
locals {
  arm_file_path = "${path.module}/arm-templates/customscript-templatewindows.json"
  parameters = merge({
    "fileUris"   = var.fileUris
    "location"      = var.location
    "vmName"        = var.vm_name
    },

  )

  arm_parameters = {
    for key, value in local.parameters :
    key => { "value" = value }
  }
}
