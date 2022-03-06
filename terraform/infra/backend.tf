terraform {
  backend "gcs" {
    bucket = "shubydo-terraform-state"
    prefix = "infra"
  }
}


