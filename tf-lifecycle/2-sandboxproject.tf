# ########### Sandbox ############

# variable "sandbox_project_name" {
#   default = "tf-sandbox"
# }

# resource "random_id" "id" {
#   byte_length = 4
#   prefix      = "${var.sandbox_project_name}-"
# }

# resource "google_project" "sandbox" {
#   name                = var.sandbox_project_name
#   project_id          = random_id.id.hex
#   billing_account     = var.billing_account
#   auto_create_network = true
#   org_id              = "1098571864372"

# }

# resource "google_project_service" "service" {
#   for_each = toset([
#     "compute.googleapis.com",
#   ])

#   service            = each.key
#   project            = google_project.sandbox.project_id
#   disable_on_destroy = false
# }

