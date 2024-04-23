variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "automation_account_name" {
  type = string
}
variable "schedule_name" {
  type = string
}
variable "runbook_name" {
  type = string
}
variable "autovars" {
  type = list(object({ name = string, value = string }))
}