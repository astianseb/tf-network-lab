variable "organization" {
  type = map(string)
  default = {
    organization_id   = ""
    organization_name = ""
  }
}
variable "billing_account" {}
variable "project_name" {}

provider "google" {

}

