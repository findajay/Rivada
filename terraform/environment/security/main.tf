resource "azurerm_subscription_policy_assignment" "asb_assignment" {
  name                 = "azuresecuritybenchmark"
  display_name         = "Azure Security Benchmark"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  subscription_id      = var.azurerm_subscription_id
}

resource "azurerm_security_center_subscription_pricing" "mdc_containers" {
  tier          = "Standard"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "mdc_container_registry" {
  tier          = "Standard"
  resource_type = "ContainerRegistry"
}

resource "azurerm_security_center_setting" "setting_sentinel" {
  setting_name = "SENTINEL"
  enabled      = true
}

#blue team email address 
resource "azurerm_security_center_contact" "mdc_contact" {
  email = "blueteam@rivada.com"

  alert_notifications = true
  alerts_to_admins    = true
}

resource "azurerm_security_center_workspace" "mdc_workspace" {
  scope        = var.azurerm_subscription_id
  workspace_id = var.loganalytics_workspace_id
}

# This uses Qualys vulnerability assessment by default if you wish to scan with MDE choose mdeTvm value for the vaType Policy parameter
# https://learn.microsoft.com/en-us/azure/defender-for-cloud/deploy-vulnerability-assessment-vm
# https://learn.microsoft.com/en-us/microsoft-365/security/defender-vulnerability-management/defender-vulnerability-management?view=o365-worldwide

resource "azurerm_subscription_policy_assignment" "va-auto-provisioning" {
  name                 = "mdc-va-autoprovisioning"
  display_name         = "Microsoft Defender for Containers vulnerability assessment and run-time protections"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f"
  subscription_id      = var.azurerm_subscription_id
  identity {
    type = "SystemAssigned"
  }
  location = var.location
}

# Assigning the Security Admin role to the Managed Identity that will be used to perform the automatic provisioning of the Vulnerability Assessment solution
resource "azurerm_role_assignment" "va-auto-provisioning-identity-role" {
  scope              = var.azurerm_subscription_id
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd"
  principal_id       = azurerm_subscription_policy_assignment.va-auto-provisioning.identity[0].principal_id
}

resource "azurerm_log_analytics_solution" "la_workspace_security" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.loganalytics_workspace_id
  workspace_name        = var.loganalytics_workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_log_analytics_solution" "la_workspace_securityfree" {
  solution_name         = "SecurityCenterFree"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.loganalytics_workspace_id
  workspace_name        = var.loganalytics_workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityCenterFree"
  }
}

resource "azurerm_security_center_automation" "la-exports" {
  name                = "ExportToWorkspace"
  location            = var.location
  resource_group_name = var.resource_group_name

  action {
    type        = "loganalytics"
    resource_id = var.loganalytics_workspace_id
  }

  source {
    event_source = "Alerts"
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "High"
        property_type  = "String"
      }
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "Medium"
        property_type  = "String"
      }
    }
  }

  source {
    event_source = "SecureScores"
  }

  source {
    event_source = "SecureScoreControls"
  }

  scopes = [var.azurerm_subscription_id]
}

