locals {
  keyvault_name = "${var.component}-${var.env}-${var.name}"
}

resource "azurerm_key_vault" "vault" {
  name                       = substr("${local.keyvault_name}", 0, 24)
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  tenant_id                  = var.service_principal.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = false

  public_network_access_enabled = true
  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Allow" # var.env == "dev" ? "Allow" : "Deny"
    virtual_network_subnet_ids = [var.subnet.id]
  }

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "service_principal" {

  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = var.service_principal.tenant_id
  object_id    = var.service_principal.object_id

  key_permissions = [
    "List",
    "Get",
    "GetRotationPolicy",
    "Update",
    "Create",
    "Delete",
    "Purge"
  ]

  secret_permissions = [
    "List",
    "Get",
    "Set",
    "Delete",
    "Purge"
  ]

  certificate_permissions = [
    "List",
    "Get",
    "Update",
    "Create",
    "Delete",
    "Purge"
  ]
}
