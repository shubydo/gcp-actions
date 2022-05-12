
resource "google_service_account" "bastion_agents" {
  account_id   = "${local.common_prefix}-bastion-agents"
  display_name = "${local.common_prefix}-bastion-agents"
  # name        = "${local.common_prefix}-bastion-agents-service-account"
  description = "Service account for bastion agents"

  # labels      = local.default_labels

}

data "google_iam_policy" "bastion_agents" {

  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "user:shubydo777@gmail.com",
      # "serviceAccount:${google_service_account.bastion_agents.email}",
    ]
  }

  # binding {
  #   role = "roles/iam.serviceAccountUser"

  #   members = [
  #     "user:shubydo777@gmail.com",
  #     # "serviceAccount:${google_service_account.bastion_agents.email}",
  #   ]
  # }
  #   binding {
  #     role = "roles/cloudsql.editor"

  #     members = [
  #       "serviceAccount:${google_service_account.bastion_agents.email}",
  #     ]
  #   }

  # binding {
  #   role = "roles/storage.viewer"
  #   members = [
  #     "serviceAccount:${google_service_account.bastion_agents.email}"
  #   ]
  # }

}


resource "google_service_account_iam_policy" "bastion_agents" {
  service_account_id = google_service_account.bastion_agents.id
  policy_data        = data.google_iam_policy.bastion_agents.policy_data

}

resource "google_compute_instance" "bastion_agents" {
  name                      = "${local.common_prefix}-bastion-agent"
  machine_type              = "f1-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      # size  = 10
      # type  = "pd-standard"
    }
  }

  service_account {
    # email  = "terraform@shubydo.iam.gserviceaccount.com"
    email  = google_service_account.bastion_agents.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.cloudsql.self_link
    access_config {
      # nat_ip = google_compute_router_nat.nat.nat_ip_address
    }
  }

  metadata = {
    "enable-oslogin" : "TRUE"
    # "os-config" = "TRUE"
  }

  tags   = ["ssh-enabled"]
  labels = local.default_labels
}




# OLD bastion AGENTS subnet
# resource "google_compute_subnetwork" "bastion_agents" {
#   name          = "${local.common_prefix}-bastion-agents-subnet"
#   ip_cidr_range = "10.0.1.0/28"
#   network       = google_compute_network.vpc.self_link
#   log_config {
#     aggregation_interval = "INTERVAL_5_SEC"
#     flow_sampling        = 0.5
#     metadata             = "INCLUDE_ALL_METADATA"
#   }
# }


output "bastion_agents" {
  description = "Current configuration of bastion agents"
  value       = google_compute_instance.bastion_agents
  sensitive   = true
}
