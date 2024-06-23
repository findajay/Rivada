resource "azurerm_key_vault_secret" "secret" {
  key_vault_id = var.key_vault.id
  name         = var.name
  value        = var.value
}