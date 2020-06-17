provider "cloudfoundry" {
  api_url             = var.CLOUD_FOUNDRY_API
  user                = var.CLOUD_FOUNDRY_USERNAME
  password            = var.CLOUD_FOUNDRY_PASSWORD
  skip_ssl_validation = true
}
