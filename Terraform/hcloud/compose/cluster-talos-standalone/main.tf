#--------------------------------------------------
# EvoCloud Workstation
#--------------------------------------------------
locals {
  user_volume_patch = <<-EOF
    apiVersion: v1alpha1
    kind: UserVolumeConfig
    name: local-storage
    provisioning:
      diskSelector:
        match: disk.dev_path == '/dev/sdb'
      minSize: 150GB
    encryption:
      provider: luks2
      keys:
        - slot: 0
          nodeID: {}
  EOF
}

data "hcloud_image" "evok8s" {
  with_selector = "name=${var.TALOS_AMI_NAME}" #The Talos Machine Image must be tagged with the name label
  most_recent = true
}

resource "hcloud_firewall" "evok8s_wks_firewall" {
  name = "my-firewall"
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

resource "hcloud_server" "talos_ctrlplane" {
  for_each    = var.TALOS_CTRL_STANDALONE
  name        = format("%s", each.value)
  server_type = var.TALOS_CTRL_STANDALONE_SIZE
  location    = var.HCLOUD_REGION
  image       = data.hcloud_image.evok8s.id

  firewall_ids = [hcloud_firewall.evok8s_wks_firewall.id]

  # This gets you an public ipv4 primary ip
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  # Attach to private ipv4 ip
  network {
    network_id = var.dmz_subnet_id
    #There is a bug with Terraform 1.4+ which causes the network to be detached & attached on every apply. Set alias_ips = []
    alias_ips = [] #Bug: https://github.com/hetznercloud/terraform-provider-hcloud/issues/650#issuecomment-1497160625
  }
}

## Create and Attach an Extra Volume
resource "hcloud_volume" "extra_disk" {
  for_each    = var.TALOS_CTRL_STANDALONE

  name        = "${hcloud_server.talos_ctrlplane[each.key].name}-extra-volume"
  size        = var.BASE_VOLUME_200
  location    = hcloud_server.talos_ctrlplane[each.key].location
  labels = {
    "managed-by"  = "EvoCloud"
    "attached-to" = hcloud_server.talos_ctrlplane[each.key].name
  }
}

# HCLOUD_VOLUME_ATTACHMENT Resource
resource "hcloud_volume_attachment" "disk_attachment" {
  for_each  = var.TALOS_CTRL_STANDALONE

  volume_id = hcloud_volume.extra_disk[each.key].id
  server_id = hcloud_server.talos_ctrlplane[each.key].id
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
  endpoints = [for xvalue in hcloud_server.talos_ctrlplane : xvalue.ipv4_address]
  nodes = concat(
    [for xvalue in hcloud_server.talos_ctrlplane : xvalue.ipv4_address]
  )
}

## Generate the Controlplane configuration and instantiate the Talos Controlplane VMs
data "talos_machine_configuration" "talos_controlplane" {
  depends_on = [hcloud_server.talos_ctrlplane]

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_server.talos_ctrlplane["node01"].ipv4_address}:6443"
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
          hcloud_server.talos_ctrlplane["node01"].ipv4_address,
          one(hcloud_server.talos_ctrlplane["node01"].network[*].ip)
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
          extraMounts = [
            {
              destination = "/var/mnt/local-storage"
              type = "bind"
              source = "/var/mnt/local-storage"
              options = ["bind", "rshared", "rw"]
            }
          ]
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
            hcloud_server.talos_ctrlplane["node01"].ipv4_address,
            one(hcloud_server.talos_ctrlplane["node01"].network[*].ip)
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
          var.TALOS_EXTRA_MANIFESTS["kube-metric_server"]
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
                          --version 1.19.1 \
                          --namespace kube-system \
                          --set k8sServiceHost=localhost \
                          --set k8sServicePort=7445 \
                          --set operator.replicas=1 \
                          --set k8sClientRateLimit.qps=50 \
                          --set k8sClientRateLimit.burst=200 \
                          --set cluster.name=${var.cluster_name} \
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
              #DEPLOYING LOCAL PATH STORAGE
              ############################################
              #Reference: https://github.com/rancher/local-path-provisioner/tree/master/deploy/chart/local-path-provisioner
              apiVersion: v1
              kind: Namespace
              metadata:
                name: local-path-storage
                labels:
                  pod-security.kubernetes.io/enforce: privileged #Talos default PodSecurity configuration prevents execution of priviledged pods. Adding a label to the namespace will allow ceph to start
              ---
              #Dedicated service account for flux in local-path-storage namespace
              apiVersion: rbac.authorization.k8s.io/v1
              kind: ClusterRoleBinding
              metadata:
                name: flux-local-path-storage
              roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
              subjects:
              - kind: ServiceAccount
                name: flux-local-path-storage-sa
                namespace: local-path-storage
              ---
              apiVersion: v1
              kind: ServiceAccount
              metadata:
                name: flux-local-path-storage-sa
                namespace: local-path-storage
              ---
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: GitRepository
              metadata:
                name: local-path-storage-provisioner
                namespace: local-path-storage
              spec:
                interval: 24h
                url: https://github.com/rancher/local-path-provisioner.git
                ref:
                  branch: master
              ---
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: local-path-storage-provisioner
                namespace: local-path-storage
              spec:
                chart:
                  spec:
                    chart: deploy/chart/local-path-provisioner
                    sourceRef:
                      kind: GitRepository
                      name: local-path-storage-provisioner
                      namespace: local-path-storage
                serviceAccountName: flux-local-path-storage-sa
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
                  storageClass:
                    create: true
                    defaultClass: true
                    defaultVolumeType: hostPath
                    name: local-path-storage
                    reclaimPolicy: Delete
                  nodePathMap:
                    - node: DEFAULT_PATH_FOR_NON_LISTED_NODES
                      paths:
                        - /var/mnt/local-storage
              ---
              ############################################
              #DEPLOYING TOFU FLUX CONTROLLER
              ############################################
              #Tofu-repo helm repository object
              apiVersion: source.toolkit.fluxcd.io/v1
              kind: HelmRepository
              metadata:
                name: tofu-controller-stable
                namespace: flux-system
              spec:
                interval: 24h
                url: https://flux-iac.github.io/tofu-controller
              ---
              #Tofu-deployment logic
              apiVersion: helm.toolkit.fluxcd.io/v2
              kind: HelmRelease
              metadata:
                name: tofu-controller
                namespace: flux-system
              spec:
                chart:
                  spec:
                    chart: tofu-controller
                    sourceRef:
                      kind: HelmRepository
                      name: tofu-controller-stable
                    version: ">=0.16.0-rc.8"
                interval: 1h0s
                releaseName: tofu-controller
                targetNamespace: flux-system
                install:
                  crds: Create
                  remediation:
                    retries: 3
                upgrade:
                  crds: CreateReplace
                  remediation:
                    retries: 3
                driftDetection:
                  mode: enabled
                values:
                  runner:
                    grpc:
                      maxMessageSize: 30
                  replicaCount: 1
                  resources:
                    requests:
                      cpu: 500m
                      memory: 256Mi
                    limits:
                      memory: 1Gi
                  caCertValidityDuration: 24h
                  certRotationCheckFrequency: 60m
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
                  - name: local-path-storage-provisioner
                    namespace: local-path-storage
                chart:
                  spec:
                    chart: headlamp
                    sourceRef:
                      kind: HelmRepository
                      name: headlamp-release
                    version: "0.38.*"
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
        ]
      }
    }),
    local.user_volume_patch,
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [data.talos_machine_configuration.talos_controlplane]

  for_each                    = hcloud_server.talos_ctrlplane
  client_configuration        = talos_machine_secrets.talos_vm.client_configuration
  machine_configuration_input = data.talos_machine_configuration.talos_controlplane.machine_configuration
  endpoint                    = each.value.ipv4_address
  node                        = each.value.ipv4_address
}

## Start the bootstraping of the Talos Kubernetes Cluster
resource "talos_machine_bootstrap" "bootstrap_cluster" {
  depends_on           = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = hcloud_server.talos_ctrlplane["node01"].ipv4_address
  node                 = hcloud_server.talos_ctrlplane["node01"].ipv4_address
}

## Collect the Talos Kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [
    talos_machine_bootstrap.bootstrap_cluster
  ]

  client_configuration = talos_machine_secrets.talos_vm.client_configuration
  endpoint             = hcloud_server.talos_ctrlplane["node01"].ipv4_address
  node                 = hcloud_server.talos_ctrlplane["node01"].ipv4_address
}

#--------------------------------------------------
# Write out Kubeconfig and Talosconfig to a file
#--------------------------------------------------
resource "local_file" "talos_kubeconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/${var.CLOUD_USER}/kubeconfig/kubeconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw}
  EOF
}

resource "local_file" "talos_talosconfig_file" {
  depends_on  = [talos_cluster_kubeconfig.kubeconfig]

  filename    = "/${var.CLOUD_USER}/talosconfig/talosconfig-${var.cluster_name}.yaml"
  directory_permission = "0740"
  file_permission      = "0640"
  content     = <<-EOF
    ${data.talos_client_configuration.talosconfig.talos_config}
  EOF
}