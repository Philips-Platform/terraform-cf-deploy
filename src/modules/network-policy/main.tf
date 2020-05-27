data "cloudfoundry_org" "org" {
  name = var.org_name
}
data "cloudfoundry_space" "space" {
  name = lower(var.space_name)
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_app" "first_app" {
    name_or_id = var.first_app_name
    space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "second_app" {
    name_or_id = var.second_app_name
    space      = data.cloudfoundry_space.space.id
}



resource "cloudfoundry_network_policy" "app-policy" {

	policy {
		source_app = data.cloudfoundry_app.first_app.id
		destination_app = data.cloudfoundry_app.second_app.id
		port = var.port_range
	}


	policy {
		source_app = data.cloudfoundry_app.second_app.id
		destination_app = data.cloudfoundry_app.first_app.id
		port = var.port_range
	}


}
