output "local_linux_vm_public_ip" {
  description = "The connection string to the Linux VM that resides in the SAME vnet as the Azure Container App."
  value       = "ssh ${azurerm_linux_virtual_machine.local_vm.admin_username}@${azurerm_public_ip.local_vm.ip_address}"
}

output "local_windows_vm_public_ip" {
  description = "The connection string to the Windows VM that resides in the SAME vnet as the Azure Container App."
  value       = "mstsc /v:${azurerm_public_ip.local_windows_vm.ip_address}"
}

output "customer_linux_vm_public_ip" {
  description = "The connection string to the Linux VM that resides in the NON-PEERED vnet."
  value       = "ssh ${azurerm_linux_virtual_machine.customer-vm.admin_username}@${azurerm_public_ip.customer-vm.ip_address}"
}

output "customer_windows_vm_public_ip" {
  description = "The connection string to the Windows VM that resides in the NON-PEERED vnet."
  value       = "mstsc /v:${azurerm_public_ip.customer-windows-vm.ip_address}"
}

output "aca_url" {
  description = "The container app url."
  value       = "curl -vvvL https://${data.azurerm_container_app.aca.ingress[0].fqdn}"
}
