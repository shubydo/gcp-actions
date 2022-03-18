# Setup the root directory of where the source code will be stored.
locals {
  functions_dir           = "${path.module}/../../functions"
  functions_artifacts_dir = "${path.module}/../../function_artifacts"

  functions = {
    helloworld = {
      name        = "helloworld"
      entry_point = "HelloWorld"
    }
    helloworld2 = {
      name        = "helloworld2"
      entry_point = "HelloWorld"
    }
  }
}

# Zip up our code so that we can store it for deployment.
data "archive_file" "function_artifact" {
  for_each    = local.functions
  type        = "zip"
  source_dir  = "${local.functions_dir}/${each.key}"
  output_path = "${local.functions_artifacts_dir}/${each.key}.zip"
}


resource "random_id" "bucket_suffix" {
  byte_length = 5
}

# This bucket will host the zipped files.
resource "google_storage_bucket" "function_artifacts" {
  name                        = "${var.project_id}-function-artifacts-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true

  labels = local.default_labels
}

# # Add the zipped file to the bucket.
resource "google_storage_bucket_object" "function_artifact" {
  # Use an MD5 here. If there's no changes to the source code, this won't change either.
  # We can avoid unnecessary redeployments by validating the code is unchanged, and forcing
  # a redeployment when it has!
  for_each = local.functions
  name     = "${each.key}/${data.archive_file.function_artifact[each.key].output_md5}.zip"
  bucket   = google_storage_bucket.function_artifacts.name
  source   = data.archive_file.function_artifact[each.key].output_path
}

# # The cloud function resource.
resource "google_cloudfunctions_function" "function" {
  for_each            = local.functions
  available_memory_mb = "128"
  entry_point         = each.value.entry_point
  # ingress_settings    = "ALLOW_ALL"

  name                  = each.value.name
  project               = var.project_id
  region                = var.region
  runtime               = "go116"
  service_account_email = google_service_account.function[each.key].email
  timeout               = 20
  trigger_http          = true
  source_archive_bucket = google_storage_bucket.function_artifacts.name
  source_archive_object = google_storage_bucket_object.function_artifact[each.key].name
}

# IAM Configuration. This allows unauthenticated, public access to the function.
# Change this if you require more control here.
resource "google_cloudfunctions_function_iam_member" "invoker" {
  for_each       = local.functions
  project        = google_cloudfunctions_function.function[each.key].project
  region         = google_cloudfunctions_function.function[each.key].region
  cloud_function = google_cloudfunctions_function.function[each.key].name

  role   = "roles/cloudfunctions.invoker"
  member = "user:shubydo777@gmail.com"
}

# This is the service account in which the function will act as.
resource "google_service_account" "function" {
  for_each     = local.functions
  account_id   = each.value.name
  description  = "Controls the workflow for the cloud pipeline"
  display_name = each.value.name
  project      = var.project_id
}
