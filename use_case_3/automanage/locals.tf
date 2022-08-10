
locals {
  arm_file_path = "${path.module}/arm-templates/automanage.json"
  parameters = merge({
    "machineName"              = var.vm_name,
    "configurationProfileName" = "DevTest"
  })

  arm_parameters = {
    for key, value in local.parameters :
    key => { "value" = value }
  }
}
