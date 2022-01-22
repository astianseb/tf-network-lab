resource "google_compute_shared_vpc_host_project" "network_prod_host" {
  project = google_project.projects["network_prod"].project_id
}
