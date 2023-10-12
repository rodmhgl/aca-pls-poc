resource "azurerm_network_interface" "customer-vm" {
  provider            = azurerm.secondary
  name                = "customer-vm-nic"
  location            = azurerm_resource_group.customer-vm.location
  resource_group_name = azurerm_resource_group.customer-vm.name
  tags                = local.default_tags

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.customer-vm.id
    public_ip_address_id          = azurerm_public_ip.customer-vm.id
  }
}

resource "azurerm_linux_virtual_machine" "customer-vm" {
  provider                        = azurerm.secondary
  name                            = "customer-vm-test"
  admin_username                  = var.admin_username
  location                        = azurerm_resource_group.customer-vm.location
  resource_group_name             = azurerm_resource_group.customer-vm.name
  network_interface_ids           = [azurerm_network_interface.customer-vm.id]
  size                            = "Standard_B2ms"
  admin_password                  = var.admin_password
  disable_password_authentication = false
  tags                            = local.default_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
