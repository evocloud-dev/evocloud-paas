#--------------------------------------------------
# Expose Gateway Router Information
#--------------------------------------------------

output "vpc_gateway_name" {
  value = google_compute_router.vpc_internet_gateway.name
}

output "vpc_gateway_id" {
  value = google_compute_router.vpc_internet_gateway.id
}

output "vpc_nat_gateway_name" {
  value = google_compute_router_nat.vpc_nat_gateway.name
}

output "vpc_nat_gateway_id" {
  value = google_compute_router_nat.vpc_nat_gateway.id
}