output "id" {
  value = azurerm_container_group.container_groups.id
}

output "ip_address" {
  value = azurerm_container_group.container_groups.ip_address
}

output "fqdn" {
  value = azurerm_container_group.container_groups.fqdn
}

output "identity" {
  value = azurerm_container_group.container_groups.identity
}
