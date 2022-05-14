
resource "google_service_account" "bastion_agents" {
  account_id   = "${local.common_prefix}-bastion-agents"
  display_name = "${local.common_prefix}-bastion-agents"
  description  = "Service account for bastion agents"
}

# Allow user to access bastion agent by impersonating their service account 
data "google_iam_policy" "allow_access_to_bastion_agents" {

  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "user:shubydo777@gmail.com",
      # "serviceAccount:${google_service_account.bastion_agents.email}",
    ]
  }
  binding {
    role = "roles/compute.networkUser"

    members = [
      "user:shubydo777@gmail.com",
      # "serviceAccount:${google_service_account.bastion_agents.email}",
    ]
  }
  # binding {
  #   role = "roles/iam.osLogin"

  #   members = [
  #     "user:shubydo777@gmail.com",
  #     # "serviceAccount:${google_service_account.bastion_agents.email}",
  #   ]
  # }



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


resource "google_service_account_iam_policy" "allow_access_to_bastion_agents" {
  service_account_id = google_service_account.bastion_agents.id
  policy_data        = data.google_iam_policy.allow_access_to_bastion_agents.policy_data
}


locals {
  bastion_agent_permissions = [
    "roles/compute.osLogin",
    "roles/compute.osLoginAdmin",
    "roles/compute.instanceAdmin.v1",

  ]
}

resource "google_service_account_iam_member" "bastion_agent_permissions" {
  for_each           = toset(local.bastion_agent_permissions)
  service_account_id = google_service_account.bastion_agents.id
  role               = each.key
  member             = "serviceAccount:${google_service_account.bastion_agents.email}"
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
    # access_config {
    #   # nat_ip = google_compute_router_nat.nat.nat_ip_address
    # }
  }

  # metadata = {
  #   "enable-oslogin" : "TRUE"
  #   # "os-config" = "TRUE"
  # }

  tags   = ["ssh-enabled"]
  labels = local.default_labels
}

output "bastion_agents" {
  description = "Current configuration of bastion agents"
  value       = google_compute_instance.bastion_agents
  sensitive   = true
}
