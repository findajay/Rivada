variable "environment_name" {
  type     = string
  default  = "dev"
  nullable = false
}

variable "component_name" {
  type     = string
  default  = "rivada"
  nullable = false
}

variable "resource_group" {
  type = object({
    name               = string
    primary_location   = string
    secondary_location = string
  })
}

variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."
  default     = "azureadmin"
}

variable "admin_password" {
  type        = string
  description = "The administrator password of the SQL logical server."
  sensitive   = true
  default     = null
}

variable "key_vault" {
  type = object({
    id = string
  })
}

variable "network_config" {
  type = object({
    primary_subnet_id   = string
    secondary_subnet_id = string
    dns_zone_id         = string
    dns_zone_name       = string
    virtual_network_id  = string
  })
}

variable "db_name" {
  type = string
}
