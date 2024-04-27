variable "location" {
  type        = string
  description = "location for resources"
}
variable "resource_group_name" {
  type        = string
  description = "resource group name"
}
variable "storage_account_name" {
  type        = string
  description = "name of the storage account"
}
variable "storage_account_tier" {
  type        = string
  description = "storage account tier"
}
variable "storage_account_replication_type" {
  type        = string
  description = "storage account replication"
}
variable "auto_principal_id" {
  type        = string
  description = "Identity tied to the Automation account"
}
