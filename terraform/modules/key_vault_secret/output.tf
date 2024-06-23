output "key_vault_secret_id" {
  value = azurerm_key_vault_secret.secret.id
}

output "key_vault_secret_content_type" {
  value = azurerm_key_vault_secret.secret.content_type
}

output "key_vault_secret_resource_id" {
  value = azurerm_key_vault_secret.secret.resource_id
}

output "key_vault_secret_value" {
  value = azurerm_key_vault_secret.secret.value
}

output "key_vault_secret_resource_version_id" {
  value = azurerm_key_vault_secret.secret.resource_versionless_id
}

output "key_vault_secret_tags" {
  value = azurerm_key_vault_secret.secret.tags
}

output "key_vault_secret_versionless_id" {
  value = azurerm_key_vault_secret.secret.versionless_id
}

output "key_vault_secret_not_before_date" {
  value = azurerm_key_vault_secret.secret.not_before_date
}

output "key_vault_secret_expiration_date" {
  value = azurerm_key_vault_secret.secret.expiration_date
}
