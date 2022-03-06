# When bootstrapping a new project, the lines in this file should be commented out
# See notes in the README.md file for more information.

# terraform {
#   backend "gcs" {
#     bucket = "<REPLACE_ME>" # GCS bucket name. Ex: myproj-terraform-state
#     prefix = "<REPLACE_ME>" # Prefix to store state for resources: Ex: "bootstrap" or "myfolder/bootstrap-stuff"
#   }
# }

# terraform init -backend-config="bucket=<MY_BUCKET>" -backend-config="prefix=<MY_PREFIX>"
# Ex: terraform init -backend-config="bucket=myproj-terraform-state" -backend-config="prefix=bootstrap"
terraform {
  backend "gcs" {
    prefix = "bootstrap"
  }
}
