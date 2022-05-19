# Create service account that bastion Compute Engine instance(s)
resource "google_service_account" "bastion_agent" {
  account_id   = "${local.common_prefix}-bastion-agent"
  display_name = "${local.common_prefix}-bastion-agent"
  description  = "Service account for bastion agent"
}

# Allow bastion agent(s) to access DB and control login permissions of users
# IAP tunneling: is used to authenticate and finely grain users access and permissions to the bastion agent(s)
# Link: https://cloud.google.com/iap/docs/authentication-howto

locals {
  bastion_agent_permissions = [
    "roles/compute.osLogin",
    "roles/compute.osLoginAdmin",
    "roles/compute.instanceAdmin.v1",
    "roles/iap.tunnelInstances.accessViaIAP"
  ]
}

data "google_iam_policy" "bastion_agent_permissions" {
  binding {
    role = "roles/compute.osLogin"
    members = [
      "serviceAccount:${google_service_account.bastion_agent.email}",
    ]
  }
  # binding {
  #   role = "roles/compute.osAdminLogin"
  #   members = [
  #     "serviceAccount:${google_service_account.bastion_agent.email}",
  #   ]
  # }
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


# Allow users to assume service account
data "google_service_account" "terraform" {
  account_id = "terraform"
}

locals {
  bastion_agent_impersonation_permissions = [
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.securityAdmin",
    "roles/compute.admin"
  ]
}
resource "google_service_account_iam_binding" "bastion_agent_user" {
  for_each           = toset(local.bastion_agent_impersonation_permissions)
  service_account_id = google_service_account.bastion_agent.id
  role               = each.key
  members = [
    "serviceAccount:${data.google_service_account.terraform.email}",
  ]
}

# resource "google_iap_tunnel_instance_iam_member" "instance" {
#   provider   = "google-beta"
#   instance   = google_compute_instance.bastion_agent.name
#   zone       = var.zone
#   role       = "roles/iap.tunnelResourceAccessor"
#   member     = "user:ericstumbo@student.purdueglobal.edu"
#   depends_on = [google_compute_instance.default]
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
