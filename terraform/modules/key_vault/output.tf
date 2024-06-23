output "id" {
  value = azurerm_key_vault.vault.id
  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]
}

output "name" {
  value = azurerm_key_vault.vault.name
  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]
}