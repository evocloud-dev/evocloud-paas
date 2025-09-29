#--------------------------------------------------
# Data Source to find Custom Talos Image
#--------------------------------------------------
data "oci_core_images" "talos_images" {
  compartment_id = var.OCI_TENANCY_ID
  #Optional
  display_name = var.TALOS_AMI_NAME
}

data "oci_identity_availability_domains" "az_domains" {
  #Required
  compartment_id = var.OCI_TENANCY_ID
}

#--------------------------------------------------
# Talos Control Plane VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to oci_core_instance
resource "random_integer" "zone_selector_ctrlnode" {
  for_each   = var.TALOS_CTRL_STANDALONE
  min        = 0
  max        = length(data.oci_identity_availability_domains.az_domains) - 1
}

resource "oci_core_instance" "talos_ctrlplane" {
  for_each                                = var.TALOS_CTRL_STANDALONE
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX

  shape_config {
    ocpus         = var.TALOS_CTRL_STANDALONE_OCPU
    memory_in_gbs = var.TALOS_CTRL_STANDALONE_ORAM
  }

  create_vnic_details {
    subnet_id        = var.dmz_subnet_id
    nsg_ids          = [var.public_nsg]
    assign_public_ip = true
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.talos_images.images[0].id #var.talos_image_id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.TALOS_STANDALONE_VOLUME_TYPE
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  availability_config {
    is_live_migration_preferred = true
    recovery_action             = "RESTORE_INSTANCE"
  }

  launch_options {
    boot_volume_type        = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
    network_type            = "PARAVIRTUALIZED"
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  freeform_tags               = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Configuring Talos Kubernetes Cluster
#--------------------------------------------------
## Generate machine secrets for Talos Kubernetes Cluster.
resource "talos_machine_secrets" "talos_vm" {}

## Generate the Talos client configuration
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoints = [for xvalue in oci_core_instance.talos_ctrlplane : xvalue.public_ip]
  nodes = concat(
    [for xvalue in oci_core_instance.talos_ctrlplane : xvalue.public_ip]
  )
}

## Generate the Controlplane configuration and instantiate the Talos Controlplane VMs
data "talos_machine_configuration" "talos_controlplane" {
  depends_on = [oci_core_instance.talos_ctrlplane]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${oci_core_instance.talos_ctrlplane["node01"].public_ip}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.talos_vm.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false

  #config_patches = concat(
  #  [for path in var.controlplane_config_patch_files : file(path)]
  #)
  config_patches = [
    yamlencode({
      machine = {
        sysctls = {
          "user.max_user_namespaces" = "11255"
        }
        network = {}

        certSANs = [
          oci_core_instance.talos_ctrlplane["node01"].public_ip,
          oci_core_instance.talos_ctrlplane["node01"].private_ip,
        ]
        kubelet = {
          extraArgs = {
            rotate-server-certificates = true
          }
          extraConfig = {
            featureGates = {
              UserNamespacesSupport = true
              UserNamespacesPodSecurityStandards = true
            }
          }
        }
        features = {
          kubernetesTalosAPIAccess = {
            enabled = true
            allowedRoles = ["os:reader"]
            allowedKubernetesNamespaces = ["kube-system"]
          }
        }
        systemDiskEncryption = {
          ephemeral = {
            provider = "luks2"
            keys = [
              {
                nodeID = {}
                slot = 0
              }
            ]
          }
          state = {
            provider = "luks2"
            keys = [
              {
                nodeID = {}
                slot = 0
              }
            ]
          }
        }
      }
      cluster = {
        apiServer = {
          extraArgs = {
            feature-gates = "UserNamespacesSupport=true,UserNamespacesPodSecurityStandards=true"
          }
          certSANs = [
            oci_core_instance.talos_ctrlplane["node01"].public_ip,
            oci_core_instance.talos_ctrlplane["node01"].private_ip,
          ]
        }
        network = {
          cni = {
            name = "none"
          }
          dnsDomain = "cluster.local"
          podSubnets = ["10.244.0.0/16"]
          serviceSubnets = ["10.96.0.0/12"]
        }
        proxy = {
          disabled = true
        }
        #A bug with Talos prevents discovery mechanism to work properly: https://github.com/siderolabs/talos/issues/9980
        #https://www.talos.dev/v1.9/talos-guides/discovery/
        discovery = {
          enabled = true
          registries = {
            kubernetes = {
              disabled = true
            }
            service = {}
          }
        }
        allowSchedulingOnControlPlanes = true
        //Extra Manifests
        extraManifests = [
          var.TALOS_EXTRA_MANIFESTS["gateway_api_std"],
          var.TALOS_EXTRA_MANIFESTS["gateway_api_exp"],
          var.TALOS_EXTRA_MANIFESTS["kubelet_serving_cert"],
          var.TALOS_EXTRA_MANIFESTS["kube-metric_server"],
          var.TALOS_EXTRA_MANIFESTS["local-storage_class"]
        ]
        //Inline Manifests
        inlineManifests = [
          {
            name     = "cilium-and-talos-ccm-deploy"
            contents = <<-EOT
              ---
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: cilium-install
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes CRB after 24 hours (86400 seconds)
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: cilium-install-sa
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: cilium-install-sa
                namespace: kube-system
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes SA after 24 hours (86400 seconds)
              ---
              apiVersion: batch/v1
              kind: Job
              metadata:
                name: cilium-deployer
                namespace: kube-system
              spec:
                backoffLimit: 10
                template:
                  metadata:
                    labels:
                      job: cilium-deployment
                  spec:
                    restartPolicy: OnFailure
                    tolerations:
                      - operator: Exists
                      - effect: NoSchedule
                        operator: Exists
                      - effect: NoExecute
                        operator: Exists
                      - effect: PreferNoSchedule
                        operator: Exists
                      - key: node-role.kubernetes.io/control-plane
                        operator: Exists
                        effect: NoSchedule
                      - key: node-role.kubernetes.io/control-plane
                        operator: Exists
                        effect: NoExecute
                      - key: node-role.kubernetes.io/control-plane
                        operator: Exists
                        effect: PreferNoSchedule
                    affinity:
                      nodeAffinity:
                        requiredDuringSchedulingIgnoredDuringExecution:
                          nodeSelectorTerms:
                            - matchExpressions:
                                - key: node-role.kubernetes.io/control-plane
                                  operator: Exists
                    containers:
                    - name: cilium-install
                      image: alpine/helm:3
                      env:
                      - name: KUBERNETES_SERVICE_HOST
                        valueFrom:
                          fieldRef:
                            apiVersion: v1
                            fieldPath: status.podIP
                      - name: KUBERNETES_SERVICE_PORT
                        value: "6443"
                      command:
                        - sh
                        - -c
                        - |
                          helm upgrade --install --namespace kube-system talos-cloud-controller-manager oci://ghcr.io/siderolabs/charts/talos-cloud-controller-manager -f https://raw.githubusercontent.com/evocloud-dev/evocloud-k8s-manifests/refs/heads/main/talos-ccm-gcp.yaml
                          helm repo add cilium https://helm.cilium.io/
                          helm repo update
                          helm upgrade --install cilium cilium/cilium \
                          --version 1.18.2 \
                          --namespace kube-system \
                          --set k8sServiceHost=localhost \
                          --set k8sServicePort=7445 \
                          --set k8sClientRateLimit.qps=50 \
                          --set k8sClientRateLimit.burst=200 \
                          --set cluster.name=evo-cluster-mgr \
                          --set cluster.id=0 \
                          --set rollOutCiliumPods=true \
                          --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
                          --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
                          --set l2announcements.enabled=true \
                          --set l2announcements.leaseDuration=15s \
                          --set l2announcements.leaseRenewDeadline=5s \
                          --set l2announcements.leaseRetryPeriod=1s \
                          --set envoyConfig.enabled=true \
                          --set gatewayAPI.enabled=true \
                          --set gatewayAPI.enableAppProtocol=true \
                          --set gatewayAPI.enableAlpn=true \
                          --set-string gatewayAPI.gatewayClass.create=true \
                          --set externalIPs.enabled=true \
                          --set ipam.mode=kubernetes \
                          --set kubeProxyReplacement=true \
                          --set maglev.tableSize=65521 \
                          --set operator.rollOutPods=true \
                          --set cgroup.autoMount.enabled=false \
                          --set cgroup.hostRoot=/sys/fs/cgroup \
                          --set envoy.securityContext.capabilities.envoy="{NET_ADMIN,NET_BIND_SERVICE,PERFMON,BPF}" \
                          --set envoy.securityContext.capabilities.keepCapNetBindService=true
                    serviceAccount: cilium-install-sa
                    serviceAccountName: cilium-install-sa
                    hostNetwork: true
            EOT
          },
          {
            name     = "evocloud-ns"
            contents = <<-EOT
              apiVersion: v1
              kind: Namespace
              metadata:
                name: evocloud-ns
            EOT
          },
        ]
      }
    }),
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [data.talos_machine_configuration.talos_controlplane]

  for_each                    = oci_core_instance.talos_ctrlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = each.value.public_ip
  node                        = each.value.public_ip
}

## Start the bootstraping of the Talos Kubernetes Cluster
resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = oci_core_instance.talos_ctrlplane["node01"].public_ip
  node                 = oci_core_instance.talos_ctrlplane["node01"].public_ip
}

## Check whether the Talos Kubernetes Cluster is in a healthy state
#data "talos_cluster_health" "cluster_health" {
#  depends_on = [talos_machine_bootstrap.bootstrap_cluster]

#  client_configuration    = talos_machine_secrets.talos_vm.client_configuration
#  control_plane_nodes     = [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip]
#  endpoints               = [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip]
#  skip_kubernetes_checks  = true
#}

## Collect the Talos Kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [
    talos_machine_bootstrap.bootstrap_cluster
    #data.talos_cluster_health.cluster_health,
  ]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = oci_core_instance.talos_ctrlplane["node01"].public_ip
  node                 = oci_core_instance.talos_ctrlplane["node01"].public_ip
}

#--------------------------------------------------
# Write out Kubeconfig and Talosconfig to a file
#--------------------------------------------------
resource "local_file" "talos_kubeconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/tmp/kubeconfig/kubeconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw}
  EOF
}

resource "local_file" "talos_talosconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/tmp/talosconfig/talosconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${data.talos_client_configuration.talosconfig.talos_config}
  EOF
}
