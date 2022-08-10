variable "resource_group_name" {
  description = "Resource group Name der Logic App"
  type        = string
}

variable "location" {
  description = "Azure Location"
  type        = string
  default     = "westeurope"
}

variable "emailAddress" {
  type = string
  description = "Emailadresse für die Alerts"
}


variable "workspaceName" {
  description = "Name des Log Analytics Workspace"
  type        = string
}

variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "tenant_id" {
}


