variable "component" {
  type = string
}

variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "workspace_log_anaytics" {
  type = object({
    id  = string
    key = string
  })
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
}

variable "ip_address_type" {
  type     = string
  default  = "Public"
  nullable = true
}

variable "subnet_id" {
  type = string
}

variable "container" {
  type = map(object({
    name   = string
    image  = string
    cpu    = optional(string, "0.5")
    memory = optional(string, "1.5")
    ports = optional(object({
      port     = optional(number, 443)
      protocol = optional(string, "TCP")
    }))
  }))
  default = {}
}
