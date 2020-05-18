terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Philips-platform"

    workspaces {
      name = "${var.workspace_name}"
    }
  }
}
