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

