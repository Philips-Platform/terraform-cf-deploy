output "space_id" {
  depends_on = [
    cloudfoundry_space_users.space
  ]
  value = cloudfoundry_space.space.id
}
