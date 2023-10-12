resource "azurerm_resource_group" "customer-vm" {
  provider = azurerm.secondary
  name     = "rg-customer-${local.stack}"
  location = var.region
  tags     = local.default_tags
}

resource "azurerm_virtual_network" "customer-vm" {
  provider            = azurerm.secondary
  name                = "${var.app}-customer-vnet"
  location            = azurerm_resource_group.customer-vm.location
  resource_group_name = azurerm_resource_group.customer-vm.name
  address_space       = [var.customer_network_address_space]
}

resource "azurerm_subnet" "customer-vm" {
  provider                                      = azurerm.secondary
  name                                          = "customer-vm-subnet"
  resource_group_name                           = azurerm_resource_group.customer-vm.name
  virtual_network_name                          = azurerm_virtual_network.customer-vm.name
  address_prefixes                              = [var.customer_subnet_address_prefix]
  private_link_service_network_policies_enabled = true
  private_endpoint_network_policies_enabled     = true
}

resource "azurerm_private_endpoint" "customer-vm-pe" {
  provider            = azurerm.secondary
  name                = "aca-customer-endpoint"
  location            = azurerm_resource_group.customer-vm.location
  resource_group_name = azurerm_resource_group.customer-vm.name
  subnet_id           = azurerm_subnet.customer-vm.id

  private_service_connection {
    name                           = "aca-privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.local.id
    is_manual_connection           = false
  }
}

resource "azurerm_public_ip" "customer-vm" {
  provider            = azurerm.secondary
  name                = "customerPublicIp1"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.customer-vm.name
  location            = azurerm_resource_group.customer-vm.location
  tags                = local.default_tags
}

resource "azurerm_public_ip" "customer-windows-vm" {
  provider            = azurerm.secondary
  name                = "customerPublicIp2"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.customer-vm.name
  location            = azurerm_resource_group.customer-vm.location
  tags                = local.default_tags
}
