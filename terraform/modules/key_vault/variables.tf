variable "component" {
  type = string
}

variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "truncate_name" {
  type = bool
  default = false
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "resource_group" {
  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "service_principal" {
  type = object({
    tenant_id = string
    object_id = string
  })
  nullable = true
  default  = null
}

variable "subnet" {
  type = object({
    id = string
  })
  nullable = true
}