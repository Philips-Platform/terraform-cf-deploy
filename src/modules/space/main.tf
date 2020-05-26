resource "cloudfoundry_space" "space" {
  name       = lower(var.space_name)
  org        = data.cloudfoundry_org.org.id
  managers   = var.space_users
  developers = var.space_users
}
data "cloudfoundry_org" "org" {
  name = var.org_name
}
resource "cloudfoundry_space_users" "space" {
  space      = cloudfoundry_space.space.id
  managers   = var.space_users
  developers = var.space_users
}
