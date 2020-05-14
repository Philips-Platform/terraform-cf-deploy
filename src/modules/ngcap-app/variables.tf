variable "app_name" {}
variable "space_id" {}
variable "app_memory" {}
variable "app_disk_quota" {}
variable "app_docker_image" {}
variable "app_services" {}
variable "app_domain" {}
variable "app_hostname" {}
variable "app_environment" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}
variable "stopped" {
  type    = bool
  default = false
}
