data "cloudfoundry_domain" "ngcap_domain" {
  for_each = var.app_domain
  name     = each.value
}


resource "cloudfoundry_route" "ngcap_route" {

  for_each = data.cloudfoundry_domain.ngcap_domain
  domain   = each.value.id
  space    = var.space_id
  hostname = var.app_hostname
}

resource "cloudfoundry_app" "ngcap_instance" {
  name         = var.app_name
  space        = var.space_id
  memory       = var.app_memory
  disk_quota   = var.app_disk_quota
  docker_image = var.app_docker_image
  environment  = var.app_environment

  dynamic "service_binding" {
    for_each = [for s in var.app_services : {
      service_instance = s.service_instance
    }]
    content {
      service_instance = service_binding.value.service_instance
    }
  }

  dynamic "routes" {
    for_each = [for s in cloudfoundry_route.ngcap_route : {
      id = s.id
    }]
    content {
      route = routes.value.id
    }

  }

  timeout = 180
  stopped = var.stopped

  docker_credentials = {
    username = var.docker_registry_username
    password = var.docker_registry_password
  }


}

