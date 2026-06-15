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

data "azurerm_image" "evok8s-image" {
  name                = var.TALOS_AMI_NAME
  resource_group_name = var.AZ_STORAGE_RG
}

# IPA CA Certificate Lookup
data "local_file" "evoidp_ca" {
  filename = "/etc/ipa/ca.crt"
}

#------------------------------------------------------
# AZURE LOAD BALANCER
#------------------------------------------------------
resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.TALOS_LB_NAME}-pip"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "this" {
  name                = var.TALOS_LB_NAME
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "controlplane_pool" {
  name            = "controlplane-backend-pool"
  loadbalancer_id = azurerm_lb.this.id
}

# --- Health Probes ---

resource "azurerm_lb_probe" "k8s_apiserver" {
  name                = "probe-k8s-apiserver"
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = "Tcp"
  port                = 6443
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "talos_apid" {
  name                = "probe-talos-apid"
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = "Tcp"
  port                = 50000
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "http" {
  name                = "probe-http"
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "https" {
  name                = "probe-https"
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = "Tcp"
  port                = 443
  interval_in_seconds = 15
  number_of_probes    = 2
}

# --- LB Rules  ---

resource "azurerm_lb_rule" "apiserver" {
  name                           = "rule-k8s-apiserver"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.controlplane_pool.id]
  probe_id                       = azurerm_lb_probe.k8s_apiserver.id
}

resource "azurerm_lb_rule" "apid" {
  name                           = "rule-talos-apid"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 50000
  backend_port                   = 50000
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.controlplane_pool.id]
  probe_id                       = azurerm_lb_probe.talos_apid.id
}

resource "azurerm_lb_rule" "httproute" {
  name                           = "rule-http"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.controlplane_pool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_lb_rule" "httpsroute" {
  name                           = "rule-https"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.controlplane_pool.id]
  probe_id                       = azurerm_lb_probe.https.id
}

#------------------------------------------------------
# Control Planes
#------------------------------------------------------
resource "azurerm_network_interface" "controlplane" {
  for_each = var.TALOS_CTRL_NODES

  name                = "${each.value}-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.admin_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "controlplane" {
  for_each = var.TALOS_CTRL_NODES

  network_interface_id      = azurerm_network_interface.controlplane[each.key].id
  network_security_group_id = var.cntrl_plane_sgr
}

resource "azurerm_network_interface_backend_address_pool_association" "controlplane" {
  for_each = var.TALOS_CTRL_NODES

  network_interface_id    = azurerm_network_interface.controlplane[each.key].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.controlplane_pool.id
}

resource "azurerm_linux_virtual_machine" "controlplane" {
  for_each = var.TALOS_CTRL_NODES

  name                  = each.value
  location              = var.rg_location
  resource_group_name   = var.rg_name
  size                  = var.TALOS_CTRL_INSTANCE_SIZE
  network_interface_ids = [azurerm_network_interface.controlplane[each.key].id]

  admin_username                  = var.CLOUD_USER
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.CLOUD_USER
    public_key = "${file("${var.PUBLIC_KEY_PAIR}")}"
  }

  source_image_id = data.azurerm_image.evok8s-image.id # Custom Talos image resource ID

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

#------------------------------------------------------
# Worker Nodes
#------------------------------------------------------
resource "azurerm_network_interface" "worker" {
  for_each = var.TALOS_WKLD_NODES

  name                = "${each.value.short_name}-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.admin_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "worker" {
  for_each = var.TALOS_WKLD_NODES

  network_interface_id      = azurerm_network_interface.worker[each.key].id
  network_security_group_id = var.worker_sgr
}

resource "azurerm_linux_virtual_machine" "worker" {
  for_each = var.TALOS_WKLD_NODES

  name                  = each.value.short_name
  location              = var.rg_location
  resource_group_name   = var.rg_name
  size                  = var.TALOS_WKLD_INSTANCE_SIZE
  network_interface_ids = [azurerm_network_interface.worker[each.key].id]

  admin_username                  = var.CLOUD_USER
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.CLOUD_USER
    public_key = "${file("${var.PUBLIC_KEY_PAIR}")}"
  }

  source_image_id = data.azurerm_image.evok8s-image.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_managed_disk" "extra_disk" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  name                 = "${each.value.short_name}-extra-disk"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.BASE_VOLUME_200

  tags = {
    managed-by   = "EvoCloud"
    attached-to  = each.value.short_name
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
  for_each = { for k, v in var.TALOS_WKLD_NODES : k => v if v.extra_volume }

  managed_disk_id    = azurerm_managed_disk.extra_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.worker[each.key].id
  lun                = index(keys(var.TALOS_WKLD_NODES), each.key)
  caching            = "ReadWrite"
}

#--------------------------------------------------
# Configuring Talos Kubernetes Cluster
#--------------------------------------------------
resource "talos_machine_secrets" "talos_vm" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  
  endpoints = [azurerm_public_ip.lb_pip.ip_address]
}

#-----------------------------------------------------
## Generate Talos Controlplane Machine Configuration
#-----------------------------------------------------
data "talos_machine_configuration" "talos_controlplane" {
  depends_on = [azurerm_linux_virtual_machine.controlplane]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${azurerm_public_ip.lb_pip.ip_address}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.talos_vm.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false

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
          nameservers = [var.idam_server_ip, var.idam_replica_ip]
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
              routes     = [
                {
                  network = "0.0.0.0/0"
                  gateway = cidrhost(var.admin_subnet_prefix, 1)
                  metric  = 1024
                }
              ]
            }
          ]
        }
        certSANs = concat(
          ["127.0.0.1", "localhost"],
          [azurerm_public_ip.lb_pip.ip_address]
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
            [azurerm_public_ip.lb_pip.ip_address]
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

resource "time_sleep" "timer" {
  depends_on      = [azurerm_network_interface_backend_address_pool_association.controlplane, data.talos_machine_configuration.talos_controlplane]
  create_duration = "20s"
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [time_sleep.timer]

  for_each                    = azurerm_linux_virtual_machine.controlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = each.value.private_ip_address
  node                        = each.value.private_ip_address
}

#-----------------------------------------------------
## Generate Talos Worker Machine Configuration
#-----------------------------------------------------
data "talos_machine_configuration" "talos_worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${azurerm_public_ip.lb_pip.ip_address}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.talos_vm.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        network = {
          nameservers = [var.idam_server_ip, var.idam_replica_ip]
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
              routes     = [
                {
                  network = "0.0.0.0/0"
                  gateway = cidrhost(var.admin_subnet_prefix, 1)
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
  depends_on = [
    data.talos_machine_configuration.talos_worker,
    azurerm_network_interface_backend_address_pool_association.controlplane,
    talos_machine_configuration_apply.controlplane
  ]

  for_each                    = azurerm_linux_virtual_machine.worker
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_worker.machine_configuration
  endpoint                    = each.value.private_ip_address
  node                        = each.value.private_ip_address
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
  node                 = azurerm_public_ip.lb_pip.ip_address
  endpoint             = azurerm_public_ip.lb_pip.ip_address
  timeouts             = { create = "5m" }
}

## Collecting kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap_cluster]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  node                 = azurerm_public_ip.lb_pip.ip_address
  endpoint             = azurerm_public_ip.lb_pip.ip_address
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
      ${var.ANSIBLE_DEBUG_FLAG ? "ANSIBLE_DEBUG=1" : ""} ANSIBLE_PIPELINING=True ansible-playbook --timeout 60 \
      /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/kubeapp-essentials.yml
      --forks 10
      --inventory-file 127.0.0.1,
      --user ${var.CLOUD_USER} --private-key ${var.PRIVATE_KEY_PAIR}
      --vault-password-file /home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/ansible-vault-pass.txt
      --ssh-common-args '-o 'StrictHostKeyChecking=no' -o 'ControlMaster=auto' -o 'ControlPersist=120s''
      --extra-vars 'ansible_secret=/home/${var.CLOUD_USER}/EVOCLOUD/Ansible/secret-vault/secret-store.yml cloud_user=${var.CLOUD_USER} idam_server_ip=${var.idam_server_ip} idam_short_hostname=${var.IDAM_SHORT_HOSTNAME} domain_tld=${var.DOMAIN_TLD} kube_cluster_name=${var.cluster_name} gtw_lb_ip=${azurerm_lb.this.private_ip_address} kubeapp_dir=/${var.CLOUD_USER}/kubeapps kubeconfig=/${var.CLOUD_USER}/kubeconfig/kubeconfig-${var.cluster_name}.yaml'
    EOF
    #Ansible logs
    environment = {
      ANSIBLE_LOG_PATH = "/${var.CLOUD_USER}/Logs/kubeapp-essentials-ansible.log"
    }
  }
}