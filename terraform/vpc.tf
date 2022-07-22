resource "google_compute_network" "vpc" {
  name                    = "${local.common_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "build_agents" {
  name          = "${local.common_prefix}-build-agents-subnet"
  ip_cidr_range = "10.0.1.0/28"
  network       = google_compute_network.vpc.self_link
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
resource "google_compute_router" "router" {
  name    = "${local.common_prefix}-router"
  region  = google_compute_subnetwork.build_agents.region
  network = google_compute_network.vpc.id
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

resource "google_compute_instance" "build_agents" {
  name         = "${local.common_prefix}-build-agent"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.build_agents.self_link
    # access_config {

    # }
  }


  labels = local.default_labels
}
