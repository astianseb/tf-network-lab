# 1. create folder
# 2. create project
# 3. attach project to SharedPVC
# 4. add IAM roles


variable "departament_a" {
    default = {
        name = "dept-a"
        folder_name = "tf-fldr-dept-a"
        groups = [
            "group:gcp-developers@sebastiang.eu"
        ]
        projects = [
            "chatbot-prod",
   #         "chatbot-dev"
        ]
    }
}

variable "group_iam_roles" {
  type = list(string)
  default = [
    "roles/compute.instanceAdmin.v1"
  ]
}


########### Folder ################

resource "google_folder" "folder_dept_a" {
  display_name = var.departament_a.folder_name
  parent       = "organizations/${var.organization.organization_id}"
}


########## Projects ################

resource "random_id" "project_dept_a" {
  byte_length = 4
}

resource "google_project" "project_dept_a" {
  for_each            = toset([for project in var.departament_a.projects : "${var.departament_a.name}-${project}"])
  name                = each.value
  project_id          = "${each.value}-${random_id.project_dept_a.hex}"
  billing_account     = var.billing_account
  auto_create_network = false
  folder_id           = google_folder.folder_dept_a.id

}

resource "google_project_service" "project_services_dept_a" {
  for_each            = toset([for project in var.departament_a.projects : "${var.departament_a.name}-${project}"])
  project  = google_project.project_dept_a["${each.value}"].project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
############## Shared VPC ######################

resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = google_compute_shared_vpc_host_project.network_prod_host.id
  for_each            = google_project.project_dept_a
  service_project = each.value.project_id
}



############## IAM folder roles ################

resource "google_folder_iam_binding" "folder" {
  folder  = google_folder.folder_dept_a.id
  for_each = toset(var.group_iam_roles)
  role    = each.value

  members = var.departament_a.groups
}

