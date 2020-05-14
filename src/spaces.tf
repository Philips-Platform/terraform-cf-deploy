data "cloudfoundry_space" "space" {
  name = lower(var.CLOUD_FOUNDRY_SPACE)
  org  = data.cloudfoundry_org.org.id
}


data "cloudfoundry_space_users" "space" {
  space      = cloudfoundry_space.space.id
  managers   = var.CLOUD_FOUNDRY_SPACE_USERS
  developers = var.CLOUD_FOUNDRY_SPACE_USERS
}
