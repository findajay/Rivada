variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type     = map(string)
  nullable = true
  default  = null
}
