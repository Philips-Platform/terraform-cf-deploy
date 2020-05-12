data "cloudfoundry_service" "service" {
  name = var.service_name
}


resource "cloudfoundry_service_instance" "service_instance" {
  name         = var.service_instance_name
  space        = var.space_id
  service_plan = data.cloudfoundry_service.service.service_plans[var.service_plan]
  json_params  = var.service_params

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

