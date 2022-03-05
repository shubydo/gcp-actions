provider "google" {
  project = var.project_id
  region  = var.region
}


# Create backend GCS bucket
terraform {
  backend "gcs" {
    bucket = var.bucket
    prefix = "terraform-state"
  }
}
