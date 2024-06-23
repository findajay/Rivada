resource "azurerm_container_group" "container_groups" {
  name                = "${var.component}-${var.env}-${var.name}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  ip_address_type     = var.ip_address_type
  os_type             = "Linux"
  subnet_ids          = [var.subnet_id]

  dynamic "container" {
    for_each = var.container
    content {
      name   = container.value["name"]
      image  = container.value["image"]
      cpu    = container.value["cpu"]
      memory = container.value["memory"]
      ports {
        port     = container.value["ports"].port
        protocol = container.value["ports"].protocol
      }
    }
  }
  diagnostics {
    log_analytics {
      log_type      = "ContainerInsights"
      workspace_id  = var.workspace_log_anaytics != null ? var.workspace_log_anaytics.id : null
      workspace_key = var.workspace_log_anaytics != null ? var.workspace_log_anaytics.key : null
    }
  }
  tags = {
    environment = "${var.env}"
  }
}

resource "azurerm_network_profile" "netp" {
  name                = "${var.component}-${var.env}-netp"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  container_network_interface {
    name = "${var.component}-${var.env}-nic"

    ip_configuration {
      name      = "private"
      subnet_id = var.subnet_id
    }
  }

}
