variable "organization" {
  type = map(string)
  default = {
    organization_name = ""
    organization_id   = ""
  organization_number = "" }
}

variable "service_account" {}

variable "billing_account" {}

provider "google" {
  impersonate_service_account = var.service_account

}
