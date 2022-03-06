# # Cloud Armor
# data "http" "ip" {
#   url = "https://ifconfig.me"
# }

# output "ip" {
#   value = data.http.ip.body
# }


# # Deny everything excecpt current IP
# resource "google_compute_security_policy" "deny_all_but_current_ip" {
#   name        = "deny-all-but-current-ip"
#   description = "Deny all except current IP"
#   rule {
#     action      = "allow"
#     description = "current IP"
#     priority    = 100

#     match {
#       versioned_expr = "SRC_IPS_V1"

#       config {
#         src_ip_ranges = [data.http.ip.body]
#       }
#     }
#   }

#   rule {
#     action   = "deny(403)"
#     priority = "2147483647"
#     match {
#       versioned_expr = "SRC_IPS_V1"
#       config {
#         src_ip_ranges = ["*"]
#       }
#     }
#     description = "default deny all rule"
#   }

# }

# # External HTTP(S) Load Balancer

