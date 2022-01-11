resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "google_project" "bootstrap_project" {
  name                = var.project_name
  project_id          = random_id.id.hex
  billing_account     = var.billing_account
  auto_create_network = false

}

resource "google_project_service" "service" {
  for_each = toset([
    "orgpolicy.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com"

  ])

  service            = each.key
  project            = google_project.bootstrap_project.project_id
  disable_on_destroy = false
}

