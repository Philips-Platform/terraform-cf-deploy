variable "app_name" {}
variable "space_name" {}
variable "org_name" {}
variable "app_memory" {} 
variable "app_disk_quota" {} 
variable "app_internal_domain" {} 
variable "app_external_domain" {} 
variable "app_hostbase" {} 
variable "app_stopped" {
        type = bool
        default = false
}
