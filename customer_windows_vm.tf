resource "azurerm_network_interface" "customer-windows-vm" {
  provider            = azurerm.secondary
  name                = "customer-windows-nic"
  location            = azurerm_resource_group.customer-vm.location
  resource_group_name = azurerm_resource_group.customer-vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.customer-vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.customer-windows-vm.id
  }
}

resource "azurerm_windows_virtual_machine" "customer-windows-vm" {
  provider            = azurerm.secondary
  name                = "customer-win-vm"
  resource_group_name = azurerm_resource_group.customer-vm.name
  location            = azurerm_resource_group.customer-vm.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.customer-windows-vm.id,
  ]

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