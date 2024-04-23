data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                       = var.keyvault
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
}

# Give user running KVSO, necessary to write secret value
resource "azurerm_role_assignment" "key_vault_role_tf" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Grant key vault secret user to automation managed id
resource "azurerm_role_assignment" "key_vault_role_mi" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.auto_principal_id
}

resource "azurerm_key_vault_secret" "storageaccount" {
  name         = var.storage_account_name
  value        = var.storage_key_secret
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on = [
    azurerm_role_assignment.key_vault_role_tf
  ]
}
