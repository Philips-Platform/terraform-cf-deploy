provider "cloudfoundry" {
  api_url             = "https://api.cloud.pcftest.com"
  user                = var.CLOUD_FOUNDRY_USERNAME
  password            = var.CLOUD_FOUNDRY_PASSWORD
  skip_ssl_validation = true
}
