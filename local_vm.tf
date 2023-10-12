resource "azurerm_network_interface" "local_vm" {
  name                = "local-vm-nic"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  tags                = local.default_tags

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.aca.id
    public_ip_address_id          = azurerm_public_ip.local_vm.id
  }
}

resource "azurerm_linux_virtual_machine" "local_vm" {
  name                            = "local-vm-test"
  admin_username                  = var.admin_username
  location                        = azurerm_resource_group.local.location
  resource_group_name             = azurerm_resource_group.local.name
  network_interface_ids           = [azurerm_network_interface.local_vm.id]
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
