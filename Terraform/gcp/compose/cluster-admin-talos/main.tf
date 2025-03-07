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
# Talos Virtual IP
#--------------------------------------------------
resource "google_compute_address" "talos_vip" {
  name         = "${var.cluster_name}-talos-vip"
  subnetwork   = var.admin_subnet_name
  address_type = "INTERNAL"
}

#--------------------------------------------------
# Ingress Load balancer IP Pool
#--------------------------------------------------
resource "google_compute_address" "ingress_lb_ip" {
  name         = "${var.cluster_name}-talos-ingress-lb"
  subnetwork   = var.admin_subnet_name
  address_type = "INTERNAL"
}

#--------------------------------------------------
# Talos Control Plane VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to google_compute_instance
resource "random_integer" "zone_selector_ctrlnode" {
  for_each     = var.TALOS_CTRL_NODES
  min = 0
  max = length(var.GCP_REGIONS) - 1
}

##Talos Controlplane VMs Creation
resource "google_compute_instance" "talos_ctrlplane" {
  depends_on = [google_compute_image.talos_img]

  for_each     = var.TALOS_CTRL_NODES
  name         = format("%s", each.value)
  machine_type = var.TALOS_CTRL_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "Talos Controlplane VM Instance"
  zone         = element(var.GCP_REGIONS, random_integer.zone_selector_ctrlnode[each.key].result)
  hostname     = format("%s.%s", each.value, var.DOMAIN_TLD)

  boot_disk {
    initialize_params {
      image = var.TALOS_AMI_NAME
      size  = var.BASE_VOLUME_10
      type  = var.TALOS_CTRL_BASE_VOLUME_TYPE
      labels = {
        name = format("%s-%s", "base-volume", each.value)
      }
    }
  }

  network_interface {
    subnetwork  = var.admin_subnet_name
  }

  allow_stopping_for_update = true

  labels = {
    server = format("%s", each.value)
  }

  #metadata_startup_script = "/usr/bin/date"

  #For selecting Spot Instances - Remove this snippet in production
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT" #SPOT | STANDARD
    instance_termination_action = "STOP" #DELETE | STOP
  }
}

#--------------------------------------------------
#Talos Worker VMs
#--------------------------------------------------
# random_integer resource is needed to be able to assign different zones to google_compute_instance
resource "random_integer" "zone_selector_wkldnode" {
  for_each     = var.TALOS_WKLD_NODES
  min = 0
  max = length(var.GCP_REGIONS) - 1
}

##Talos Worker VMs Creation
resource "google_compute_instance" "talos_workload" {
  depends_on = [google_compute_image.talos_img]

  for_each     = var.TALOS_WKLD_NODES
  name         = format("%s", each.value.short_name)
  machine_type = var.TALOS_WKLD_INSTANCE_SIZE #custom-6-20480 | custom-6-15360-ext
  description  = "Talos Workload VM Instance"
  zone         = element(var.GCP_REGIONS, random_integer.zone_selector_wkldnode[each.key].result)
  hostname     = format("%s.%s", each.value.short_name, var.DOMAIN_TLD)

  boot_disk {
    initialize_params {
      image = var.TALOS_AMI_NAME
      size  = var.BASE_VOLUME_10
      type  = var.TALOS_WKLD_BASE_VOLUME_TYPE
      labels = {
        name = format("%s-%s", "base-volume", each.value.short_name)
      }
    }
  }

  network_interface {
    subnetwork  = var.admin_subnet_name
  }

  allow_stopping_for_update = true

  labels = {
    server = format("%s", each.value.short_name)
  }

  #metadata_startup_script = "/usr/bin/date"

  #For selecting Spot Instances - Remove this snippet in production
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT" #SPOT | STANDARD
    instance_termination_action = "STOP" #DELETE | STOP
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

##Talos Worker VMs Extra disk creation and attachment
resource "google_compute_disk" "extra_disk" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  name  = "${google_compute_instance.talos_workload[each.key].name}-extra-volume"
  type  = var.TALOS_WKLD_EXTRA_VOLUME_TYPE
  size  = var.BASE_VOLUME_200
  zone  = google_compute_instance.talos_workload[each.key].zone
  physical_block_size_bytes = 4096
}

resource "google_compute_attached_disk" "disk_attachment" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }
  disk     = google_compute_disk.extra_disk[each.key].name
  instance = google_compute_instance.talos_workload[each.key].self_link
  mode     = "READ_WRITE"
  zone     = google_compute_instance.talos_workload[each.key].zone
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
    [for xvalue in google_compute_instance.talos_workload : xvalue.network_interface[0].network_ip],
  )
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
        network = {
          nameservers = [var.idam_server_ip, var.idam_replica_ip, var.GCP_METADATA_NS]
          interfaces = [
            {
              interface = "eth0"
              dhcp      = false
              vip       = {
                ip = google_compute_address.talos_vip.address
              }
            }
          ]
        }
        kubelet = {
          extraArgs = {
            rotate-server-certificates = true
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
          certSANs = [
            google_compute_address.talos_vip.address,
          ]
        }
        network = {
          cni = {
            name = "none"
          }
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
          var.TALOS_EXTRA_MANIFESTS["gateway_api_tls"],
          var.TALOS_EXTRA_MANIFESTS["cilium_manifest"],
          var.TALOS_EXTRA_MANIFESTS["rook_ceph_operator"],
          var.TALOS_EXTRA_MANIFESTS["rook_ceph_cluster"],
          var.TALOS_EXTRA_MANIFESTS["headlamp_ui"],
          var.TALOS_EXTRA_MANIFESTS["kyverno_policy"],
          var.TALOS_EXTRA_MANIFESTS["kubelet_serving_cert"],
          var.TALOS_EXTRA_MANIFESTS["kube-metric_server"],
          var.TALOS_EXTRA_MANIFESTS["flux-cd-operator"]
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

## Generate the Worker configuration and instantiate the Talos Worker VMs
data "talos_machine_configuration" "talos_worker" {
  depends_on = [google_compute_instance.talos_workload]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip}:6443"
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
        network = {
          nameservers = [var.idam_server_ip, var.idam_replica_ip, var.GCP_METADATA_NS]
        }
        kubelet = {
          extraArgs = {
            rotate-server-certificates = true
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
    }),
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [data.talos_machine_configuration.talos_worker]

  for_each                    = google_compute_instance.talos_workload
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_worker.machine_configuration
  endpoint                    = each.value.network_interface[0].network_ip
  node                        = each.value.network_interface[0].network_ip
}

## Start the bootstraping of the Talos Kubernetes Cluster
resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [talos_machine_configuration_apply.worker]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
  node                 = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
}

## Check whether the Talos Kubernetes Cluster is in a healthy state
#data "talos_cluster_health" "cluster_health" {
#  depends_on = [talos_machine_bootstrap.bootstrap_cluster]

#  client_configuration    = talos_machine_secrets.talos_vm.client_configuration
#  control_plane_nodes     = [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip]
#  worker_nodes            = [for xvalue in google_compute_instance.talos_workload : xvalue.network_interface[0].network_ip]
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


############### CILIUM HELM TEMPLATE GENERATION CODE ############################
#Documentation: https://docs.cilium.io/en/stable/
#Parameter options: https://docs.cilium.io/en/stable/cmdref/cilium-agent/
#helm repo add cilium https://helm.cilium.io/
#Basic Cilium Deployment with no kube-prometheus monitoring integration
#helm template cilium cilium/cilium \
#--version 1.17.0 \
#--namespace kube-system \
#--set k8sServiceHost=localhost \
#--set k8sServicePort=7445 \
#--set k8sClientRateLimit.qps=50 \
#--set k8sClientRateLimit.burst=200 \
#--set cluster.name=evokube-mgr \
#--set cluster.id=0 \
#--set rollOutCiliumPods=true \
#--set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
#--set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
#--set l2announcements.enabled=true \
#--set envoyConfig.enabled=true \
#--set ingressController.enabled=true \
#--set gatewayAPI.enabled=true \
#--set gatewayAPI.enableAppProtocol=true \
#--set gatewayAPI.enableAlpn=true \
#--set-string gatewayAPI.gatewayClass.create=true \
#--set externalIPs.enabled=true \
#--set hubble.relay.enabled=true \
#--set hubble.ui.enabled=true \
#--set hubble.ui.rollOutPods=true \
#--set ipam.mode=kubernetes \
#--set kubeProxyReplacement=true \
#--set maglev.tableSize=65521 \
#--set loadBalancer.algorithm=maglev \
#--set operator.rollOutPods=true \
#--set cgroup.autoMount.enabled=false \
#--set cgroup.hostRoot=/sys/fs/cgroup \
#--set envoy.securityContext.capabilities.keepCapNetBindService=true > /home/mlkroot/cilium-1.17.0.yaml


##To add kube-prometheus monitoring integration:
##
##
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

#When performing cilium upgrade, include this required parameter:
#--set preflight.enabled=true

############### ROOK-CEPH HELM TEMPLATE GENERATION CODE ############################
# https://www.talos.dev/v1.9/kubernetes-guides/configuration/ceph-with-rook/
#Talos Kubernetes Cluster requires to label namespace rook-ceph with 'pod-security.kubernetes.io/enforce=privileged' for it to work
#
#helm template --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph > /home/mlkroot/rook-operator.yaml
#helm template --create-namespace --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster > /home/mlkroot/rook-cluster.yaml
