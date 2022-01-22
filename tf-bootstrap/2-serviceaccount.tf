variable "org_iam_roles" {
  type = list(string)
  default = [
    "roles/resourcemanager.organizationAdmin",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.folderCreator",
    "roles/compute.xpnAdmin"
  ]
}

variable "sa_iam_roles" {
  type = list(string)
  default = [
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser"
  ]
}


resource "google_project_default_service_accounts" "default_sa" {
  project = google_project.bootstrap_project.project_id
  action  = "DELETE"
}

resource "google_service_account" "tf_service_account" {
  project      = google_project.bootstrap_project.project_id
  account_id   = "sg-tf-sa"
  display_name = "SG Service Account for Terraform"
}

resource "google_billing_account_iam_member" "sa-ba-viewer" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.tf_service_account.email}"
}

resource "google_service_account_iam_member" "sa_iam" {
  service_account_id = google_service_account.tf_service_account.name
  for_each           = toset(var.sa_iam_roles)
  role               = each.value
  member             = "user:me@sebastiang.eu"
}

resource "google_organization_iam_member" "org_admin" {
  org_id   = var.organization.organization_id
  for_each = toset(var.org_iam_roles)
  role     = each.value
  member   = "serviceAccount:${google_service_account.tf_service_account.email}"
}

output "service_account" {
  value = google_service_account.tf_service_account.email
}