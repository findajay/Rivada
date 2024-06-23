
resource "azurerm_virtual_network" "network" {
  name                = "${local.component_name}-${var.environment}"
  address_space       = ["10.0.0.0/21"]
  location            = azurerm_resource_group.rg_infra.location
  resource_group_name = azurerm_resource_group.rg_infra.name
}

resource "azurerm_subnet" "public" {
  count                = 2
  name                 = "public-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg_infra.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

resource "azurerm_subnet" "private" {
  count                = 2
  name                 = "private-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg_infra.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.${count.index + 2}.0/24"]

  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]

  delegation {
    name = "private"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name = "Microsoft.ContainerInstance/containerGroups"
    }
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${local.component_name}-${var.environment}"
  location            = azurerm_resource_group.rg_infra.location
  resource_group_name = azurerm_resource_group.rg_infra.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

