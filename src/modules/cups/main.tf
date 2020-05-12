resource "cloudfoundry_user_provided_service" "cups_instance" {
  name             = var.cups_instance_name
  space            = var.space_id
  syslog_drain_url = var.syslog_drain_url
}
