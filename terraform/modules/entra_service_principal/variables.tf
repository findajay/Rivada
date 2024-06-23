variable "application" {
  type = object({
    application_id = string
  })
}

variable "tags" {
  type = map(string)
  default = {}
}
