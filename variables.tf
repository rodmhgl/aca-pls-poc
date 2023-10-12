variable "region" {
  description = "Azure infrastructure region"
  type        = string
  default     = "eastus"
}

variable "local_network_address_space" {
  description = "The address space that is used the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "local_subnet_address_prefix" {
  description = "The address space that is used the aca subnet."
  type        = string
  default     = "10.0.0.0/23"
}

variable "customer_network_address_space" {
  description = "The address space that is used the virtual network."
  type        = string
  default     = "172.16.0.0/16"
}

variable "customer_subnet_address_prefix" {
  description = "The address space that is used the aca subnet."
  type        = string
  default     = "172.16.0.0/23"
}

variable "app" {
  description = "Name of the application that we are deploying."
  type        = string
  default     = "myapp"
}

variable "env" {
  description = "The environment that we are deploying to."
  type        = string
  default     = "dev"
}

variable "approved_subscription_ids" {
  description = "A list of subscription IDs that are auto-approved for private endpoint creation."
  type        = list(string)
  default     = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
}

variable "admin_password" {
  description = "The password for the local admin account for the VMs."
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "The username for the local admin account for the VMs."
  type        = string
  default     = "azureuser"
}