variable "location" {
    type = string
    default = "West Europe"
}

variable "failover_location" {
    type = string
    default = "North Europe"
}

variable "subscription_id" {
    type = string
    default = "xxxx-xxxx-xxxx-xxxx-xxxx"
}

variable "webhook_receiver_url" {
  type = string
  default = "https://webhook.site/b54ccbe9-1eca-482e-aa35-3ec7d4cafab1"
}