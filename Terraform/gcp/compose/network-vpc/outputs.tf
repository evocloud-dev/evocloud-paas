#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------

output "main_vpc_id" {
  value = google_compute_network.main.id
}

output "main_vpc_name" {
  value = google_compute_network.main.name
}