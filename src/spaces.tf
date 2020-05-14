data "cloudfoundry_space" "space" {
  name = lower(var.CLOUD_FOUNDRY_SPACE)
  org  = data.cloudfoundry_org.org.id
}
