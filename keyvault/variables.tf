variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "keyvault" {
  type = string
}
variable "auto_principal_id" {
  type = string
}
variable "storage_key_secret" {
  type = string
}
variable "storage_account_name" {
  type        = string
  description = "the storage account name"
}
