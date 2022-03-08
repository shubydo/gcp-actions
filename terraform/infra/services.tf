locals {
  services = [
    "compute.googleapis.com",
    "cloudfunctions.googleapis.com",
  ]
}


# Services to enable for the project
resource "google_project_service" "project" {
  for_each = toset(local.services)
  service  = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}
