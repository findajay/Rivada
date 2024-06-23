data "azurerm_subscription" "current" {}
locals {
  environment_names = ["dev", "stage", "prod"]
}
module "environments" {
  source = "./environment"
  count  = 3

  environment     = local.environment_names[count.index]
  subscription_id = var.subscription_id

  location          = var.location
  failover_location = var.failover_location

  front_door_sku_name    = "Standard_AzureFrontDoor"
  cdn_endpoint_host_name = "mediahost"

  sql_server_config = {
    db_name = "identitystore"
  }

  email_receivers = {
    admin1 = {
      name          = "service account"
      email_address = "service@rivada.com"
  } }

  webhook_receiver_url = var.webhook_receiver_url

  active_container_service_groups = {
    container_group_name = "backend"
    containers = {
      container1 = {
        name   = "hello-world"
        memory = "1.5"
        cpu    = "0.5"
        image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
        ports = {
          port     = 443
          protocol = "TCP"
        }
      }
      sidecar = {
        name   = "sidecar"
        memory = "1.5"
        cpu    = "0.5"
        image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
        ports = {
          port     = 443
          protocol = "TCP"
        }
      }
  } }

  passive_container_service_groups = {
    container_group_name = "backend"
    containers = {
      container1 = {
        name   = "hello-world"
        memory = "1.5"
        cpu    = "0.5"
        image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
        ports = {
          port     = 443
          protocol = "TCP"
        }
      }
      sidecar = {
        name   = "sidecar"
        memory = "1.5"
        cpu    = "0.5"
        image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
        ports = {
          port     = 443
          protocol = "TCP"
        }
      }
  } }



}


