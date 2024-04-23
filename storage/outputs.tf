output "storage_account_name" {
  description = "The Storage Account Name."
  value       = azurerm_storage_account.storage.name
}

output "storage_key_secret" {
  value     = azurerm_storage_account.storage.primary_access_key
  sensitive = true
}
