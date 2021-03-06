variable "app_name" {}
variable "space_name" {}
variable "app_memory" {}
variable "app_disk_quota" {}
variable "app_docker_image" {}
variable "app_services" {
}
variable "app_domain" {
  type = list(string)
}
variable "app_stopped" {
  type    = bool
  default = false
}
variable "app_ports" {}
variable "app_hostname" {}
variable "app_environment" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}
variable "cups_services" {}
variable "org_name" {}
variable "health_check_http_endpoint" {
	type = string
	default = "/"
}

variable "health_check_type" {
	type = string
	default = "port"
}
