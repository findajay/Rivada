resource "azurerm_storage_account" "static_asset_store" {
  name                      = "${local.component_name}${var.environment}store"
  resource_group_name       = azurerm_resource_group.rg_services.name
  location                  = azurerm_resource_group.rg_services.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

}

resource "azurerm_cdn_profile" "asset_store_cdn_profile" {
  name                = "${local.component_name}-${var.environment}-cdn-profile"
  location            = azurerm_resource_group.rg_services.location
  resource_group_name = azurerm_resource_group.rg_services.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "asset_store_cdn_endpoint" {
  name                = "${local.component_name}-${var.environment}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.asset_store_cdn_profile.name
  location            = azurerm_resource_group.rg_services.location
  resource_group_name = azurerm_resource_group.rg_services.name

  origin {
    name      = "assetsstoreorigin"
    host_name = azurerm_storage_account.static_asset_store.primary_blob_host
  }
}

resource "azurerm_dns_cname_record" "asset_cdn_endpoint_record" {
  name                = "assets"
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg_services.name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.asset_store_cdn_endpoint.id
}

resource "azurerm_cdn_endpoint_custom_domain" "asset_cdn_endpoint_customdomain" {
  name            = "assets-cdn-endpoint-domain"
  cdn_endpoint_id = azurerm_cdn_endpoint.asset_store_cdn_endpoint.id
  host_name       = "${azurerm_dns_cname_record.asset_cdn_endpoint_record.name}.${azurerm_private_dns_zone.dns_zone.name}"

  cdn_managed_https {
    certificate_type = "Shared"
    protocol_type    = "IPBased"
    tls_version      = "None"
  }

}

resource "azurerm_storage_container" "rivada_app_store" {
  name                  = "dashboard"
  storage_account_name  = azurerm_storage_account.static_asset_store.name
  container_access_type = "blob"
}

resource "azurerm_storage_container" "rivada_videos_store" {
  name                  = "videos"
  storage_account_name  = azurerm_storage_account.static_asset_store.name
  container_access_type = "blob"
}

