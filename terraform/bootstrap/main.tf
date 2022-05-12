locals {
  # Project wide services to enable.
  project_services = [
    "compute.googleapis.com",
  ]
}

# API Services
resource "google_project_service" "service" {
  for_each = toset(local.project_services)
  service  = each.key
}

# Terraform State bucket. See notes in README.md and backend.tf
resource "google_storage_bucket" "terraform_state" {
  name                        = var.bucket
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = local.default_labels
}

