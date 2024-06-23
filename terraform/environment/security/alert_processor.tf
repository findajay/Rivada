module "azurerm_logicapp_workflow" {
  source = "../../modules/logic_app"

  name                = "rivada-alert-processor"
  resource_group_name = var.resource_group_name
  location            = var.location
  enabled             = true

  tags = {
    type        = "Alert Processor"
    environment = "Global"
    connection  = "slack"
  }
}
