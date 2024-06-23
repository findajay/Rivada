data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name     = var.display_name
  identifier_uris  = var.identifier_uris
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  api {
    requested_access_token_version = 2
    known_client_applications      = var.api.known_client_applications
    dynamic "oauth2_permission_scope" {
      for_each = var.api.oauth2_permission_scopes
      content {
        admin_consent_description  = oauth2_permission_scope.value["admin_consent_description"]
        admin_consent_display_name = oauth2_permission_scope.value["admin_consent_display_name"]
        enabled                    = oauth2_permission_scope.value["enabled"]
        id                         = oauth2_permission_scope.value["id"]
        type                       = oauth2_permission_scope.value["type"]
        user_consent_description   = oauth2_permission_scope.value["user_consent_description"]
        user_consent_display_name  = oauth2_permission_scope.value["user_consent_display_name"]
        value                      = oauth2_permission_scope.value["value"]
      }
    }
  }

}
