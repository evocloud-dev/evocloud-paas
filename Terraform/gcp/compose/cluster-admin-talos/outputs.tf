#--------------------------------------------------
# Expose EvoTalos Kubernetes Cluster Information
#--------------------------------------------------

output "kubeconfig" {
  description = "The generated kubeconfig"
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

# Retrieve the Talos Client Configuration of the Talos Kubernetes Cluster
output "talos_client_configuration" {
  description = "The generated talos_client_configuration"
  value     = data.talos_client_configuration.talosconfig.client_configuration
  sensitive = true
}

# Retrieve the Talos Configuration in case you would like to interact with the `talosctl`
output "talosconfig" {
  description = "The generated talosconfig"
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

# Retrieve Talos Machine Configuration for Controlplane
output "talos_controlplane_config" {
  description = "Talos Controlplane Machine Configuration"
  value = data.talos_machine_configuration.talos_controlplane
  sensitive = true
}

# Retrieve Talos Machine Configuration for Worker
output "talos_worker_config" {
  description = "Talos Worker Machine Configuration"
  value = data.talos_machine_configuration.talos_worker
  sensitive = true
}

# Retrieve Talos Load-balancer IP Address
output "ingress_lb_ip" {
  description = "Talos Load-balancer IP Address"
  value = google_compute_instance.talos_loadbalancer["node01"].network_interface[0].network_ip
  sensitive = true
}

# Retrieve Gateway Loadbalancer IP Address
output "gateway_vip" {
  description = "Gateway LoadBalancer IP"
  value = google_compute_address.gateway_vip.address
  sensitive = true
}