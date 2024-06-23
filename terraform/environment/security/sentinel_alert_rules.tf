# microsoft security incident rules for different products 
resource "azurerm_sentinel_alert_rule_ms_security_incident" "sentinel_alert_rule_app" {
  name                       = "app-ms-security-incident-alert-rule"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  product_filter             = "Microsoft Cloud App Security"
  display_name               = "sentinel alert rule for cloud apps"
  severity_filter            = ["High"]
}

resource "azurerm_sentinel_alert_rule_ms_security_incident" "sentinel_alert_rule_threat" {
  name                       = "threat-ms-security-incident-alert-rule"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  product_filter             = "Microsoft Defender Advanced Threat Protection"
  display_name               = "sentinel alert rule for Advanced Threat Protection"
  severity_filter            = ["High"]
}

# Sentinel threat intelligence rule
data "azurerm_sentinel_alert_rule_template" "sentinel_threat_intell_template" {
  display_name               = "(Preview) Microsoft Defender Threat Intelligence Analytics"
  log_analytics_workspace_id = azurerm_log_analytics_solution.la_workspace_securityfree.workspace_resource_id
}

resource "azurerm_sentinel_alert_rule_threat_intelligence" "sentinel_threat_intell_rule" {
  name                       = "sentinel-threat-intell-rule"
  log_analytics_workspace_id = azurerm_log_analytics_solution.la_workspace_securityfree.workspace_resource_id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.sentinel_threat_intell_template.name
}
