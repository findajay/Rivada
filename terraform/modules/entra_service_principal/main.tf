data "azuread_client_config" "current" {}

resource "azuread_service_principal" "principal" {
  client_id                    = var.application.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}
