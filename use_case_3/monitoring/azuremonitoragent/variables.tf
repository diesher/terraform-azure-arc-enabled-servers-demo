variable "resource_group_name" {
  description = "Resource group Name der Logic App"
  type        = string
}

variable "location" {
  description = "Azure Location"
  type        = string
  default     = "westeurope"
}

variable "workspaceName" {
  description = "Name des Log Analytics Workspace"
  type        = string
}

#variable "arm_file_path" {
#  description = "die Configuration Parametern der Logic App Workflow Definition"
#  type = string
#}

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


