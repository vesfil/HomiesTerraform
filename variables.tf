variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-homies"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "spaincentral"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan name"
  default     = "asp-homies"
}

variable "web_app_name" {
  type        = string
  description = "Web App name"
  default     = "homies-app"
}

variable "sql_server_name" {
  type        = string
  description = "SQL Server name"
  default     = "sqlserver-homies"
}

variable "sql_admin_username" {
  type        = string
  description = "SQL Server admin username"
  default     = "missadministrator"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL Server admin password"
  sensitive   = true
  default     = "thisIsKat11!23" # ← Добави това, ако искаш
}

variable "sql_database_name" {
  type        = string
  description = "SQL Database name"
  default     = "Homies"
}

variable "firewall_rule_name" {
  type        = string
  description = "Firewall rule name"
  default     = "AllowAllAzureServices"
}

variable "github_repository_url" {
  type        = string
  description = "https://github.com/vesfil/HomiesTerraform"
}

variable "force_new" {
  type    = bool
  default = false
}