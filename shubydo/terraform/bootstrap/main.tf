resource "google_storage_bucket" "terraform_state" {
  name                        = var.state_bucket_name
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = local.default_labels
}

