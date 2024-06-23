resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id = var.key_vault.id
  tenant_id    = var.service_principal.tenant_id
  object_id    = var.service_principal.principal_id

  key_permissions         = var.key_permissions
  secret_permissions      = var.secret_permissions
  certificate_permissions = var.certificate_permissions
}
