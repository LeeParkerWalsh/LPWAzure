output "automation_account_id" {
  value = azurerm_automation_account.lpwauto.identity.0.principal_id
}