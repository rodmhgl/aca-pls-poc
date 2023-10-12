locals {
  stack = "${var.app}-${var.env}-${var.region}"

  default_tags = {
    environment = var.env
    app         = var.app
    lab         = "pls-test"
  }

}

resource "azurerm_resource_group" "local" {
  name     = "rg-local-${local.stack}"
  location = var.region
  tags     = local.default_tags
}

resource "azurerm_log_analytics_workspace" "local" {
  name                = "log-${local.stack}"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  tags                = local.default_tags
}

resource "azurerm_virtual_network" "local" {
  name                = "${var.app}-local-vnet"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  address_space       = [var.local_network_address_space]
}

resource "azurerm_subnet" "aca" {
  name                                          = "aca-local-subnet"
  resource_group_name                           = azurerm_resource_group.local.name
  virtual_network_name                          = azurerm_virtual_network.local.name
  address_prefixes                              = [var.local_subnet_address_prefix]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_private_endpoint" "local" {
  name                = "${local.stack}-local-endpoint"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  subnet_id           = azurerm_subnet.aca.id

  private_service_connection {
    name                           = "${local.stack}-privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.local.id
    is_manual_connection           = false
  }
}

resource "azurerm_public_ip" "local_vm" {
  name                = "localPublicIp1"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.local.name
  location            = azurerm_resource_group.local.location
  tags                = local.default_tags
}

resource "azurerm_public_ip" "local_windows_vm" {
  name                = "localPublicIp2"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.local.name
  location            = azurerm_resource_group.local.location
  tags                = local.default_tags
}
