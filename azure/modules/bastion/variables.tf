variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "az_region" {
  description = "Azure region where the deployment machines will be created"
  type    = string
  default = "westeurope"
}

variable "vm_size" {
  description = "Bastion machine vm size"
  type        = string
  default     = "Standard_B1s"
}

variable "resource_group_name" {
  description = "Resource group name where the bastion will be created"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network where the bastion subnet will be created"
  type        = string
}

variable "snet_address_range" {
  description = "Subnet address range of the bastion subnet"
}

variable "storage_account" {
  description = "Storage account where the boot diagnostics will be stored"
  type = string
}
