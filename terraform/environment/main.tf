locals {
  component_name                 = "rivada"
  backend_address_pool_name      = "${azurerm_virtual_network.network.name}-bkd-pool"
  frontend_port_name             = "${azurerm_virtual_network.network.name}-fe-port"
  frontend_ip_configuration_name = "${azurerm_virtual_network.network.name}-fe-ip"
  http_setting_name              = "${azurerm_virtual_network.network.name}-http-st"
  listener_name                  = "${azurerm_virtual_network.network.name}-http-lstn"
  request_routing_rule_name      = "${azurerm_virtual_network.network.name}-req-route"
  redirect_configuration_name    = "${azurerm_virtual_network.network.name}-rdr-conf"
  admin_password                 = try(random_password.admin_password[0].result, var.sql_server_config.sql_admin_password)
}
data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg_infra" {
  name     = "${local.component_name}-${var.environment}-infra"
  location = var.location
}

resource "azurerm_resource_group" "rg_services" {
  name     = "${local.component_name}-${var.environment}-services"
  location = var.location
}

module "containers_entra_app" {
  source = "../modules/entra_application"

  display_name = "${local.component_name}-${var.environment}-container"
}

module "containers_entra_service_principal" {
  source = "../modules/entra_service_principal"

  application = module.containers_entra_app
}

module "containers_sp_password" {
  source = "../modules/entra_service_principal_password"

  display_name      = "containers sp password"
  service_principal = module.containers_entra_service_principal
}

module "containers_keyvault" {
  source         = "../modules/key_vault"
  resource_group = azurerm_resource_group.rg_services

  component         = local.component_name
  env               = var.environment
  subnet            = azurerm_subnet.private[0]
  name              = "${local.component_name}${var.environment}containerkeys"
  service_principal = module.containers_entra_service_principal
}

module "key_vault_secret_function" {
  source = "../modules/key_vault_secret"

  key_vault = module.containers_keyvault
  name      = "container-secret-password"
  value     = module.containers_sp_password.value
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "${var.environment}.${local.component_name}.io"
  resource_group_name = azurerm_resource_group.rg_infra.name
}

# Blue Green deployment on container groups 
//Active container Group
module "blue_container_groups" {
  source = "../modules/container_group"

  component      = local.component_name
  env            = var.environment
  subnet_id      = azurerm_subnet.private[0].id
  resource_group = azurerm_resource_group.rg_services
  workspace_log_anaytics = {
    id  = azurerm_log_analytics_workspace.workspace.id
    key = azurerm_log_analytics_workspace.workspace.primary_shared_key
  }
  name      = var.active_container_service_groups.container_group_name
  container = var.active_container_service_groups.containers
}

//Passive container group
module "green_container_groups" {
  source = "../modules/container_group"

  component      = local.component_name
  env            = var.environment
  subnet_id      = azurerm_subnet.private[1].id
  resource_group = azurerm_resource_group.rg_services
  workspace_log_anaytics = {
    id  = azurerm_log_analytics_workspace.workspace.id
    key = azurerm_log_analytics_workspace.workspace.primary_shared_key
  }
  name      = var.passive_container_service_groups.container_group_name
  container = var.passive_container_service_groups.containers
}

# Random password for SQL server
resource "random_password" "admin_password" {
  count       = var.sql_server_config.sql_admin_password == null ? 1 : 0
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

# sql component with failover setup 
module "sql_database" {
  source = "../modules/sql_server"

  component_name   = local.component_name
  environment_name = var.environment
  admin_password   = local.admin_password
  admin_username   = "${local.component_name}${var.environment}-admin"
  resource_group = {
    name               = azurerm_resource_group.rg_infra.name
    primary_location   = azurerm_resource_group.rg_infra.location
    secondary_location = var.failover_location
  }
  key_vault = module.containers_keyvault
  db_name   = var.sql_server_config.db_name
  network_config = {
    primary_subnet_id   = azurerm_subnet.private[0].id
    secondary_subnet_id = azurerm_subnet.private[1].id
    dns_zone_id         = azurerm_private_dns_zone.dns_zone.id
    dns_zone_name       = azurerm_private_dns_zone.dns_zone.name
    virtual_network_id  = azurerm_virtual_network.network.id
  }
}


module "security" {
  source = "./security"

  azurerm_subscription_id     = data.azurerm_subscription.current.id
  resource_group_name         = azurerm_resource_group.rg_infra.name
  location                    = azurerm_resource_group.rg_infra.location
  loganalytics_workspace_id   = azurerm_log_analytics_workspace.workspace.id
  loganalytics_workspace_name = azurerm_log_analytics_workspace.workspace.name
}
