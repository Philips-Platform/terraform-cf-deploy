
resource "cloudfoundry_network_policy" "app-policy" {

	dynamic "policy" {
		for_each = [for p in var.app_network_policies: {
			source = p.source,
			destination = p.destination,
			portRange = p.portRange
		}]
		content {
			source_app = policy.value.source
                        destination_app = policy.value.destination
			port = policy.value.portRange
		}


	}


	dynamic "policy" {
		for_each = [for p in var.app_network_policies: {
			source = p.source,
			destination = p.destination,
			portRange = p.portRange
		}]
		content {
			source_app = policy.value.destination
                        destination_app = policy.value.source
			port = policy.value.portRange			
                }
	}



}
