#--------------------------------------------------
# Data Source to find Custom Talos Image
#--------------------------------------------------
data "oci_core_images" "talos_images" {
  compartment_id = var.OCI_TENANCY_ID
  #Optional
  display_name = var.TALOS_AMI_NAME
}

#--------------------------------------------------
# Data Source to find EvoVM Linux Image
#--------------------------------------------------
data "oci_core_images" "evovm_image" {
  compartment_id  = var.OCI_TENANCY_ID
  #Optional
  display_name    = var.BASE_AMI_NAME
}

#--------------------------------------------------
# Data import for Availability Domain
#--------------------------------------------------
data "oci_identity_availability_domains" "az_domains" {
  #Required
  compartment_id = var.OCI_TENANCY_ID
}

#--------------------------------------------------
# LoadBalancer Virtual IP
#--------------------------------------------------
resource "oci_core_private_ip" "gateway_vip" {
  display_name    = "${var.cluster_name}-gateway-vip"
  #subnet_id       = var.admin_subnet_id
  vnic_id         = data.oci_core_vnic_attachments.lb01_vnic_attachment.vnic_attachments[0].vnic_id
  freeform_tags   = {"Platform"= "EvoCloud"}
}

data "oci_core_vnic_attachments" "lb01_vnic_attachment" {
  depends_on = [
    oci_core_instance.talos_loadbalancer["node01"]
  ]

  compartment_id = var.OCI_TENANCY_ID
  instance_id    = oci_core_instance.talos_loadbalancer["node01"].id
}

#resource "attachment" "" {}

#--------------------------------------------------
# Loadbalancer VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to oci_core_instance
resource "random_integer" "zone_selector_ctrlnode" {
  for_each   = var.TALOS_LB_NODES
  min        = 0
  max        = length(data.oci_identity_availability_domains.az_domains) - 1
}

resource "oci_core_instance" "talos_loadbalancer" {
  for_each                                = var.TALOS_LB_NODES
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX

  shape_config {
    ocpus         = var.TALOS_LB_OCPU
    memory_in_gbs = var.TALOS_LB_ORAM
  }

  metadata = {
    ssh_authorized_keys = file("${var.NODE_PUBLIC_KEY_PAIR}")
  }

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.evovm_image.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.TALOS_LB_BASE_VOLUME_TYPE
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

  provisioner "remote-exec" {
    inline = [ "echo 'EvoNODE Readiness Check Succeeded: Instance is fully up.'" ]
    connection {
      type = "ssh"
      user = var.CLOUD_USER
      timeout = "10"
      private_key = file(var.NODE_PRIVATE_KEY_PAIR)
      host = self.private_ip
    }
  }

  freeform_tags               = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Talos Control Plane VMs
#--------------------------------------------------
resource "oci_core_instance" "talos_ctrlplane" {
  for_each                                = var.TALOS_CTRL_NODES
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX

  shape_config {
    ocpus         = var.TALOS_CTRL_OCPU
    memory_in_gbs = var.TALOS_CTRL_ORAM
  }

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.talos_images.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.TALOS_CTRL_BASE_VOLUME_TYPE
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
#Talos Worker VMs
#--------------------------------------------------
resource "oci_core_instance" "talos_workload" {
  for_each                                = var.TALOS_WKLD_NODES
  compartment_id                          = var.OCI_TENANCY_ID
  display_name                            = format("%s", each.value.short_name)
  availability_domain                     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  shape                                   = var.BASE_SHAPE_E4_FLEX

  shape_config {
    ocpus         = var.TALOS_WKLD_OCPU
    memory_in_gbs = var.TALOS_WKLD_ORAM
  }

  create_vnic_details {
    subnet_id        = var.admin_subnet_id
    nsg_ids          = [var.private_nsg]
    assign_public_ip = false
    #hostname_label = format("%s.%s", each.value, var.DOMAIN_TLD)
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.talos_images.images[0].id
    boot_volume_size_in_gbs = var.BASE_VOLUME_50
    boot_volume_vpus_per_gb = var.TALOS_WKLD_BASE_VOLUME_TYPE

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

##Talos Worker VMs Extra disk creation and attachment
resource "oci_core_volume" "extra_disk" {
  compartment_id                          = var.OCI_TENANCY_ID
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  display_name            = "${oci_core_instance.talos_workload[each.key].display_name}-extra-volume"
  availability_domain     = data.oci_identity_availability_domains.az_domains.availability_domains[0].name
  vpus_per_gb             = var.TALOS_WKLD_BASE_VOLUME_TYPE
  size_in_gbs             = var.BASE_VOLUME_200
  freeform_tags           = {"Platform"= "EvoCloud"}
}

resource "oci_core_volume_attachment" "disk_attachment" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }
  volume_id   = oci_core_volume.extra_disk[each.key].id
  instance_id = oci_core_instance.talos_workload[each.key].id
  attachment_type = "PARAVIRTUALIZED"
}

#--------------------------------------------------
# Ansible Configuration Management Code - LB NODES
#--------------------------------------------------
resource "terraform_data" "redeploy_talos_lb" {
  input = var.taloslb_revision
}

resource "terraform_data" "talos_lb_configuration" {
  depends_on = [
    oci_core_instance.talos_loadbalancer,
    oci_core_instance.talos_ctrlplane
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_talos_lb]
  }

  for_each = oci_core_instance.talos_loadbalancer

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/talos-kube-lb.yml --forks 10 --inventory-file ${each.value.private_ip}, --user ${var.CLOUD_USER} --private-key ${var.NODE_PRIVATE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args "-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'" --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml server_ip=${each.value.private_ip} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} server_short_hostname=${each.value.display_name} domain_tld=${var.DOMAIN_TLD} server_timezone=${var.DEFAULT_TIMEZONE} cloud_user=${var.CLOUD_USER} metadata_ns_ip=${var.OCI_METADATA_NS} idam_replica_ip=${var.idam_replica_ip} upstream_servers=${join(",", values(oci_core_instance.talos_ctrlplane)[*].private_ip)} ports_list=[80,443,6443,50000] lb_node01_ip=${oci_core_instance.talos_loadbalancer["node01"].private_ip} lb_node02_ip=${oci_core_instance.talos_loadbalancer["node02"].private_ip} gateway_vip=${trimsuffix(oci_core_private_ip.gateway_vip.ip_address, ",")} zone=${trimsuffix(each.value.availability_domain, ", ")}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/server-admin-talos_loadbalancer.log"
    }
  }
}

#--------------------------------------------------
# Configuring Talos Kubernetes Cluster
#--------------------------------------------------
## Generate machine secrets for Talos Kubernetes Cluster.
resource "talos_machine_secrets" "talos_vm" {}

## Talos Client Configuration
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoints = [for xvalue in oci_core_instance.talos_ctrlplane : xvalue.private_ip]
  nodes = concat(
    [for xvalue in oci_core_instance.talos_ctrlplane : xvalue.private_ip],
    [for xvalue in oci_core_instance.talos_workload : xvalue.private_ip],
  )
}

## Control Plane Machine Configuration
data "talos_machine_configuration" "talos_controlplane" {
  depends_on = [oci_core_instance.talos_ctrlplane, oci_core_instance.talos_loadbalancer]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${oci_core_private_ip.gateway_vip.ip_address}:6443"
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
          oci_core_instance.talos_loadbalancer["node01"].private_ip,
          oci_core_instance.talos_loadbalancer["node02"].private_ip,
          oci_core_private_ip.gateway_vip.ip_address,
        ]
        kubelet = {
          extraArgs = {
            cloud-provider = "external"
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
            oci_core_instance.talos_loadbalancer["node01"].private_ip,
            oci_core_instance.talos_loadbalancer["node02"].private_ip,
            oci_core_private_ip.gateway_vip.ip_address,
          ]
        }
        network = {
          cni = {
            name = "none"
          }
          dnsDomain = "cluster.local"
          podSubnets = ["10.17.0.0/17"]
          serviceSubnets = ["10.17.128.0/17"]
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
              disabled = false
            }
            service = {
              disabled = true
            }
          }
        }
        extraManifests = [
          var.TALOS_EXTRA_MANIFESTS["gateway_api_std"],
          var.TALOS_EXTRA_MANIFESTS["gateway_api_exp"],
          var.TALOS_EXTRA_MANIFESTS["kubelet_serving_cert"],
          var.TALOS_EXTRA_MANIFESTS["kube-metric_server"],
          var.TALOS_EXTRA_MANIFESTS["local-storage_class"],
          var.TALOS_EXTRA_MANIFESTS["kube-buildpack"]
        ]
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
                            --version 0.4.1 \
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
                            --version 1.10.4 \
                            --wait
                    restartPolicy: OnFailure
                    serviceAccount: vela-install
                    serviceAccountName: vela-install
            EOT
          },
          {
            name     = "flux-helm-deploy"
            contents = <<-EOT
              ---
              #Flux Operator Chart Repo: https://github.com/controlplaneio-fluxcd/charts/tree/main/charts/flux-operator
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-install
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes CRB after 24 hours (86400 seconds)
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-install
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-install
                namespace: kube-system
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes SA after 24 hours (86400 seconds)
              ---
              #https://operatorhub.io/operator/flux-operator
              apiVersion: batch/v1
              kind: Job
              metadata:
                name: flux-operator-deploy
                namespace: kube-system
              spec:
                backoffLimit: 10
                template:
                  metadata:
                    labels:
                      job: flux-operator-deployment
                  spec:
                    containers:
                    - name: helm
                      image: alpine/helm:3
                      command:
                        - sh
                        - -c
                        - |
                          kubectl create namespace flux-system || true
                          helm upgrade --install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
                            --namespace flux-system \
                            --create-namespace \
                            --version 0.30.0 \
                            --wait
                    restartPolicy: OnFailure
                    serviceAccount: flux-install
                    serviceAccountName: flux-install
              ---
              #Deploying Flux Instance with Multi-tenancy Disabled
              apiVersion: fluxcd.controlplane.io/v1
              kind: FluxInstance
              metadata:
                name: flux
                namespace: flux-system
                annotations:
                  fluxcd.controlplane.io/reconcileEvery: "1h"
                  fluxcd.controlplane.io/reconcileArtifactEvery: "15m"
                  fluxcd.controlplane.io/reconcileTimeout: "20m"
              spec:
                distribution:
                  version: "2.7.x"
                  registry: "ghcr.io/fluxcd"
                  artifact: "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
                components:
                  - source-controller
                  - kustomize-controller
                  - helm-controller
                  - notification-controller
                  - image-reflector-controller
                  - image-automation-controller
                  - source-watcher
                cluster:
                  type: kubernetes
                  multitenant: false
                  networkPolicy: false
                  domain: "cluster.local"
                kustomize:
                  patches:
                    - target:
                        kind: Deployment
                        name: "(kustomize-controller|helm-controller)"
                      patch: |
                        - op: add
                          path: /spec/template/spec/containers/0/args/-
                          value: --concurrent=10
                        - op: add
                          path: /spec/template/spec/containers/0/args/-
                          value: --requeue-dependency=15s
              ---
              ############################################
              #DEPLOYING ROOK STORAGE SOLUTION
              ############################################
              apiVersion: v1
              kind: Namespace
              metadata:
                name: rook-ceph
                labels:
                  pod-security.kubernetes.io/enforce: privileged #Talos default PodSecurity configuration prevents execution of priviledged pods. Adding a label to the namespace will allow ceph to start
              ---
              #Dedicated service account for flux in rook-ceph namespace
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-rook-ceph
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-rook-ceph-sa
                namespace: rook-ceph
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-rook-ceph-sa
                namespace: rook-ceph
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: rook-release
                namespace: rook-ceph
              spec:
                interval: 24h
                url: https://charts.rook.io/release
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: rook-ceph-operator
                namespace: rook-ceph
              spec:
                chart:
                  spec:
                    chart: rook-ceph
                    sourceRef:
                      kind: HelmRepository
                      name: rook-release
                    version: "v1.17.*"
                serviceAccountName: flux-rook-ceph-sa
                interval: 30m0s
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 3
                driftDetection:
                  mode: enabled
                values:
                  enableDiscoveryDaemon: true
                  discoveryDaemonInterval: 15m
                  monitoring:
                    enabled: true
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: rook-ceph-cluster
                namespace: rook-ceph
              spec:
                dependsOn:
                  - name: rook-ceph-operator
                chart:
                  spec:
                    chart: rook-ceph-cluster
                    sourceRef:
                      kind: HelmRepository
                      name: rook-release
                    version: "v1.17.*"
                serviceAccountName: flux-rook-ceph-sa
                interval: 35m0s
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 3
                driftDetection:
                  mode: enabled
                values:
                  toolbox:
                    enabled: true
                  mgr:
                    modules:
                      - name: rook
                        enabled: true
                  monitoring:
                    enabled: true
                    createPrometheusRules: true

              ---
              ############################################
              #HEADLAMP DEPLOYMENT
              ############################################
              apiVersion: v1
              kind: Namespace
              metadata:
                name: headlamp
              ---
              #Dedicated service account for headlamp in headlamp namespace
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-headlamp
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-headlamp-sa
                namespace: headlamp
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-headlamp-sa
                namespace: headlamp
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: headlamp-release
                namespace: headlamp
              spec:
                interval: 24h
                url: https://kubernetes-sigs.github.io/headlamp
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: headlamp
                namespace: headlamp
              spec:
                dependsOn:
                  - name: rook-ceph-cluster
                    namespace: rook-ceph
                chart:
                  spec:
                    chart: headlamp
                    sourceRef:
                      kind: HelmRepository
                      name: headlamp-release
                    version: "0.36.*"
                serviceAccountName: flux-headlamp-sa
                interval: 30m0s
                timeout: 25m0s
                driftDetection:
                  mode: enabled
                values:
                  serviceAccount:
                    name: "headlamp-admin"
                  ingress:
                    enabled: false
                  config:
                    pluginsDir: /build/plugins
                  initContainers:
                    - command:
                        - /bin/sh
                        - -c
                        - mkdir -p /build/plugins && cp -r /plugins/* /build/plugins/
                      image: ghcr.io/evocloud-dev/headlamp/evo-headlamp-plugins:0.1.0 #custom-built plugin image
                      imagePullPolicy: Always
                      name: headlamp-plugins
                      securityContext:
                        runAsNonRoot: false
                        privileged: false
                        runAsUser: 0
                        runAsGroup: 101
                      volumeMounts:
                        - mountPath: /build/plugins
                          name: headlamp-plugins
                  persistentVolumeClaim:
                    enabled: true
                    accessModes:
                      - ReadWriteOnce
                    size: 1Gi
                  volumeMounts:
                    - mountPath: /build/plugins
                      name: headlamp-plugins
                  volumes:
                    - name: headlamp-plugins
                      persistentVolumeClaim:
                        claimName: headlamp

              ---
              ###################################################
              #KUBE PROMETHEUS STACK
              ###################################################
              apiVersion: v1
              kind: Namespace
              metadata:
                name: monitoring
                labels:
                  pod-security.kubernetes.io/enforce: privileged #Talos default PodSecurity configuration prevents execution of priviledged pods. Adding a label to the namespace will allow deamonsets to start
              ---
              #Dedicated service account for headlamp in headlamp namespace
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-kube-promstack
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-kube-promstack-sa
                namespace: monitoring
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-kube-promstack-sa
                namespace: monitoring
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: kube-promstack-release
                namespace: monitoring
              spec:
                interval: 24h
                type: oci
                url: oci://ghcr.io/prometheus-community/charts
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: kube-promstack-stack
                namespace: monitoring
              spec:
                chart:
                  spec:
                    chart: kube-prometheus-stack
                    sourceRef:
                      kind: HelmRepository
                      name: kube-promstack-release
                    version: "77.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-kube-promstack-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                driftDetection:
                  mode: enabled
                values:
                  grafana:
                    adminPassword: prom-operator
                  nodeExporter:
                    enabled: true
                    operatingSystems:
                      linux:
                        enabled: true
                      aix:
                        enabled: false
                      darwin:
                        enabled: false
              ---
              ###################################################
              #OpenCost Billing
              ###################################################
              # #https://opencost.io/docs/configuration/gcp
              apiVersion: v1
              kind: Namespace
              metadata:
                name: opencost
              ---
              #Dedicated service account for opencost in opencost namespace
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-opencost
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-opencost-sa
                namespace: opencost
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-opencost-sa
                namespace: opencost
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: kube-opencost-release
                namespace: opencost
              spec:
                interval: 24h
                url: https://opencost.github.io/opencost-helm-chart
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: kube-opencost-stack
                namespace: opencost
              spec:
                chart:
                  spec:
                    chart: opencost
                    sourceRef:
                      kind: HelmRepository
                      name: kube-opencost-release
                    version: "2.3.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-opencost-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                driftDetection:
                  mode: enabled
                values:
                  networkPolicies:
                    prometheus:
                      namespace: monitoring
                  opencost:
                    exporter:
                      cloudProviderApiKey: "op3nco57op3Nco57OP3Nco57op3nco57op3Nco57"
                    prometheus:
                      internal:
                        enabled: true
                        namespaceName: monitoring
                        port: 9090
                        serviceName: kube-promstack-stack-kube-prometheus
              ---
              ###################################################
              #KubeScape Vulnerability Scanner
              ###################################################
              # https://github.com/kubescape/helm-charts
              apiVersion: v1
              kind: Namespace
              metadata:
                name: kubescape
                labels:
                  pod-security.kubernetes.io/enforce: privileged #Talos default PodSecurity configuration prevents execution of priviledged pods.
              ---
              #Dedicated service account for kubescape in kubescape namespace
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-kubescape
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-kubescape-sa
                namespace: kubescape
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-kubescape-sa
                namespace: kubescape
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: kubescape-release
                namespace: kubescape
              spec:
                interval: 24h
                url: https://kubescape.github.io/helm-charts
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: kubescape-stack
                namespace: kubescape
              spec:
                dependsOn:
                  - name: rook-ceph-cluster
                    namespace: rook-ceph
                chart:
                  spec:
                    chart: kubescape-operator
                    sourceRef:
                      kind: HelmRepository
                      name: kubescape-release
                    version: "1.29.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-kubescape-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                driftDetection:
                  mode: enabled
                values:
                  clusterName: evo-cluster-mgr
                  capabilities:
                    continuousScan: enable

              ---
              ############################################
              #DEPLOYING KEDA
              ############################################
              #https://github.com/kedacore/charts
              apiVersion: v1
              kind: Namespace
              metadata:
                name: keda
              ---
              #Dedicated service account for keda
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-keda
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-keda-sa
                namespace: keda
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-keda-sa
                namespace: keda
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: keda-release
                namespace: keda
              spec:
                interval: 24h
                url: https://kedacore.github.io/charts
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: keda-stack
                namespace: keda
              spec:
                chart:
                  spec:
                    chart: keda
                    sourceRef:
                      kind: HelmRepository
                      name: keda-release
                    version: "2.17.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-keda-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                  #cleanupOnFail: true
                driftDetection:
                  mode: enabled
                values:
                  clusterName: cluster-manager
                  clusterDomain: cluster.local
                  priorityClassName: system-node-critical
                  nodeSelector:
                    node-role.kubernetes.io/control-plane: ""
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      effect: NoSchedule
              ---
              ############################################
              #DEPLOYING DAPR RUNTIME
              ############################################
              apiVersion: v1
              kind: Namespace
              metadata:
                name: dapr-system
              ---
              #Dedicated service account for keda
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-dapr
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-dapr-sa
                namespace: dapr-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-dapr-sa
                namespace: dapr-system
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: dapr-release
                namespace: dapr-system
              spec:
                interval: 24h
                url: https://dapr.github.io/helm-charts
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: dapr-stack
                namespace: dapr-system
              spec:
                dependsOn:
                  - name: rook-ceph-cluster
                    namespace: rook-ceph
                chart:
                  spec:
                    chart: dapr
                    sourceRef:
                      kind: HelmRepository
                      name: dapr-release
                    version: "1.16.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-dapr-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                  #cleanupOnFail: true
                driftDetection:
                  mode: enabled
                values:
                  global:
                    ha:
                      enabled: true
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: dapr-dashboard-stack
                namespace: dapr-system
              spec:
                dependsOn:
                  - name: dapr-stack
                chart:
                  spec:
                    chart: dapr-dashboard
                    sourceRef:
                      kind: HelmRepository
                      name: dapr-release
                    version: "0.15.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-dapr-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                  #cleanupOnFail: true
                driftDetection:
                  mode: enabled
              ---
              ###################################################
              #TRIVY  OPERATOR
              ###################################################
              # #https://aquasecurity.github.io/trivy-operator/latest/
              apiVersion: v1
              kind: Namespace
              metadata:
                name: trivy-system
                labels:
                  pod-security.kubernetes.io/enforce: privileged #Talos default PodSecurity configuration prevents execution of priviledged pods. Adding a label to the namespace will allow deamonsets to start
              ---
              #Dedicated service account for trivy
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-kube-trivy
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-kube-trivy-sa
                namespace: trivy-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-kube-trivy-sa
                namespace: trivy-system
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: kube-trivy-release
                namespace: trivy-system
              spec:
                interval: 24h
                type: oci
                url: oci://ghcr.io/aquasecurity/helm-charts
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: kube-trivy-stack
                namespace: trivy-system
              spec:
                chart:
                  spec:
                    chart: trivy-operator
                    sourceRef:
                      kind: HelmRepository
                      name: kube-trivy-release
                    version: "0.31.*"
                interval: 30m0s
                timeout: 25m0s
                serviceAccountName: flux-kube-trivy-sa
                install:
                  remediation:
                    retries: 3
                upgrade:
                  remediation:
                    retries: 2
                driftDetection:
                  mode: enabled
                values:
                  server:
                    replicas: 1
              ---
            EOT
          },
          {
            name     = "kyverno-helm-deploy"
            contents = <<-EOT
              ---
              #Kyverno Chart Repo: https://github.com/kyverno/kyverno/tree/main/charts
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: kyverno-install
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes CRB after 24 hours (86400 seconds)
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: kyverno-install
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: kyverno-install
                namespace: kube-system
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes SA after 24 hours (86400 seconds)
              ---
              apiVersion: batch/v1
              kind: Job
              metadata:
                name: kyverno-helm-deployer
                namespace: kube-system
              spec:
                backoffLimit: 10
                template:
                  metadata:
                    labels:
                      job: kyverno-helm-deployment
                  spec:
                    containers:
                    - name: helm
                      image: alpine/helm:3
                      command:
                        - sh
                        - -c
                        - |
                          kubectl create namespace kyverno || true
                          kubectl label namespace kyverno pod-security.kubernetes.io/enforce=privileged
                          helm repo add kyverno https://kyverno.github.io/kyverno/
                          helm repo update
                          helm upgrade --install kyverno kyverno/kyverno \
                            --namespace kyverno \
                            --create-namespace \
                            --version 3.5.2 \
                            --set admissionController.replicas=3 \
                            --set backgroundController.replicas=2 \
                            --set cleanupController.replicas=2 \
                            --set reportsController.replicas=2 \
                            --wait
                    restartPolicy: OnFailure
                    serviceAccount: kyverno-install
                    serviceAccountName: kyverno-install
            EOT
          },
        ]
      }
    }),
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [data.talos_machine_configuration.talos_controlplane, terraform_data.talos_lb_configuration]

  for_each                    = oci_core_instance.talos_ctrlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = each.value.private_ip
  node                        = each.value.private_ip
}

## Worker Machine Configuration
data "talos_machine_configuration" "talos_worker" {
  depends_on = [oci_core_instance.talos_workload, oci_core_instance.talos_loadbalancer]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${oci_core_private_ip.gateway_vip.ip_address}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.talos_vm.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  #config_patches = concat(
  #  [for path in var.worker_config_patch_files : file(path)]
  #)
  config_patches = [
    yamlencode({
      machine = {
        network = {}
        kubelet = {
          extraArgs = {
            cloud-provider = "external"
            rotate-server-certificates = true
          }
        }
        install = {
          extraKernelArgs = ["talos.dashboard.disabled=1"]
        }
        systemDiskEncryption = {
          ephemeral = {
            provider = "luks2"
            options = ["no_read_workqueue", "no_write_workqueue"]
            keys = [
              {
                nodeID = {}
                slot = 0
              }
            ]
          }
          state = {
            provider = "luks2"
            options = ["no_read_workqueue", "no_write_workqueue"]
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
        network = {
          cni = {
            name = "none"
          }
          dnsDomain = "cluster.local"
          podSubnets = ["10.17.0.0/17"]
          serviceSubnets = ["10.17.128.0/17"]
        }
      }
    }),
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [data.talos_machine_configuration.talos_worker, terraform_data.talos_lb_configuration, talos_machine_configuration_apply.controlplane]

  for_each                    = oci_core_instance.talos_workload
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_worker.machine_configuration
  endpoint                    = each.value.private_ip
  node                        = each.value.private_ip
}

## Bootstrap Talos K8s Cluster
resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [talos_machine_configuration_apply.controlplane, terraform_data.talos_lb_configuration]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  node                 = oci_core_private_ip.gateway_vip.ip_address
  endpoint             = oci_core_private_ip.gateway_vip.ip_address
  timeouts             = { create = "5m" }
}

## Generate kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [
    talos_machine_bootstrap.bootstrap_cluster,
  ]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  node                 = oci_core_private_ip.gateway_vip.ip_address
  endpoint             = oci_core_private_ip.gateway_vip.ip_address
}

## Save kubeconfig to a file
resource "local_file" "talos_kubeconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/home/${var.CLOUD_USER}/kubeconfig/kubeconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw}
  EOF
}

## Save talosconfig to a file
resource "local_file" "talos_talosconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/home/${var.CLOUD_USER}/talosconfig/talosconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${data.talos_client_configuration.talosconfig.talos_config}
  EOF
}
