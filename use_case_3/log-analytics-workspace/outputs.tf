
output "log_workspace" {
  value       = {
    log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.logs.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.workspace_id
  }
  description = "Log Analytics Workspace Resource attributes."
}
