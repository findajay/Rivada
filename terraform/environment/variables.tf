variable "environment" {
  type     = string
  default  = "dev"
  nullable = false
}

variable "location" {
  type     = string
  default  = "West Europe"
  nullable = true
}

variable "failover_location" {
  type    = string
  default = "Central Europe"
}

variable "cdn_endpoint_host_name" {
  type     = string
  nullable = false
}

variable "sql_server_config" {
  type = object({
    db_name            = string
    sql_admin_password = optional(string)
  })
}

variable "subscription_id" {
  type = string
}

variable "email_receivers" {
  type = map(object({
    name          = string
    email_address = string
  }))
  nullable = true
  default  = null
}

variable "webhook_receiver_url" {
  type        = string
  description = "Url of the webhook to process alert with standard schema."
  nullable    = true
  default     = null
}

variable "active_container_service_groups" {
  type = object({
    container_group_name = string
    containers = map(object({ name = string
      image  = string
      cpu    = optional(string, "0.5")
      memory = optional(string, "1.5")
      ports = optional(object({
        port     = optional(number, 443)
        protocol = optional(string, "TCP")
      }))
    }))
  })
}

variable "passive_container_service_groups" {
  type = object({
    container_group_name = string
    containers = map(object({ name = string
      image  = string
      cpu    = optional(string, "0.5")
      memory = optional(string, "1.5")
      ports = optional(object({
        port     = optional(number, 443)
        protocol = optional(string, "TCP")
      }))
    }))
  })
}

variable "front_door_sku_name" {
  type        = string
  description = "The SKU for the Front Door profile. Possible values include: Standard_AzureFrontDoor, Premium_AzureFrontDoor"
  default     = "Standard_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku_name)
    error_message = "The SKU value must be one of the following: Standard_AzureFrontDoor, Premium_AzureFrontDoor."
  }
}
