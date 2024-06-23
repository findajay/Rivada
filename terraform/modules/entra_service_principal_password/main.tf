resource "azuread_service_principal_password" "password" {
  display_name         = var.display_name
  service_principal_id = var.service_principal.object_id
  end_date_relative    = var.end_date_relative
}
