resource "google_compute_network" "vpc" {
  name                    = "${local.common_prefix}-vpc"
  auto_create_subnetworks = false
  # delete_default_routes_on_create = false
}

# Subnets for DB and build agents
resource "google_compute_subnetwork" "cloudsql" {
  name          = "${local.common_prefix}-cloudsql-subnet-${var.environment}-${var.region}"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_router" "router" {
  name    = "${local.common_prefix}-router"
  region  = google_compute_subnetwork.cloudsql.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.common_prefix}-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

}
