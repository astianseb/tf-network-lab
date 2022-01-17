# resource "google_org_policy_policy" "primary" {
#   name   = "${var.organization.organization_id}/policies/gcp.detailedAuditLoggingMode"
#   parent = "organizations/${var.organization.organization_id}"

#   spec {
#     reset = true
#   }
# }

# resource "google_org_policy_policy" "vmExternalIpAccess" {
#   name   = "organizations/${var.organization.organization_id}/policies/compute.vmExternalIpAccess"
#   parent = "organizations/${var.organization.organization_id}"

#   spec {
#       rules {
#         deny_all = "FALSE"
#       }
#   }
# }

