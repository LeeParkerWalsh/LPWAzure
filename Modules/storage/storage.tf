resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
}

resource "azurerm_storage_share" "FSShare" {
  name                 = "lpwtestfiles"
  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]
  quota                = 50
}

resource "azurerm_role_assignment" "automation_account_files" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = var.auto_principal_id
}

resource "azurerm_storage_share_directory" "directory" {
  name             = "hellodirectory"
  storage_share_id = azurerm_storage_share.FSShare.id
}

resource "azurerm_storage_share_file" "helloworld" {
  name             = "helloworld.txt"
  storage_share_id = azurerm_storage_share.FSShare.id
  path             = azurerm_storage_share_directory.directory.name
  source           = "./scripts/helloworld.txt"
}