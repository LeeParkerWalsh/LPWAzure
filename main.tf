resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "automation" {
  source                  = "./Modules/automation"
  resource_group_name     = var.resource_group_name
  location                = var.location
  schedule_name           = var.schedule_name
  runbook_name            = var.runbook_name
  automation_account_name = var.automation_account_name
  autovars                = var.autovars
}

module "storage" {
  depends_on = [
    azurerm_resource_group.rg
  ]
  source                           = "./Modules/storage"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  storage_account_name             = var.storage_account_name
  storage_account_tier             = "Standard"
  storage_account_replication_type = "LRS"
  auto_principal_id                = module.automation.automation_account_id
}
