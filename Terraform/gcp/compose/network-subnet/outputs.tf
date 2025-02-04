#--------------------------------------------------
# Expose Subnet Information
#--------------------------------------------------

output "dmz_subnet_name" {
  value = google_compute_subnetwork.dmz_subnet.name
}

output "dmz_subnet_id" {
  value = google_compute_subnetwork.dmz_subnet.id
}

output "admin_subnet_name" {
  value = google_compute_subnetwork.admin_subnet.name
}

output "admin_subnet_id" {
  value = google_compute_subnetwork.admin_subnet.id
}

output "backend_subnet_name" {
  value = google_compute_subnetwork.backend_subnet.name
}

output "backend_subnet_id" {
  value = google_compute_subnetwork.backend_subnet.id
}