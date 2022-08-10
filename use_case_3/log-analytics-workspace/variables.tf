
variable "logw_rg_name" {
  type = string
  description = "(Required) Monitoring resource group name in which the monitoring resources are created."
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "log_analytics_workspace_name" {
  type = string
  description = "(Required) Specifies the name of the Log Analytics Workspace. Workspace name should include 4-63 letters, digits or '-'"
}

variable "sku" {
  description = "Sku ofLog Analytics Workspace."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Datenretention-Zeit in Tage. Möglicher Wertebereich zwischen 30 und 730."
  type        = number
  default     = 30
}

variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "tenant_id" {
}
