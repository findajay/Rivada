
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "la-${local.component_name}-${var.environment}"
  location            = azurerm_resource_group.rg_infra.location
  resource_group_name = azurerm_resource_group.rg_infra.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "application_insights" {
  source = "../modules/application_insights"

  name            = "ai"
  env             = var.environment
  component       = local.component_name
  la_workspace_id = azurerm_log_analytics_workspace.workspace.id
  resource_group  = azurerm_resource_group.rg_infra
}

resource "azurerm_monitor_diagnostic_setting" "diagnos_blue_container_groups" {
  name                       = "${local.component_name}-${var.environment}-diagnostics"
  target_resource_id         = module.blue_container_groups.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "diagnos_green_container_groups" {
  name                       = "${local.component_name}-${var.environment}-diagnostics1"
  target_resource_id         = module.green_container_groups.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_action_group" "monitor_action_group" {
  name                = "action-group-${local.component_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_infra.name
  short_name          = substr("ag${local.component_name}-${var.environment}", 0, 12)
  enabled             = true

  arm_role_receiver {
    name                    = "armroleaction"
    role_id                 = "194ae4cb-b126-40b2-bd5b-6091b380977d" #security administrator 
    use_common_alert_schema = true
  }

  dynamic "email_receiver" {
    for_each = coalesce(var.email_receivers, {})
    content {
      name          = email_receiver.value["name"]
      email_address = email_receiver.value["email_address"]
    }
  }

  # A logic app has been setup for recieving webhooks, it listens to alert metadata and send it to communication channels after transformation. 
  dynamic "webhook_receiver" {
    for_each = var.webhook_receiver_url != null ? [1] : []
    content {
      name                    = "azmonitoralertprocessor"
      service_uri             = var.webhook_receiver_url
      use_common_alert_schema = true
    }
  }

}

resource "azurerm_monitor_smart_detector_alert_rule" "performance_smart_alert_rule" {
  name                = "performance-smart-alert-rule"
  resource_group_name = azurerm_resource_group.rg_infra.name
  severity            = "Sev1"
  scope_resource_ids  = [module.application_insights.app_id]
  frequency           = "PT24H"
  detector_type       = "RequestPerformanceDegradationDetector"
  throttling_duration = "PT2H"
  enabled             = true
  description         = "Notifies about degraded performance"

  action_group {
    ids = [azurerm_monitor_action_group.monitor_action_group.id]
  }
}

resource "azurerm_monitor_smart_detector_alert_rule" "memory_leak_smart_alert_rule" {
  name                = "memory_leak-smart-alert-rule"
  resource_group_name = azurerm_resource_group.rg_infra.name
  severity            = "Sev0"
  scope_resource_ids  = [module.application_insights.app_id]
  frequency           = "PT24H"
  detector_type       = "MemoryLeakDetector"
  throttling_duration = "PT2H"
  enabled             = true
  description         = "Notifies about Memory Leak"

  action_group {
    ids = [azurerm_monitor_action_group.monitor_action_group.id]
  }
}

resource "azurerm_monitor_smart_detector_alert_rule" "anomoly_smart_alert_rule" {
  name                = "anomoly-smart-alert-rule"
  resource_group_name = azurerm_resource_group.rg_infra.name
  severity            = "Sev0"
  scope_resource_ids  = [module.application_insights.app_id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
  throttling_duration = "PT2H"
  enabled             = true
  description         = "Notifies about anomoly/crash detection"

  action_group {
    ids = [azurerm_monitor_action_group.monitor_action_group.id]
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health_alert_rule" {
  name                = "service-health-alert-rule"
  resource_group_name = azurerm_resource_group.rg_infra.name
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "This alert rule tracks health of service and notify action group."

  criteria {
    resource_id       = module.blue_container_groups.id
    category          = "ResourceHealth"
    resource_provider = "Microsoft.ContainerInstance"
  }

  action {
    action_group_id = azurerm_monitor_action_group.monitor_action_group.id
  }
}
