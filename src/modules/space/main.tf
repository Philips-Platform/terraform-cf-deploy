resource "cloudfoundry_space" "space" {
  name = lower(var.space_name)
  org  = data.cloudfoundry_org.org.id
}
data "cloudfoundry_org" "org" {
  name = var.org_name
}
