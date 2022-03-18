locals {
  common_prefix = "jack-${var.environment}"

  default_labels = {
    terraform  = true
    project_id = var.project_id
  }
}
