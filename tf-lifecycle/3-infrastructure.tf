########## Projects #############

variable "projects" {
  default = {
    "network_prod" = {
      project_name = "tf-net-prod-1"
      folder_name  = "tf-networking"
      "networks" = [
        {
          name = "tf-net-ext"
          subnet = [
            {
              name   = "tf-net-ext-sb1"
              cidr   = "10.100.10.0/24"
              region = "europe-central2" },
            {
              name   = "tf-net-ext-sb2"
              cidr   = "10.100.11.0/24"
              region = "europe-central2"
            },
            {
              name   = "tf-net-ext-sb3"
              cidr   = "10.100.12.0/24"
              region = "europe-west2"
            }
          ]
        },
        {
          name = "tf-net-int"
          subnet = [
            {
              name   = "tf-net-int-sb1"
              cidr   = "10.100.20.0/24"
              region = "europe-central2"
            },
             {
              name   = "tf-net-int-sb2"
              cidr   = "10.100.21.0/24"
              region = "europe-west1"
            }
          ]
      }]
    }
    "network_dev" = {
      project_name = "tf-net-dev-1"
      folder_name  = "tf-networking"
    }
    # "chatbot_a_prod" = {
    #   project_name = "tf-chatbot-a-prod"
    #   folder_name  = "tf-dept-a"
    # }

  }
}


########### Folders ################

resource "google_folder" "folder" {
  for_each     = toset([for key in var.projects : key.folder_name])
  display_name = each.value
  parent       = "organizations/${var.organization.organization_id}"
}


########## Projects ################

resource "random_id" "projects" {
  byte_length = 4
}

resource "google_project" "projects" {
  for_each            = var.projects
  name                = each.value.project_name
  project_id          = "${each.value.project_name}-${random_id.projects.hex}"
  billing_account     = var.billing_account
  auto_create_network = false
  folder_id           = google_folder.folder["${each.value.folder_name}"].id

}

resource "google_project_service" "project_services" {
  for_each = var.projects
  project  = google_project.projects["${each.key}"].project_id

  service            = "compute.googleapis.com"
  disable_on_destroy = false
}


########## Prod Networks ####################

resource "google_compute_network" "networks" {
  project                 = google_project.projects["network_prod"].project_id
  for_each                = toset([for key, value in var.projects.network_prod.networks : value.name])
  name                    = each.value
  auto_create_subnetworks = false
  mtu                     = 1460
}



locals {
  subnets = flatten([
    for networks in var.projects.network_prod.networks : [
      for subnet in networks.subnet : {
        network_name = networks.name,
        cidr = subnet.cidr
        subnet_name = subnet.name
        region = subnet.region
        }
        ]
        ])
}

locals {
  subnets_map = {
    for obj in local.subnets : "${obj.subnet_name}" => obj
  }
  }




resource "google_compute_subnetwork" "subnets" {
  project       = google_project.projects["network_prod"].project_id
  for_each      = local.subnets_map
  name          = each.value.subnet_name
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.networks["${each.value.network_name}"].id
}



############## Prod network firewall #####################

locals {
  ranges = [for net in var.projects.network_prod.networks : {
    net = net.name,
    cidr = net.subnet[*].cidr}]
}

locals {
  ranges_map = {
    for obj in local.ranges : "${obj.net}" => obj
    }
  }



resource "google_compute_firewall" "allow_internal" {
  project       = google_project.projects["network_prod"].project_id
  for_each = local.ranges_map
  name    = "tf-allow-internal-${each.key}"
  network = each.key
  #destination_ranges = each.value.cidr
  source_ranges = each.value.cidr

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

}

resource "google_compute_firewall" "allow_ssh" {
  project       = google_project.projects["network_prod"].project_id
  for_each = local.ranges_map
  name    = "tf-allow-ssh-${each.key}"
  network = each.key
  #destination_ranges = each.value.cidr
  source_ranges = each.value.cidr

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }


}
