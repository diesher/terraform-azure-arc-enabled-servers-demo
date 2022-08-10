variable "resource_group_name" {
  description = "Resource group Name der Logic App"
  type        = string
}

variable "location" {
  description = "Azure Location"
  type        = string
  default     = "westeurope"
}

variable "fileUris" {
  type = string
  description = "fileUris"
}

variable "vm_name" {
  type = string
  description = "Name of the VM"
}

variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "tenant_id" {
}


