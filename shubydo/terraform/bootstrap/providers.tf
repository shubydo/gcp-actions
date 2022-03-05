provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "client_config" {
  provider = "google"
}

# data "project" "project_info" {
#   project_id = google.project
# }


