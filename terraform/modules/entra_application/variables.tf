variable "display_name" {
  type = string
}

variable "identifier_uris" {
  type     = list(string)
  nullable = true
  default  = null
}
variable "api" {
  type = object({
    known_client_applications = optional(list(string), [])
    oauth2_permission_scopes = optional(list(object({
      admin_consent_description  = string
      admin_consent_display_name = string
      enabled                    = optional(bool, true)
      id                         = string
      type                       = optional(string, "User")
      user_consent_description   = optional(string)
      user_consent_display_name  = optional(string)
      value                      = string
    })), [])
  })
  default = {
    known_client_applications = []
    oauth2_permission_scopes = []
  }
}

variable "web" {
  type = object({
    homepage_url  = string
    logout_url    = string
    redirect_uris = list(string)

    implicit_grant = optional(object(
      {
        access_token_issuance_enabled = optional(bool, false)
        id_token_issuance_enabled     = optional(bool, false)
      }),
      {
        access_token_issuance_enabled = false
        id_token_issuance_enabled     = false
      }
    )
  })
  nullable = true
  default = null
}
