variable "location" {
  type        = string
  description = "location for resources"
}
variable "resource_group_name" {
  type        = string
  description = "resource group name"
}
variable "automation_account_name" {
  type        = string
  description = "name of the automation account"
}
variable "schedule_name" {
  type        = string
  description = "name of the schedule within automation account"
}
variable "runbook_name" {
  type        = string
  description = "name of the runbook"
}
variable "autovars" {
  type        = list(object({ name = string, value = string }))
  description = "list of variables for automation account"
}
variable "webhookURI" {
  type        = string
  description = "address of webhook used within automation for send message"
}
