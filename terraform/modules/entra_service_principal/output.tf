output "object_id" {
    value = azuread_service_principal.principal.object_id
}

output "principal_id" {
    value = azuread_service_principal.principal.object_id
}

output "client_id" {
    value = var.application.application_id
}

output "tenant_id" {
    value = azuread_service_principal.principal.application_tenant_id 
}