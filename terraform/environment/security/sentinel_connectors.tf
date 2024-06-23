# Sentinel onboarding on log analytics workspace
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel_onboarding" {
 workspace_id = var.loganalytics_workspace_id
  customer_managed_key_enabled = false
}

# Sentinel connectors for threat detection and protection
# Enabling applicable connectors for workload in cloud 
resource "azurerm_sentinel_data_connector_azure_security_center" "az_security_center" {
  name                       = "azsecuritycenter-data-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "ms_cloud_app_security" {
  name                       = "ms-cloud-app-security-data-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
}

resource "azurerm_sentinel_data_connector_microsoft_threat_intelligence" "ms_threat_intelligence" {
  name                                         = "ms-threat-intelligence-data-connector"
  log_analytics_workspace_id                   = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  microsoft_emerging_threat_feed_lookback_date = "1970-01-01T00:00:00Z"
}

resource "azurerm_sentinel_watchlist" "az_sentinel_watchlist" {
  name                       = "sentinel-watchlist"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  display_name               = "Rivada sentinel watchlist"
  item_search_key            = "Key"
}
