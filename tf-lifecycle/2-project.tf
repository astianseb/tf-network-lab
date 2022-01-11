variable "folders_to_create" {
  type = list(string)
  default = [
    "tf-networking",
    "tf-dept-a",
    "tf-dept-b"
  ]
}

resource "google_folder" "tf_networking" {
  for_each     = toset(var.folders_to_create)
  display_name = each.value
  parent       = "organizations/${var.organization.organization_id}"
}

########### Sandbox ############

variable "project_name" {
  default = "tf-sandbox"
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "google_project" "project" {
  name                = var.project_name
  project_id          = random_id.id.hex
  billing_account     = var.billing_account
  auto_create_network = true
  org_id              = "1098571864372"

}

resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
  ])

  service            = each.key
  project            = google_project.project.project_id
  disable_on_destroy = false
}

resource "google_org_policy_policy" "sandbox_policy_1" {
  name   = "${var.organization.organization_id}/constraints/compute.vmExternalIpAccess"
  parent = "projects/${google_project.project.project_id}"

  spec {
    rules {
      allow_all = "TRUE"
    }
  }
}




# resource "random_id" "id" {
#   byte_length = 4
#   prefix      = "${var.project_name}-"
# }

# resource "google_project" "project" {
#   name                = var.project_name
#   project_id          = random_id.id.hex
#   billing_account     = var.billing_account
#   auto_create_network = false
#   org_id     = "1098571864372"

# }

# resource "google_project_service" "service" {
#   for_each = toset([
#     "compute.googleapis.com",
#     "iap.googleapis.com"
#   ])

#   service            = each.key
#   project            = google_project.project.project_id
#   disable_on_destroy = false
# }