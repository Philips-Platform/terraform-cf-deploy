output "app_instance_id" {
  value = cloudfoundry_app.instance.id
}

output "service_instances" {
  depends_on = [
    data.cloudfoundry_service_instance.service_instance,
    data.cloudfoundry_service_key.service_instance_key
  ]
  value = {
    for service in data.cloudfoundry_service_instance.service_instance :
    service.name => service.id
  }


  description = "services_map"
}
output "service_key_credentials" {
  depends_on = [
    data.cloudfoundry_service_key.service_instance_key
  ]
  value = {
    for service in data.cloudfoundry_service_key.service_instance_key :
    service.name => service.credentials
  }
  description = "services_credentials"
}
