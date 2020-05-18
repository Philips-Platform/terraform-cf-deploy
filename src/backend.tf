terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Philips-platform"

    workspaces {
      name = "terraform-cf-deploy"
    }
  }
}
