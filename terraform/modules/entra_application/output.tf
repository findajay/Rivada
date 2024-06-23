output "object_id" {
  value = azuread_application.app.object_id
}

output "principal_id" {
  value = azuread_application.app.object_id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "application_id" {
  value = azuread_application.app.application_id 
}

output "oauth2_permission_scope_ids" {
  value = azuread_application.app.oauth2_permission_scope_ids 
}
