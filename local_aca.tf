locals {
  # Unable to find a direct export for the managed resource group name
  # So we'll just hack it together ourselves
  aca_fqdn_parts = split(".", data.azurerm_container_app.aca.ingress[0].fqdn)
  aca_managed_rg = "MC_${local.aca_fqdn_parts[1]}-rg_${local.aca_fqdn_parts[1]}_${local.aca_fqdn_parts[2]}"
}

resource "azapi_resource" "containerapp_environment" {
  type                    = "Microsoft.App/managedEnvironments@2022-03-01"
  name                    = "cae-${local.stack}"
  parent_id               = azurerm_resource_group.local.id
  location                = azurerm_resource_group.local.location
  response_export_values  = ["properties.defaultDomain", "properties.staticIp"]
  ignore_missing_property = true

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.local.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.local.primary_shared_key
        }
      }
      vnetConfiguration = {
        internal               = true
        infrastructureSubnetId = azurerm_subnet.aca.id
        dockerBridgeCidr       = "10.2.0.1/16"
        platformReservedCidr   = "10.1.0.0/16"
        platformReservedDnsIP  = "10.1.0.2"
      }
    }
  })

  depends_on = [
    azurerm_virtual_network.local,
  ]

  # lifecycle {
  #   ignore_changes = [
  #     output,
  #   ]
  # }

}

data "azurerm_container_app_environment" "acae" {
  name                = azapi_resource.containerapp_environment.name
  resource_group_name = azurerm_resource_group.local.name
}

resource "azapi_resource" "containerapp" {
  type      = "Microsoft.App/containerapps@2022-03-01"
  name      = "app01acae"
  parent_id = azurerm_resource_group.local.id
  location  = azurerm_resource_group.local.location

  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.containerapp_environment.id
      configuration = {
        ingress = {
          external : true,
          targetPort : 80
        },

      }
      template = {
        containers = [
          {
            image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            name  = "simple-hello-world-container"
            resources = {
              cpu    = 0.25
              memory = "0.5Gi"
            }
          }
        ]
        scale = {
          minReplicas = 0,
          maxReplicas = 2
        }
      }
    }

  })
}

data "azurerm_container_app" "aca" {
  name                = azapi_resource.containerapp.name #"app01acae"
  resource_group_name = azurerm_resource_group.local.name
  depends_on          = [azapi_resource.containerapp]
}

data "azurerm_lb" "kubernetes-internal" {
  name                = "kubernetes-internal"
  resource_group_name = local.aca_managed_rg
}

resource "azurerm_private_link_service" "local" {
  name                                        = "${local.stack}-privatelink"
  resource_group_name                         = azurerm_resource_group.local.name
  location                                    = azurerm_resource_group.local.location
  auto_approval_subscription_ids              = var.approved_subscription_ids
  visibility_subscription_ids                 = var.approved_subscription_ids
  load_balancer_frontend_ip_configuration_ids = [data.azurerm_lb.kubernetes-internal.frontend_ip_configuration[0].id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.aca.id
    primary                    = true
  }
}
