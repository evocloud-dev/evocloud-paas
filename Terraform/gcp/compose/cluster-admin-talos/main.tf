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

  name        = var.TALOS_AMI_NAME
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
################################################################################
## Talos Controlplane VMs: Generate and apply configs on controlplane nodes
################################################################################
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
            google_compute_address.talos_vip.address,
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
                          --version 1.17.4 \
                          --namespace kube-system \
                          --set k8sServiceHost=localhost \
                          --set k8sServicePort=7445 \
                          --set k8sClientRateLimit.qps=50 \
                          --set k8sClientRateLimit.burst=200 \
                          --set cluster.name=cluster-manager \
                          --set cluster.id=0 \
                          --set rollOutCiliumPods=true \
                          --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
                          --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
                          --set l2announcements.enabled=true \
                          --set envoyConfig.enabled=true \
                          --set gatewayAPI.enabled=true \
                          --set gatewayAPI.enableAppProtocol=true \
                          --set gatewayAPI.enableAlpn=true \
                          --set-string gatewayAPI.gatewayClass.create=true \
                          --set externalIPs.enabled=true \
                          --set hubble.relay.enabled=true \
                          --set hubble.ui.enabled=true \
                          --set hubble.ui.rollOutPods=true \
                          --set ipam.mode=kubernetes \
                          --set kubeProxyReplacement=true \
                          --set maglev.tableSize=65521 \
                          --set loadBalancer.algorithm=maglev \
                          --set operator.rollOutPods=true \
                          --set cgroup.autoMount.enabled=false \
                          --set cgroup.hostRoot=/sys/fs/cgroup \
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
                            --version 0.21.0 \
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
                  fluxcd.controlplane.io/reconcileTimeout: "15m"
              spec:
                distribution:
                  version: "2.x"
                  registry: "ghcr.io/fluxcd"
                  artifact: "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
                components:
                  - source-controller
                  - kustomize-controller
                  - helm-controller
                  - notification-controller
                  - image-reflector-controller
                  - image-automation-controller
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
                chart:
                  spec:
                    chart: headlamp
                    sourceRef:
                      kind: HelmRepository
                      name: headlamp-release
                    version: "0.31.*"
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
                    version: "72.*"
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
              #https://opencost.io/docs/configuration/gcp
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
                    version: "2.1.*"
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
                chart:
                  spec:
                    chart: kubescape-operator
                    sourceRef:
                      kind: HelmRepository
                      name: kubescape-release
                    version: "1.27.*"
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
                  capabilities:
                    continuousScan: enable

              ---
              ############################################
              #DEPLOYING KEDA
              ############################################
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
                chart:
                  spec:
                    chart: dapr
                    sourceRef:
                      kind: HelmRepository
                      name: dapr-release
                    version: "1.15.*"
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
                            --version 3.4.1 \
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
  depends_on = [data.talos_machine_configuration.talos_controlplane]

  for_each                    = google_compute_instance.talos_ctrlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = each.value.network_interface[0].network_ip
  node                        = each.value.network_interface[0].network_ip
}
################################################################################
## Talos Worker VMs: Generate and apply configs on worker nodes
################################################################################
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
################################################################################
## Start the bootstraping of the Talos Kubernetes Cluster
################################################################################
resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
  node                 = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
  timeouts             = {
    creates = "5m"
  }
}

## Collect the Talos Kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [
    talos_machine_bootstrap.bootstrap_cluster,
  ]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
  node                 = google_compute_instance.talos_ctrlplane["node01"].network_interface[0].network_ip
}

## Check whether the Talos Kubernetes Cluster is in a healthy state
#data "talos_cluster_health" "cluster_health" {
#  depends_on = [talos_machine_bootstrap.bootstrap_cluster]

#  skip_kubernetes_checks  = false
#  control_plane_nodes     = [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip]
#  worker_nodes            = [for xvalue in google_compute_instance.talos_workload : xvalue.network_interface[0].network_ip]
#  endpoints               = [for xvalue in google_compute_instance.talos_ctrlplane : xvalue.network_interface[0].network_ip]
#  client_configuration    = talos_machine_secrets.talos_vm.client_configuration
#  timeouts                = { read = "15m" }
#}

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

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_cluster_post_configuration" {
  input = var.cluster_post_config_revision
}

resource "terraform_data" "cluster_post_configuration" {
  depends_on = [local_file.talos_kubeconfig_file]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_cluster_post_configuration]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/kubeapps-admin-talos.yml --forks 10 --inventory-file 127.0.0.1, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml cloud_user=${var.CLOUD_USER} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} kube_cluster_name=${var.cluster_name} ingress_lb_ip=${google_compute_address.ingress_lb_ip.address}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/Logs/cluster_post_configuration-ansible.log"
    }
  }
}

resource "terraform_data" "redeploy_kubeapp_gateway" {
  input = var.kubeapp_gateway_revision
}

resource "terraform_data" "kubeapp_gateway" {
  depends_on = [terraform_data.cluster_post_configuration]

  #Uncomment below if we want to run Triggers when VM ID changes
  #triggers_replace = [google_compute_instance.idam_server]
  #Uncomment below if we want to run Triggers on Revision number increase
  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_kubeapp_gateway]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/kubeapp-gateway-endpoint.yml --forks 10 --inventory-file 127.0.0.1, --user ${var.CLOUD_USER} --private-key /etc/pki/tls/gcp-evocloud.pem --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml cloud_user=${var.CLOUD_USER} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} kube_cluster_name=${var.cluster_name} kubeapp_shortname=evomon kubeapp_namespace=monitoring kubeapp_backend_svc=kube-promstack-stack-grafana kubeapp_backend_svc_port=80 ingress_lb_ip=${google_compute_address.ingress_lb_ip.address}'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/home/${var.CLOUD_USER}/EVOCLOUD/Logs/kubeapp_gateway-ansible.log"
    }
  }
}

############### CILIUM HELM TEMPLATE GENERATION CODE ############################
#Documentation: https://docs.cilium.io/en/stable/
#Parameter options: https://docs.cilium.io/en/stable/cmdref/cilium-agent/
#helm repo add cilium https://helm.cilium.io/
#
##To add kube-prometheus monitoring integration:
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
