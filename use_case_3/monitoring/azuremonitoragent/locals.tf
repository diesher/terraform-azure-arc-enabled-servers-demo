
locals {
  arm_file_path = "${path.module}/arm-templates/ama-windows-template.json"
  parameters = merge({
    "workspaceName"   = var.workspaceName
    "location"      = var.location
    "vmName"        = var.vm_name
    },

  )

  arm_parameters = {
    for key, value in local.parameters :
    key => { "value" = value }
  }
}
