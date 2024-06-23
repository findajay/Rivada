resource "random_id" "front_door_endpoint_name" {
  byte_length = 8
}

locals {
  front_door_profile_name      = "${local.component_name}${var.environment}"
  front_door_endpoint_name     = "afd-${lower(random_id.front_door_endpoint_name.hex)}"
  front_door_origin_group_name = "${local.component_name}-${var.environment}-origin-group"
  front_door_origin_name       = "${local.component_name}-${var.environment}-origin"
  front_door_route_name        = "${local.component_name}-${var.environment}-route"
}

resource "azurerm_cdn_frontdoor_profile" "front_door" {
  name                = local.front_door_profile_name
  resource_group_name = azurerm_resource_group.rg_infra.name
  sku_name            = var.front_door_sku_name
}

resource "azurerm_cdn_frontdoor_custom_domain" "front_door_custom_domain" {
  name                     = "${local.component_name}-${var.environment}-cd"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door.id
  dns_zone_id              = azurerm_private_dns_zone.dns_zone.id
  host_name                = "api.rivada.com"

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group" {
  name                     = local.front_door_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "fd_app_service_origin_blue" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id

  enabled                        = true
  host_name                      = module.blue_container_groups.fqdn
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = module.blue_container_groups.fqdn
  priority                       = 1
  weight                         = 100
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_origin" "fd_app_service_origin_green" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id

  enabled                        = true
  host_name                      = module.green_container_groups.fqdn
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = module.green_container_groups.fqdn
  priority                       = 5
  weight                         = 1
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "my_blue_route" {
  name                          = local.front_door_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd_app_service_origin_blue.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "my_green_route" {
  name                          = local.front_door_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd_app_service_origin_green.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}
