data "google_service_account" "terraform" {
  account_id = "terraform"
}

# data "google_iam_policy" "terraform" {
#   binding {
#     role = "roles/iam.serviceAccountTokenCreator"
#     members = [
#       "serviceAccount:${data.google_service_account.terraform.email}",
#     ]
# }

# resource "google_service_account_iam_policy" "terraform" {
#   account = "${data.google_service_account.terraform.email}"
#   policy_data = data.google_iam_policy.terraform.policy_data
# }

resource "google_service_account" "bastion_agent" {
  account_id   = "${local.common_prefix}-bastion-agent"
  display_name = "${local.common_prefix}-bastion-agent"
  description  = "Service account for bastion agent"
}


# Allow terraform sa + users to access bastion agent by impersonating their service account 
data "google_iam_policy" "allow_access_to_bastion_agent" {

  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:${data.google_service_account.terraform.email}",
      # "serviceAccount:${google_service_account.bastion_agent.email}",
    ]
  }

  binding {
    role = "roles/iam.serviceAccountTokenCreator"

    members = [
      "serviceAccount:${data.google_service_account.terraform.email}",
      # "serviceAccount:${google_service_account.bastion_agent.email}",
    ]

  }

  # binding {
  #   role = "roles/iam.serviceAccountUser"

  #   members = [
  #     "user:shubydo777@gmail.com",
  #     # "serviceAccount:${google_service_account.bastion_agent.email}",
  #   ]
  # }
  # binding {
  #   role = "roles/compute.networkUser"

  #   members = [
  #     "user:shubydo777@gmail.com",
  #     # "serviceAccount:${google_service_account.bastion_agent.email}",
  #   ]
  # }
  # binding {
  #   role = "roles/iam.osLogin"

  #   members = [
  #     # "user:shubydo777@gmail.com",
  #     "serviceAccount:${google_service_account.bastion_agent.email}",
  #   ]
  # }



  # binding {
  #   role = "roles/iam.serviceAccountUser"

  #   members = [
  #     "user:shubydo777@gmail.com",
  #     # "serviceAccount:${google_service_account.bastion_agent.email}",
  #   ]
  # }
  #   binding {
  #     role = "roles/cloudsql.editor"

  #     members = [
  #       "serviceAccount:${google_service_account.bastion_agent.email}",
  #     ]
  #   }

  # binding {
  #   role = "roles/storage.viewer"
  #   members = [
  #     "serviceAccount:${google_service_account.bastion_agent.email}"
  #   ]
  # }

}

# resource "google_iam" "name" {

# }


resource "google_service_account_iam_policy" "allow_access_to_bastion_agent" {
  service_account_id = google_service_account.bastion_agent.id
  policy_data        = data.google_iam_policy.allow_access_to_bastion_agent.policy_data
}


locals {
  bastion_agent_permissions = [
    "roles/compute.osLogin",
    "roles/compute.osLoginAdmin",
    "roles/compute.instanceAdmin.v1",
  ]
}

data "google_iam_policy" "bastion_agent_permissions" {
  binding {
    role = "roles/compute.osLogin"
    members = [
      "serviceAccount:${google_service_account.bastion_agent.email}",
    ]
  }
  binding {
    role = "roles/compute.osLoginAdmin"
    members = [
      "serviceAccount:${google_service_account.bastion_agent.email}",
    ]
  }
  binding {
    role = "roles/compute.instanceAdmin.v1"
    members = [
      "serviceAccount:${google_service_account.bastion_agent.email}",
    ]
  }
}

resource "google_compute_instance_iam_policy" "bastion_agent_permissions" {
  instance_name = google_compute_instance.bastion_agent.name
  zone          = google_compute_instance.bastion_agent.zone
  policy_data   = data.google_iam_policy.bastion_agent_permissions.policy_data
}


resource "google_service_account_iam_binding" "bastion_agent" {
  service_account_id = google_service_account.bastion_agent.id
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.bastion_agent.email}"
  ]
}


# resource "google_service_account_iam_member" "bastion_agent_permissions" {
#   for_each           = toset(local.bastion_agent_permissions)
#   service_account_id = google_service_account.bastion_agent.id
#   role               = each.key
#   member             = "serviceAccount:${google_service_account.bastion_agent.email}"
# }



# resource "google_service_account_iam_binding" "name" {
#   service_account_id = google_service_account.bastion_agent.id
#   role               = "roles/compute.osLogin"
#   members = [
#     "serviceAccount:${google_service_account.bastion_agent.email}"
#   ]
# }

resource "google_compute_instance" "bastion_agent" {
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
    email  = google_service_account.bastion_agent.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.cloudsql.self_link
    # access_config {
    #   # nat_ip = google_compute_router_nat.nat.nat_ip_address
    # }
  }

  metadata = {
    "enable-oslogin" : "TRUE"
    # "os-config" = "TRUE"
  }

  tags   = ["ssh-enabled"]
  labels = local.default_labels
}

output "bastion_agent" {
  description = "Current configuration of bastion agent"
  value       = google_compute_instance.bastion_agent
  sensitive   = true
}
