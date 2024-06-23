// ###########################
// Container Registry
// ###########################
resource "azurerm_container_registry" "acr" {
  name                          = "${local.component_name}registry"
  resource_group_name           = azurerm_resource_group.rg_infra.name
  location                      = azurerm_resource_group.rg_infra.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  identity {
    type = "SystemAssigned"
  }

  network_rule_set = [
    {
      default_action = "Deny"
      ip_rule        = []
      virtual_network = [
        {
          action    = "Allow"
          subnet_id = azurerm_subnet.private[0].id
        }
      ]
    }
  ]
}

resource "azurerm_private_endpoint" "acr" {
  name                = "${azurerm_container_registry.acr.name}-private-endpoint"
  resource_group_name = azurerm_resource_group.rg_infra.name
  location            = azurerm_resource_group.rg_infra.location
  subnet_id           = azurerm_subnet.private[0].id

  private_dns_zone_group {
    name                 = "container-registry-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }

  private_service_connection {
    name                           = "containerregistryprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry_vnet_link" {
  name                  = "vnet-private-zone-link"
  resource_group_name   = azurerm_resource_group.rg_infra.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.network.id
  registration_enabled  = true
}

resource "azurerm_role_definition" "component_private_link" {
  name        = "Component ACR Private Link"
  scope       = data.azurerm_subscription.current.id
  description = "Allows access add a private link to the ACR."

  permissions {
    actions     = ["Microsoft.ContainerRegistry/registries/privateEndpointConnectionsApproval/action"]
    not_actions = []
  }
}

