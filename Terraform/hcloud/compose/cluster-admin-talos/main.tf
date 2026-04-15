#--------------------------------------------------
# EvoCloud Admin Cluster
#--------------------------------------------------

# Locals for better variable manipulation
locals {
  trusted_roots_patch = <<-EOF
    apiVersion: v1alpha1
    kind: TrustedRootsConfig
    name: evoidp-ca-certificate
    certificates: |-
      ${replace(data.local_file.evoidp_ca.content, "\n", "\n  ")}
  EOF
}

data "hcloud_image" "evok8s" {
  with_selector = "name=${var.TALOS_AMI_NAME}" #The Talos Machine Image must be tagged with the name label
  most_recent = true
}

# IPA CA Certificate Lookup
data "local_file" "evoidp_ca" {
  filename = "/etc/ipa/ca.crt"
}

#---------------------------------------------------------
# Optional Firewall Rule - Not in use in private networks
#---------------------------------------------------------
resource "hcloud_firewall" "evok8s_firewall_rule" {
  name = "evok8s-wks-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "50000-50001"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0"
    ]
  }
}

#--------------------------------------------------
# Loadbalancer VMs
#--------------------------------------------------
resource "hcloud_load_balancer" "this" {
  name               = var.TALOS_LB_NAME
  load_balancer_type = "lb11"
  location           = var.HCLOUD_REGION

  labels = {
      managed-by  = "EvoCloud"
  }
}

#-----------------------------------------------------
# Hcloud Load Balancer Endpoints
#-----------------------------------------------------
resource "hcloud_load_balancer_service" "apiserver" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
  proxyprotocol    = false
}

resource "hcloud_load_balancer_service" "apid" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "tcp"
  listen_port      = 50000
  destination_port = 50000
  proxyprotocol    = false
}

resource "hcloud_load_balancer_service" "httproute" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80
  proxyprotocol    = false
}

resource "hcloud_load_balancer_service" "httpsroute" {
  load_balancer_id = hcloud_load_balancer.this.id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
  proxyprotocol    = false
}

#-----------------------------------------------------
# Hcloud Load Balancer Host Targets
#-----------------------------------------------------
resource "hcloud_load_balancer_target" "this" {
  depends_on = [hcloud_server.controlplane]

  load_balancer_id = hcloud_load_balancer.this.id
  type             = "label_selector" #label_selector | server | ip
  label_selector   = "role=controlplane"
  use_private_ip   = true #use the private IP to connect to target VMs
}
#-----------------------------------------------------
# Attach Hcloud Load Balancer to Target Network
#-----------------------------------------------------
resource "hcloud_load_balancer_network" "this" {
  load_balancer_id  = hcloud_load_balancer.this.id
  network_id        = var.vpc_id
}

#-----------------------------------------------------
# Hcloud Control plane nodes
#-----------------------------------------------------
resource "hcloud_server" "controlplane" {
  for_each = var.TALOS_CTRL_NODES

  name        = format("%s", each.value)
  server_type = var.TALOS_CTRL_INSTANCE_SIZE
  image       = data.hcloud_image.evok8s.id
  location    = var.HCLOUD_REGION

  network {
    network_id = var.admin_subnet_id
    #ip         = each.value.cluster_data.private_ip
    #There is a bug with Terraform 1.4+ which causes the network to be detached & attached on every apply. Set alias_ips = []
    alias_ips = [] #Bug: https://github.com/hetznercloud/terraform-provider-hcloud/issues/650#issuecomment-1497160625
  }

  #If this block is not defined, two primary (ipv4 & ipv6) ips are auto generated.
  public_net {
    #ipv4_enabled = each.value.cluster_data.enable_public_ip ? true  : false
    ipv6_enabled = false
    ipv4_enabled = false
  }

  # Firewall attached to the VM_SERVER
  # On Hetzner if ipv4_enabled = false, then firewall is not used
  firewall_ids = [hcloud_firewall.evok8s_firewall_rule.id]

  # no space separator in the key or value
  labels = {
    managed-by  = "EvoCloud"
    role        = "controlplane"
  }
}

#-----------------------------------------------------
# Hcloud Worker nodes
#----------------------------------------------------
resource "hcloud_server" "worker" {
  for_each = var.TALOS_WKLD_NODES

  name        = format("%s", each.value.short_name)
  server_type = var.TALOS_WKLD_INSTANCE_SIZE
  image       = data.hcloud_image.evok8s.id
  location    = var.HCLOUD_REGION

  network {
    network_id = var.admin_subnet_id
    #There is a bug with Terraform 1.4+ which causes the network to be detached & attached on every apply. Set alias_ips = []
    alias_ips = [] #Bug: https://github.com/hetznercloud/terraform-provider-hcloud/issues/650#issuecomment-1497160625
  }

  #If this block is not defined, two primary (ipv4 & ipv6) ips are auto generated.
  public_net {
    ipv6_enabled = false
    ipv4_enabled = false
  }

  # Firewall attached to the VM_SERVER
  firewall_ids = [hcloud_firewall.evok8s_firewall_rule.id]

  # no space separator in the key or value
  labels = {
    managed-by  = "EvoCloud"
    role        = "worker"
  }
}

##Talos Worker VMs Extra disk creation and attachment
resource "hcloud_volume" "extra_disk" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  name      = "${hcloud_server.worker[each.key].name}-extra-volume"
  size      = var.BASE_VOLUME_200
  location  = hcloud_server.worker[each.key].location
  labels = {
    "managed-by"  = "EvoCloud"
    "attached-to" = hcloud_server.worker[each.key].name
  }
}

# HCLOUD_VOLUME_ATTACHMENT Resource
resource "hcloud_volume_attachment" "disk_attachment" {
  for_each  = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  volume_id = hcloud_volume.extra_disk[each.key].id
  server_id = hcloud_server.worker[each.key].id
  automount = false #This attaches a raw disk to the server
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
  endpoints = [hcloud_load_balancer.this.ipv4]
}

#-----------------------------------------------------
## Generate Talos Controlplane Machine Configuration
#-----------------------------------------------------
data "talos_machine_configuration" "talos_controlplane" {
  depends_on = [hcloud_server.controlplane]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_load_balancer.this.ipv4}:6443"
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
          "fs.inotify.max_user_watches" = "1048576"
          "fs.inotify.max_user_instances" = "8192"
          "net.ipv4.neigh.default.gc_thresh1" = "4096"
          "net.ipv4.neigh.default.gc_thresh2" = "8192"
          "net.ipv4.neigh.default.gc_thresh3" = "16384"
          "net.ipv4.tcp_slow_start_after_idle" = "0"
          "user.max_user_namespaces" = "11255"
        }
        network = {
          nameservers = [var.idam_server_ip, var.idam_replica_ip, var.HCLOUD_METADATA_NS]
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
              routes     = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.HCLOUD_GATEWAY
                  metric  = 1024
                }
              ]
            }
          ]
        }
        certSANs = concat(
          ["127.0.0.1", "localhost"],
          [hcloud_load_balancer.this.ipv4]
        )
        kubelet = {
          extraArgs = {
            cloud-provider = "external"
            rotate-server-certificates = true
          }
          extraConfig = {
            serializeImagePulls = false
            maxParallelImagePulls = 5
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
          certSANs = concat(
            ["127.0.0.1", "localhost"],
            [hcloud_load_balancer.this.ipv4]
          )
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
          var.TALOS_EXTRA_MANIFESTS["kube-metric_server"]
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
                          --version 1.19.2 \
                          --namespace kube-system \
                          --set operator.replicas=2 \
                          --set k8sServiceHost=localhost \
                          --set k8sServicePort=7445 \
                          --set k8sClientRateLimit.qps=50 \
                          --set k8sClientRateLimit.burst=200 \
                          --set cluster.name=${var.cluster_name} \
                          --set cluster.id=1 \
                          --set rollOutCiliumPods=true \
                          --set l2announcements.enabled=true \
                          --set envoyConfig.enabled=true \
                          --set gatewayAPI.enabled=true \
                          --set gatewayAPI.enableAppProtocol=true \
                          --set gatewayAPI.enableAlpn=true \
                          --set devices="{eth0,e+}" \
                          --set-string gatewayAPI.gatewayClass.create=true \
                          --set externalIPs.enabled=true \
                          --set ipam.mode=kubernetes \
                          --set kubeProxyReplacement=true \
                          --set operator.rollOutPods=true \
                          --set cgroup.autoMount.enabled=false \
                          --set cgroup.hostRoot=/sys/fs/cgroup \
                          --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
                          --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
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
                          helm repo add kubevela https://kubevela.github.io/charts
                          helm repo update
                          helm upgrade --install kubevela kubevela/vela-core \
                            --namespace vela-system \
                            --create-namespace \
                            --version 1.10.6 \
                            --wait
                    restartPolicy: OnFailure
                    serviceAccount: vela-install
                    serviceAccountName: vela-install
            EOT
          },
          {
            name     = "kubevela-UI-deploy"
            contents = <<-EOT
              ---
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: kubevela-ui-install
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes CRB after 24 hours (86400 seconds)
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: vela-ui-install
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: vela-ui-install
                namespace: kube-system
                annotations:
                  ttl.after.delete: "86400s" #Automatically deletes SA after 24 hours (86400 seconds)
              ---
              apiVersion: batch/v1
              kind: Job
              metadata:
                name: vela-ui-addon-deployer
                namespace: kube-system
              spec:
                backoffLimit: 10
                template:
                  metadata:
                    labels:
                      job: vela-ui-deployment
                  spec:
                    containers:
                    - name: velacli
                      image: ghcr.io/evocloud-dev/oci/kubevela-cli:1.10.6-amd64
                      command:
                        - "vela"
                      args:
                        - "addon"
                        - "enable"
                        - "velaux"
                        - "serviceType=NodePort"
                        - "nodePort=30000"
                    restartPolicy: OnFailure
                    serviceAccount: vela-ui-install
                    serviceAccountName: vela-ui-install
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
              #https://github.com/controlplaneio-fluxcd/charts/tree/main/charts/flux-operator
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
                            --version 0.45.1 \
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
                  version: "2.8.x"
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
                    version: "v1.19.*"
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
                    version: "v1.19.*"
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
              #Dedicated service account for headlamp
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
                namespace: kube-system
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-headlamp-sa
                namespace: kube-system
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: headlamp-release
                namespace: kube-system
              spec:
                interval: 24h
                url: https://kubernetes-sigs.github.io/headlamp
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: headlamp
                namespace: kube-system
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
                    version: "0.41.*"
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
                    baseURL: "/ui"
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
                    version: "82.*"
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
                    version: "2.5.*"
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
              # https://github.com/kubescape/helm-charts/tree/main/charts/kubescape-operator
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
                    version: "1.30.*"
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
                #https://github.com/kubescape/helm-charts/blob/main/charts/kubescape-operator/values.yaml
                values:
                  clusterName: evo-cluster-mgr
                  capabilities:
                    continuousScan: disable

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
                    version: "2.19.*"
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
                    version: "1.17.*"
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
                    version: "0.32.*"
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
                            --version 3.6.0 \
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
    local.trusted_roots_patch,
  ]
}

## Give time for controlplane nodes readiness
resource "time_sleep" "timer" {
  depends_on = [hcloud_load_balancer_target.this, data.talos_machine_configuration.talos_controlplane]

  create_duration = "20s"
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [time_sleep.timer]

  for_each                    = hcloud_server.controlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = one(each.value.network[*].ip)
  node                        = one(each.value.network[*].ip)
}

#-----------------------------------------------------
## Generate Talos Worker Machine Configuration
#-----------------------------------------------------
data "talos_machine_configuration" "talos_worker" {
  #depends_on = [hcloud_server.worker]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_load_balancer.this.ipv4}:6443"
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
          nameservers = [var.idam_server_ip, var.idam_replica_ip, var.HCLOUD_METADATA_NS]
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
              routes     = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.HCLOUD_GATEWAY
                }
              ]
            }
          ]
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
    local.trusted_roots_patch,
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [data.talos_machine_configuration.talos_worker, hcloud_load_balancer_target.this, talos_machine_configuration_apply.controlplane]

  for_each                    = hcloud_server.worker
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_worker.machine_configuration
  endpoint                    = one(each.value.network[*].ip)
  node                        = one(each.value.network[*].ip)
}

#---------------------------------------------------------
# Start the bootstraping of the Talos Kubernetes Cluster
#---------------------------------------------------------
## Avoid race condition between talos_machine_configuration_apply and bootstrapping
resource "time_sleep" "timer2" {
  create_duration = "20s"
  depends_on = [talos_machine_configuration_apply.controlplane]
}

resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [time_sleep.timer2]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  node                 = hcloud_load_balancer.this.ipv4
  endpoint             = hcloud_load_balancer.this.ipv4
  timeouts             = { create = "5m" }
}

## Collecting kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap_cluster]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  node                 = hcloud_load_balancer.this.ipv4
  endpoint             = hcloud_load_balancer.this.ipv4
}

resource "local_file" "talos_kubeconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/${var.CLOUD_USER}/kubeconfig/kubeconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw}
  EOF
}

## Collecting Talosconfig
resource "local_file" "talos_talosconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/${var.CLOUD_USER}/talosconfig/talosconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${data.talos_client_configuration.talosconfig.talos_config}
  EOF
}

## Validate Kubernetes endpoint is up
#data "http" "k8s_health_check" {
#  depends_on     = [ local_file.talos_kubeconfig_file ]

#  url            = "https://${hcloud_load_balancer.this.ipv4}:6443/version"
#  insecure       = true
#  retry {
#    attempts     = 60
#    min_delay_ms = 5000
#    max_delay_ms = 5000
#  }
#}
#--------------------------------------------------
# Wait for Kubernetes to fully deploy
#--------------------------------------------------
resource "time_sleep" "timer3" {
  create_duration = "120s"
  depends_on = [local_file.talos_kubeconfig_file]
}

#--------------------------------------------------
# Ansible Configuration Management Code
#--------------------------------------------------
resource "terraform_data" "redeploy_cluster_post_configuration" {
  input = var.cluster_post_config_revision
}

resource "terraform_data" "cluster_post_configuration" {
  depends_on = [time_sleep.timer3]

  lifecycle {
    replace_triggered_by = [terraform_data.redeploy_cluster_post_configuration]
  }

  provisioner "local-exec" {
    command = <<EOF
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/kubeapp-essentials.yml --forks 10 --inventory-file 127.0.0.1, --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR} --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s'' --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml cloud_user=${var.CLOUD_USER} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} kube_cluster_name=${var.cluster_name} gtw_lb_ip=${hcloud_load_balancer_network.this.ip} kubeapp_dir=/${var.CLOUD_USER}/kubeapps kubeconfig=/${var.CLOUD_USER}/kubeconfig/kubeconfig-${var.cluster_name}.yaml'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/${var.CLOUD_USER}/Logs/kubeapp-essentials-ansible.log"
    }
  }
}