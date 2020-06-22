data "cloudfoundry_space" "space" {
  name = lower(var.space_name)
  org  = data.cloudfoundry_org.org.id
}
data "cloudfoundry_org" "org" {
  name = var.org_name
}
data "cloudfoundry_domain" "domain" {
  for_each = toset(var.app_domain)
  name     = each.value
}
data "cloudfoundry_service_instance" "service_instance" {
  for_each   = { for key, value in var.app_services : key => value }
  name_or_id = each.key
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_service_key" "service_instance_key" {
  for_each         = { for key, value in var.app_services : key => value }
  name             = each.value
  service_instance = data.cloudfoundry_service_instance.service_instance[each.key].id
}

data "cloudfoundry_user_provided_service" "cups_instance" {
  count = length(var.cups_services)
  name  = var.cups_services[count.index]
  space = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "route" {

  for_each = data.cloudfoundry_domain.domain
  domain   = each.value.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.app_hostname
}

resource "cloudfoundry_app" "instance" {
  name         = var.app_name
  space        = data.cloudfoundry_space.space.id
  memory       = var.app_memory
  disk_quota   = var.app_disk_quota
  docker_image = var.app_docker_image
  environment  = var.app_environment
  ports        = toset(var.app_ports)

  dynamic "service_binding" {
    for_each = [for s in data.cloudfoundry_service_instance.service_instance : {
      service_instance = s.id
    }]
    content {
      service_instance = service_binding.value.service_instance
    }
  }

  dynamic "service_binding" {
    for_each = [for s in data.cloudfoundry_user_provided_service.cups_instance : {
      service_instance = s.id
    }]
    content {
      service_instance = service_binding.value.service_instance
    }
  }

  dynamic "routes" {
    for_each = [for s in cloudfoundry_route.route : {
      id = s.id

    }]
    content {
      route = routes.value.id
    }

  }
  timeout = 180
  stopped = var.app_stopped
  health_check_http_endpoint = var.health_check_http_endpoint
  health_check_type = var.health_check_type



  docker_credentials = {
    username = var.docker_registry_username
    password = var.docker_registry_password
  }


}
