
# Das Deployment eines ARM Templates
resource "azurerm_resource_group_template_deployment" "automanage_deployment" {
  resource_group_name = var.resource_group_name
  # Die Funktion filemd5 zwingt ein Re-Deployment wenn es eine Änderung in der Datei gibt
  # Damit wird sichergestellt dass der Workflow immer aktuell ist.
  name               = "automanage-${filemd5(local.arm_file_path)}"
  template_content   = file(local.arm_file_path)
  deployment_mode    = "Incremental"
  parameters_content = jsonencode(local.arm_parameters)
}

