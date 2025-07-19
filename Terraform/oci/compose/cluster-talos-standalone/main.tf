#Reference: https://github.com/siderolabs/contrib/tree/main/examples/terraform/gcp
#           https://github.com/egrosdou01/blog-post-resources/tree/main/opentofu-talos-proxmox
#           https://blog.grosdouli.dev/blog/talos-on-proxmox-opentofu-part-1
#           https://olav.ninja/talos-cluster-on-proxmox-with-terraform
#           https://vincentdeborger.be/blog/setting-up-kubernetes-using-talos-and-terraform/
#           https://www.talos.dev/v1.9/kubernetes-guides/network/deploying-cilium/
#           https://www.talos.dev/v1.9/kubernetes-guides/configuration/ceph-with-rook/
#           https://www.talos.dev/v1.9/introduction/prodnotes/
#           https://www.talos.dev/v1.9/kubernetes-guides/configuration/deploy-metrics-server/
#           https://www.talos.dev/v1.9/talos-guides/configuration/disk-encryption/
# Talos Machine Config Parameters: https://www.talos.dev/v1.9/reference/configuration/v1alpha1/config/

resource "google_compute_image" "talos_img" {
  count       = var.create_talos_img ? 1 : 0

  name        = "evocloud-talos19-b010"
  description = "Talos Base AMI Image"
  family      = "evocloud-talos19"
  labels = {
    base-image-name = "evocloud-talos19-b010"
    os-distro       = "gttech-talos-distro"
    owner           = "geanttech"
  }

  raw_disk {
    source = var.TALOS_AMI_SOURCE
  }

  guest_os_features {
    type = "VIRTIO_SCSI_MULTIQUEUE"
  }
}

#--------------------------------------------------
# Gateway LoadBalancer IP
#--------------------------------------------------
resource "google_compute_address" "gateway_vip" {
  name         = "${var.cluster_name}-gateway-vip"
  subnetwork   = var.dmz_subnet_name
  address_type = "INTERNAL"
}

#--------------------------------------------------
# Talos Control Plane VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to google_compute_instance
resource "random_integer" "zone_selector_ctrlnode" {
  for_each     = var.TALOS_CTRL_STANDALONE
  min = 0
  max = length(var.OCI_REGION) - 1
}

##Talos Controlplane VMs Creation
resource "google_compute_instance" "talos_ctrlplane" {
  depends_on = [google_compute_image.talos_img]

  for_each     = var.TALOS_CTRL_STANDALONE
  name         = format("%s", each.value)
  machine_type = var.TALOS_CTRL_STANDALONE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "Talos Controlplane Standalone Instance"
  zone         = element(var.OCI_REGION, random_integer.zone_selector_ctrlnode[each.key].result)
  hostname     = format("%s.%s", each.value, var.DOMAIN_TLD)

  boot_disk {
    initialize_params {
      image = var.TALOS_AMI_NAME
      size  = var.BASE_VOLUME_10
      type  = var.TALOS_STANDALONE_VOLUME_TYPE
      labels = {
        name = format("%s-%s", "base-volume", each.value)
      }
    }
  }

  network_interface {
    subnetwork  = var.dmz_subnet_name
  }

  allow_stopping_for_update = true

  labels = {
    server = format("%s", each.value)
  }

  #For selecting Spot Instances - Remove this snippet in production
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = var.use_spot ? "SPOT" : "STANDARD"
    instance_termination_action = "STOP" #DELETE | STOP
  }
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
  endpoints = [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip]
  nodes = concat(
    [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip],
  )
}

#Wait for 45 secondes for VM Instance to be fully available
resource "time_sleep" "wait_45_seconds" {
  depends_on = [data.talos_machine_configuration.talos_controlplane]

  create_duration = "45s"
}

## Generate the Controlplane configuration and instantiate the Talos Controlplane VMs
data "talos_machine_configuration" "talos_controlplane" {
  depends_on = [google_compute_instance.talos_ctrlplane]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip}:6443"
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
        network = {
          nameservers = [var.idam_server_ip, var.idam_replica_ip]
          interfaces = [
            {
              interface = "eth0"
              dhcp      = false
            }
          ]
        }
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
          enabled = false
          registries = {
            kubernetes = {
              disabled = false
            }
            service = {
              disabled = true
            }
          }
        }
        allowSchedulingOnControlPlanes = true
        //Extra Manifests
        extraManifests = [
          var.TALOS_EXTRA_MANIFESTS["gateway_api_std"],
          var.TALOS_EXTRA_MANIFESTS["gateway_api_tls"],
          var.TALOS_EXTRA_MANIFESTS["kubelet_serving_cert"],
          var.TALOS_EXTRA_MANIFESTS["kube-metric_server"],
          var.TALOS_EXTRA_MANIFESTS["local-storage_class"],
          var.TALOS_EXTRA_MANIFESTS["kube-buildpack"]
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
                          --version 1.17.5 \
                          --namespace kube-system \
                          --set k8sServiceHost=localhost \
                          --set k8sServicePort=7445 \
                          --set k8sClientRateLimit.qps=50 \
                          --set k8sClientRateLimit.burst=200 \
                          --set cluster.name=evo-cluster-std \
                          --set cluster.id=99 \
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
          {
            name     = "kro-helm-deploy"
            contents = <<-EOT
              ---
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: kro-install
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes CRB after 24 hours (86400 seconds)
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: kro-install
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: kro-install
                namespace: kube-system
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes SA after 24 hours (86400 seconds)
              ---
              apiVersion: batch/v1
              kind: Job
              metadata:
                name: kro-app-deployer
                namespace: kube-system
              spec:
                backoffLimit: 10
                template:
                  metadata:
                    labels:
                      job: kro-deployment
                  spec:
                    containers:
                    - name: helm
                      image: alpine/helm:3
                      command:
                        - sh
                        - -c
                        - |
                          kubectl create namespace kro || true
                          helm upgrade --install kro-orchestrator oci://ghcr.io/kro-run/kro/kro \
                            --namespace kro \
                            --create-namespace \
                            --version 0.3.0 \
                            --wait
                    restartPolicy: OnFailure
                    serviceAccount: kro-install
                    serviceAccountName: kro-install
            EOT
          },
          {
            name     = "kubevela-helm-deploy"
            contents = <<-EOT
              ---
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: kubevela-install
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes CRB after 24 hours (86400 seconds)
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: vela-install
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: vela-install
                namespace: kube-system
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes SA after 24 hours (86400 seconds)
              ---
              apiVersion: batch/v1
              kind: Job
              metadata:
                name: vela-helm-app-deployer
                namespace: kube-system
              spec:
                backoffLimit: 10
                template:
                  metadata:
                    labels:
                      job: vela-deployment
                  spec:
                    containers:
                    - name: helm
                      image: alpine/helm:3
                      command:
                        - sh
                        - -c
                        - |
                          kubectl create namespace vela-system || true
                          helm repo add kubevela https://kubevela.github.io/charts
                          helm repo update
                          helm upgrade --install kubevela kubevela/vela-core \
                            --namespace vela-system \
                            --create-namespace \
                            --version 1.10.3 \
                            --wait
                    restartPolicy: OnFailure
                    serviceAccount: vela-install
                    serviceAccountName: vela-install
            EOT
          },
        ]
      }
    }),
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [data.talos_machine_configuration.talos_controlplane]

  for_each                    = google_compute_instance.talos_ctrlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = each.value.network_interface[0].network_ip
  node                        = each.value.network_interface[0].network_ip
}

## Start the bootstraping of the Talos Kubernetes Cluster
resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
  node                 = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
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
    talos_machine_bootstrap.bootstrap_cluster,
    #data.talos_cluster_health.cluster_health,
  ]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
  node                 = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
}

#--------------------------------------------------
# Write out Kubeconfig and Talosconfig to a file
#--------------------------------------------------
resource "local_file" "talos_kubeconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/home/${var.CLOUD_USER}/kubeconfig/kubeconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw}
  EOF
}

resource "local_file" "talos_talosconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/home/${var.CLOUD_USER}/talosconfig/talosconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${data.talos_client_configuration.talosconfig.talos_config}
  EOF
}

############### CILIUM HELM TEMPLATE GENERATION CODE ############################
#Parameter options: https://docs.cilium.io/en/stable/cmdref/cilium-agent/t
#cd cilium-1.16.6/install/kubernetes/
#Basic Cilium Deployment with no kube-prometheus monitoring integration
#helm template cilium ./cilium \
#--version 1.17.3 \
#--namespace kube-system \
#--set ipam.mode=kubernetes \
#--set kubeProxyReplacement=true \
#--set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
#--set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
#--set cgroup.autoMount.enabled=false \
#--set cgroup.hostRoot=/sys/fs/cgroup \
#--set k8sServiceHost=localhost \
#--set k8sServicePort=7445 \
#--set k8sClientRateLimit.qps=50 \
#--set k8sClientRateLimit.burst=200 \
#--set=gatewayAPI.enabled=true \
#--set=gatewayAPI.enableAlpn=true \
#--set l2announcements.enabled=true \
#--set=gatewayAPI.enableAppProtocol=true \
#--set operator.rollOutPods=true \
#--set rollOutCiliumPods=true \
#--set hubble.relay.enabled=true \
#--set hubble.ui.enabled=true \
#--set envoy.securityContext.capabilities.keepCapNetBindService=true > /home/mlkroot/cilium.yaml

#To add kube-prometheus monitoring integration:
#
#--set operator.prometheus.enabled=true \
#--set operator.prometheus.serviceMonitor.enabled=true \
#--set operator.dashboards.enabled=true \
#--set operator.dashboards.namespace=monitoring \
#--set monitor.enabled=true \
#--set prometheus.enabled=true \
#--set prometheus.serviceMonitor.enabled=true \
#--set prometheus.serviceMonitor.trustCRDsExist=true \
#--set dashboards.enabled=true \
#--set dashboards.namespace=monitoring \
#--set hubble.metrics.enableOpenMetrics=true \
#--set hubble.metrics.serviceMonitor.enabled=true \
#--set hubble.metrics.dashboards.enabled=true \
#--set hubble.metrics.dashboards.namespace=monitoring \
#--set hubble.metrics.dashboards.annotations.grafana_folder=Hubble \
#--set hubble.relay.prometheus.enabled=true \
#--set hubble.relay.prometheus.serviceMonitor.enabled=true \
#--set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"     \
#--set prometheus.enabled=true \

#To tweak the load balancing algorithm
#
#--set loadBalancer.algorithm=maglev \
#--set loadBalancer.mode=dsr \

############### ROOK-CEPH HELM TEMPLATE GENERATION CODE ############################
# https://www.talos.dev/v1.9/kubernetes-guides/configuration/ceph-with-rook/
#Talos Kubernetes Cluster requires to label namespace rook-ceph with 'pod-security.kubernetes.io/enforce=privileged' for it to work
#
#helm template --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph \
#--set monitoring.enabled=true > /home/mlkroot/rook-operator-v1.17.1.yaml
#
#helm template --create-namespace --namespace rook-ceph rook-ceph-cluster \
# --set operatorNamespace=rook-ceph \
# --set toolbox.enabled=true \
# --set monitoring.enabled=true rook-release/rook-ceph-cluster > /home/mlkroot/rook-cluster-v1.17.1.yaml
