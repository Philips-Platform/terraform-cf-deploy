output "service_instance_id" {
  value = "${cloudfoundry_service_instance.service_instance.id}"
}


output "service_key_credentials" {
  value = cloudfoundry_service_key.service_instance_key.credentials
}
