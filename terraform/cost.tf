module "admins" {
  source = "./modules/admins"
}

resource "azurerm_resource_group" "rg_global_infra" {
  name     = "rivada-global-infra"
  location = var.location
}

resource "azurerm_monitor_action_group" "azure_admin" {
  name                = "azure_admin"
  resource_group_name = azurerm_resource_group.rg_global_infra.name
  short_name          = "azure_admin"

  email_receiver {
    name          = "service account"
    email_address = "infra-service@rivada.com"
  }
}

# global budget notification for cloud account
resource "azurerm_consumption_budget_subscription" "global_budget" {
  name            = "Global_Budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 2000
  time_grain = "Monthly"

  time_period {
    start_date = "2024-07-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"

    contact_groups = [
      azurerm_monitor_action_group.azure_admin.id,
    ]

    contact_roles = [
      "Owner"
    ]
  }
}
