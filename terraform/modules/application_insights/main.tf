resource "azurerm_application_insights" "app_insights" {
  name                = "${var.component}-${var.env}-${var.name}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  workspace_id        = var.la_workspace_id
  application_type    = "web"
}

