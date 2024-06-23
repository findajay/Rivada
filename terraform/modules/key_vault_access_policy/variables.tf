variable "key_vault" {
  type = object({
    id = string
  })
}

variable "service_principal" {
  type = object({
    tenant_id = string
    principal_id = string
  })
}

variable "key_permissions" {
  type = list(string)
  default = []
}

variable "secret_permissions" {
  type = list(string)
  default = []
}

variable "certificate_permissions" {
  type = list(string)
  default = []
}