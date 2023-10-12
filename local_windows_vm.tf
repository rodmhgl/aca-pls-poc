resource "azurerm_network_interface" "local-windows-vm" {
  name                = "local-windows-example-nic"
  location            = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aca.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.local_windows_vm.id
  }
}

resource "azurerm_windows_virtual_machine" "local-windows-vm" {
  name                  = "localwinvm"
  resource_group_name   = azurerm_resource_group.local.name
  location              = azurerm_resource_group.local.location
  size                  = "Standard_F2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.local-windows-vm.id, ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}