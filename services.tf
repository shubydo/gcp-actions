locals {
  services = [
    "compute.googleapis.com",
    # "workflows.googleapis.com",
  ]
}


# Services to enable for the project
resource "google_project_service" "project" {
  for_each = toset(local.services)
  project  = "shubydo"
  service  = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
