**Orchestration of multiple environments for cloud based container solution for Rivada**
Overview
This project leverages Terraform to orchestrate an Azure environment that includes components for security, monitoring, networking, and container management. The infrastructure provisions Azure Front Door, Azure Container Instances, and an Azure Container Registry for deploying and managing containers.

**Project Structure**
```javascript
.
├── devops
│   ├── build.yml
│   ├── deploy.yml
│   ├── infrastructure.yml
├── main.tf
├── cost.tf
├── variables.tf
├── outputs.tf
├── environment
│   ├── security
│   │   ├── alert_processor.tf
│   │   └── main.tf
│   │   └── sentinel_alert_rules.tf
│   │   ├── sentinel_connectors.tf
│   │   └── variables.tf
│   ├── monitoring.tf
│   ├── network.tf
│   └── front_door.tf
│   └── container_registry.tf
│   └── main.tf
│   └── setup.tf
│   └── variables.tf
├── modules
├── README.md
└── terraform.tfvars
```

**Prerequisites :** 
Terraform installed on your machine.
Azure CLI installed and configured. Follow the instructions here to install.
An Azure subscription.

Modules : Environment component handles orchastration of below modules

### Security
The security module utilizes the benefits of free Microsoft security center which is capable of providing some policies to scan containers and various other infra resources using microsoft cloud defender.

### Key Vault
 Securely store and manage sensitive information such as passwords, tokens, and keys. This includes the configuration for Azure Key Vault and Role-Based Access Control (RBAC) to manage secrets and permissions.

### Monitoring
The monitoring module provisions Azure Monitor and Log Analytics to collect, analyze, and act on telemetry data from your Azure resources. It also sends alerts to action groups and webhook notifications for external app integrations, utilizing Azure Monitor for full-stack monitoring of applications and infrastructure. Log Analytics allows querying and analyzing log data.

### Networking
Configures a virtual network with appropriate subnets.
NSGs: Implements security rules to control inbound and outbound traffic.

### Container Management
The container management module handles the creation of an Azure Container Registry (ACR) and Azure Container Instances (ACI) for deploying containers and orchastrate it using frontdoor load balancing capabilities.

**Variables**
Define the necessary variables in terraform.tfvars or directly in the variables.tf file. Here are some essential variables:

```javascript
variable "environment" {
  type     = string
  default  = "dev"
  nullable = false
}

variable "location" {
  type     = string
  default  = "West Europe"
  nullable = true
}

variable "failover_location" {
  type     = string
  default  = "Central Europe"
}

variable "cdn_endpoint_host_name" {
  type     = string
  nullable = false
}

variable "sql_admin_password" {
  type     = string
  nullable = true
}

variable "subscription_id" {
  type = string
}

variable "email_receivers" {
  type = map(object({
    name          = string
    email_address = string
  }))
  nullable = true
  default  = null
}

variable "webhook_receiver_url" {
  type        = string
  description = "Url of the webhook to process alert with standard schema."
  nullable    = true
  default     = null
}

variable "active_container_service_groups" {
  type = object({
    container_group_name = string
    containers = map(object({ 
      name  = string
      image  = string
      cpu    = optional(string, "0.5")
      memory = optional(string, "1.5")
      ports = optional(object({
        port     = optional(number, 443)
        protocol = optional(string, "TCP")
      }))
    }))
  })
}

variable "passive_container_service_groups" {
  type = object({
    container_group_name = string
    containers = map(object({ 
      name  = string
      image  = string
      cpu    = optional(string, "0.5")
      memory = optional(string, "1.5")
      ports = optional(object({
        port     = optional(number, 443)
        protocol = optional(string, "TCP")
      }))
    }))
  })
}

variable "front_door_sku_name" {
  type        = string
  description = "The SKU for the Front Door profile. Possible values include: Standard_AzureFrontDoor, Premium_AzureFrontDoor"
  default     = "Standard_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku_name)
    error_message = "The SKU value must be one of the following: Standard_AzureFrontDoor, Premium_AzureFrontDoor."
  }
}

```
**Deployment**
Clone the Repository:

Go to the root repository of code 

### Initialize Terraform:
```javascript
terraform init
```
### Plan the Deployment:
```javascript
terraform plan -out main.tfplan
```

### Apply the Configuration:
```javascript
 terraform apply main.tfplan  
```

**Devops **
The YAML file uses several environment variables for configuring the backend storage. Make sure these variables are defined in your pipeline settings:

```javascript
storageAccountName
containerName
key
accessKey
```

**Steps to Set Up the Pipeline**
### Create a New Pipeline:

Navigate to your Azure DevOps project.
Go to Pipelines > Create Pipeline.
Choose your repository and select "YAML" as the configuration method.
Copy and paste the provided YAML configuration into the editor.
Define Environment Variables:

### Go to the pipeline settings.
Define the required environment variables (storageAccountName, containerName, key, accessKey) under the "Variables" section.
Run the Pipeline:

### Save and run the pipeline.
Monitor the pipeline execution to ensure that the stages complete successfully.