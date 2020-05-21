variable "CLOUD_FOUNDRY_USERNAME" {
  type = string
}
variable "CLOUD_FOUNDRY_PASSWORD" {
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
    "8b3ca926-d4cf-4d55-8dbd-4f8ede964e6b",
    "a6ca0dc6-8606-40ca-8f50-7b8f7380a741"
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
  default = "docker.na1.hsdp.io/client-ngcap_dev-deploy"
}
variable "DOCKER_REGISTRY_USERNAME" {
  type = string
}
variable "DOCKER_REGISTRY_PASSWORD" {
  type = string
}

variable "ngcap_cs_tag" {
  type = string
}
variable "ngcap_js_tag" {
  type = string
}

variable "ngcap_fhir_version" {
  type    = string
  default = "STU3"
}

variable "stop_apps" {
  type    = bool
  default = true
}


variable "build_tag" {
  type    = string
  default = "latest"
}
