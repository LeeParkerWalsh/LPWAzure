
resource "azurerm_automation_account" "lpwauto" {
  name                = var.automation_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }

  sku_name = "Basic"
}

resource "azurerm_automation_variable_string" "autovariables" {
  for_each = { for autovar in var.autovars : autovar.name => autovar }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = each.value.value
}

data "local_file" "script" {
  filename = "./scripts/filemodified.ps1"
}

resource "azurerm_automation_runbook" "filemodified" {
  name                    = var.runbook_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = "false"
  log_progress            = "false"
  description             = "Runbook to check when file last modified"
  runbook_type            = "PowerShell72"

  content = data.local_file.script.content
}

resource "azurerm_automation_schedule" "autoschedule" {
  name                    = var.schedule_name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = "Week"
  interval                = 1
  description             = "Weekly Schedule"
  week_days               = ["Sunday"]
}

resource "azurerm_automation_job_schedule" "autojobschedule" {
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = var.schedule_name
  runbook_name            = var.runbook_name
  depends_on = [
    azurerm_automation_schedule.autoschedule,
    azurerm_automation_runbook.filemodified
  ]
}
