resource "azurerm_private_dns_zone" "customer-vm" {
  provider            = azurerm.secondary
  name                = data.azurerm_container_app_environment.acae.default_domain
  resource_group_name = azurerm_resource_group.customer-vm.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vm_vnet_link" {
  provider              = azurerm.secondary
  name                  = "containerapplink"
  resource_group_name   = azurerm_resource_group.customer-vm.name
  private_dns_zone_name = azurerm_private_dns_zone.customer-vm.name
  virtual_network_id    = azurerm_virtual_network.customer-vm.id
}

resource "azurerm_private_dns_a_record" "vm_containerapp_record" {
  provider            = azurerm.secondary
  name                = "app01acae"
  zone_name           = azurerm_private_dns_zone.customer-vm.name
  resource_group_name = azurerm_resource_group.customer-vm.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.customer-vm-pe.private_service_connection[0].private_ip_address]
}
