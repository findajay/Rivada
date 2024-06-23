variable "component" {
  type = string
}

variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
}

variable "la_workspace_id" {
    type = string  
}