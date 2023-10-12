resource "azurerm_private_dns_zone" "local" {
  name                = data.azurerm_container_app_environment.acae.default_domain
  resource_group_name = azurerm_resource_group.local.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "containerapplink"
  resource_group_name   = azurerm_resource_group.local.name
  private_dns_zone_name = azurerm_private_dns_zone.local.name
  virtual_network_id    = azurerm_virtual_network.local.id
}

resource "azurerm_private_dns_a_record" "containerapp_record" {
  name                = "app01acae"
  zone_name           = azurerm_private_dns_zone.local.name
  resource_group_name = azurerm_resource_group.local.name
  records             = [azurerm_private_endpoint.local.private_service_connection[0].private_ip_address]
  ttl                 = 300
}
