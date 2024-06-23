variable "key_vault" {
  type = object({
    id = string
  })
}

variable "name" {
  type = string
}

variable "value" {
  type = string
  sensitive = true
}
