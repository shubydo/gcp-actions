locals {
  common_prefix = "jack-${var.environment}"

  client_ip = data.http.client_ip.body

  default_labels = {
    terraform   = true
    project_id  = var.project_id
    environment = var.environment
    region      = var.region
  }
}

data "http" "client_ip" {
  url = "https://ifconfig.me"
}

output "local_ip" {
  value = local.client_ip
}
