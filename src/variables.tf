variable "CLOUD_FOUNDRY_USERNAME" {
  type = string
}
variable "CLOUD_FOUNDRY_PASSWORD" {
  type = string
}
variable "CLOUD_FOUNDRY_API" {
  type = string 
}
variable "CLOUD_FOUNDRY_ORG" {
  type = string
}
variable "CLOUD_FOUNDRY_SPACE" {
  type = string
}

variable "CLOUD_FOUNDRY_INTERNAL_DOMAIN" {
  type    = string
  default = "apps.internal"
}

variable "CLOUD_FOUNDRY_SPACE_USERS" {
  type = list

  default = [
    "f0dd6ea7-9c7d-48fa-b179-7771ebf6a8b7"
  ]
}

variable "CLOUD_FOUNDRY_EXTERNAL_DOMAIN" {
  type    = string
  default = "us-east.philips-healthsuite.com"
}

variable "memory" {
  default = "512"
}

variable "disk_quota" {
  default = "1024"
}

variable "postgres_service_plan" {
  type = string
}
variable "rabbitmq_service_plan" {
  type = string
}
variable "redis_service_plan" {
  type = string
}


variable "DOCKER_REGISTRY_NAMESPACE" {
  type    = string
  default = ""
}
variable "DOCKER_REGISTRY_USERNAME" {
  type = string
}
variable "DOCKER_REGISTRY_PASSWORD" {
  type = string
}

variable "stop_apps" {
  type    = bool
  default = true
}


variable "build_tag" {
  type    = string
  default = "latest"
}
