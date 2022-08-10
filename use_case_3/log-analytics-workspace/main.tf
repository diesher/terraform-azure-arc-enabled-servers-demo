

#-------------------------------
# Log Analytics Workspace
#-------------------------------
resource "azurerm_log_analytics_workspace" "logs" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.logw_rg.location
  resource_group_name = data.azurerm_resource_group.logw_rg.name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}


