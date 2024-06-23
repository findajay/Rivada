#Relational Database
resource "azurerm_mssql_managed_instance" "primary" {
  name                         = "${var.component_name}-${var.environment_name}-primary"
  resource_group_name          = var.resource_group.name
  location                     = var.resource_group.primary_location
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  license_type                 = "BasePrice"
  subnet_id                    = var.network_config.primary_subnet_id
  sku_name                     = "GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 32

  depends_on = [
    azurerm_subnet_network_security_group_association.primary,
    azurerm_subnet_route_table_association.primary,
  ]

  tags = {
    environment = "prod"
  }
}

resource "azurerm_mssql_managed_database" "sql_managed_db" {
  name                = "${var.component_name}-${var.environment_name}-${var.db_name}"
  managed_instance_id = azurerm_mssql_managed_instance.primary.id

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_mssql_managed_instance" "secondary" {
  name                         = "${var.component_name}-${var.environment_name}-secondary"
  resource_group_name          = var.resource_group.name
  location                     = var.resource_group.secondary_location
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  license_type                 = "BasePrice"
  subnet_id                    = var.network_config.secondary_subnet_id
  sku_name                     = "GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 32

  depends_on = [
    azurerm_subnet_network_security_group_association.secondary,
    azurerm_subnet_route_table_association.secondary,
  ]

  tags = {
    environment = "prod"
  }
}

resource "azurerm_mssql_managed_database" "sql_managed_db_in_secondary" {
  name                = "${var.component_name}-${var.environment_name}-${var.db_name}"
  managed_instance_id = azurerm_mssql_managed_instance.secondary.id

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_mssql_managed_instance_failover_group" "failover_group" {
  name                        = "${var.component_name}-${var.environment_name}-failover-group"
  location                    = azurerm_mssql_managed_instance.primary.location
  managed_instance_id       = azurerm_mssql_managed_instance.primary.id
  partner_managed_instance_id = azurerm_mssql_managed_instance.secondary.id

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}

//Store sql server password in keyvault 
module "key_vault_secret_function" {
  source = "../key_vault_secret"

  key_vault = var.key_vault
  name      = "sql-server-password"
  value     = var.admin_password
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "${var.component_name}-${var.environment_name}-private-endpoint-sql"
  location            = var.resource_group.primary_location
  resource_group_name = var.resource_group.name
  subnet_id           = var.network_config.primary_subnet_id

  private_service_connection {
    name                           = "private-serviceconnection"
    private_connection_resource_id = azurerm_mssql_managed_instance.primary.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [var.network_config.dns_zone_id]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_zone_vnet_link" {
  name                  = "${var.component_name}-${var.environment_name}-vnet-link"
  resource_group_name   = var.resource_group.name
  private_dns_zone_name = var.network_config.dns_zone_name
  virtual_network_id    = var.network_config.virtual_network_id
}

//NSG for failover group and network association 
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.component_name}-${var.environment_name}-nsg"
  location            = var.resource_group.primary_location
  resource_group_name = var.resource_group.name

  security_rule {
    name                       = "allowInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "primary" {
  subnet_id                 = var.network_config.primary_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "secondary" {
  subnet_id                 = var.network_config.secondary_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_route_table" "routetable" {
  name                = "${var.component_name}-${var.environment_name}-routetable"
  location            = var.resource_group.primary_location
  resource_group_name = var.resource_group.name

  route {
    name           = "${var.component_name}-${var.environment_name}-route"
    address_prefix = "Sql"
    next_hop_type  = "VnetLocal"
  }
}

resource "azurerm_subnet_route_table_association" "primary" {
  subnet_id      = var.network_config.primary_subnet_id
  route_table_id = azurerm_route_table.routetable.id
}

resource "azurerm_subnet_route_table_association" "secondary" {
  subnet_id      = var.network_config.secondary_subnet_id
  route_table_id = azurerm_route_table.routetable.id
}
