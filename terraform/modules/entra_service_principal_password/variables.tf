variable "service_principal" {
  type = object({
    object_id = string
  })
}

variable "display_name" {
  type = string
}

variable "end_date_relative" {
  type = string
  nullable = true
  default = null
}
