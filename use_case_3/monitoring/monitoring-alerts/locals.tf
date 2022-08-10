locals {
  arm_file_path = "${path.module}/arm-templates/monitoring-template.json"
  parameters = merge({
    "workspaceName"   = var.workspaceName
    "location"      = var.location
    "emailAddress"    = var.emailAddress
    },

  )

  arm_parameters = {
    for key, value in local.parameters :
    key => { "value" = value }
  }
}