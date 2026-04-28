terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.66.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "hmstorage2026"
    container_name       = "homiescontainer"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = "45ab7c0b-0483-4cfa-b5bb-498a103b8661"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999

  # Това казва на Terraform да създава нов ресурс при всяко apply
  lifecycle {
    replace_triggered_by = [
      # Можеш да добавиш timestamp или друга променлива
    ]
  }
}
resource "terraform_data" "trigger" {
  input = timestamp()
}

resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = "switzerlandnorth"
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_mssql_server" "ams" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "amd" {
  name                 = var.sql_database_name
  server_id            = azurerm_mssql_server.ams.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Local"
}

resource "azurerm_mssql_firewall_rule" "firewallrule" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.ams.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false

    app_command_line = "dotnet Homies.dll"
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.ams.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.amd.name};User ID=${azurerm_mssql_server.ams.administrator_login};Password=thisIsKat11!23;Trusted_Connection=False;MultipleActiveResultSets=True;Encrypt=True;"
  }
}

#source "azurerm_app_service_source_control" "assc" {
# app_id                 = azurerm_linux_web_app.alwa.id
#repo_url               = var.github_repository_url
# branch                 = "main"
# use_manual_integration = false
#}

output "web_app_name" {
  description = "The name of the deployed web app"
  value       = azurerm_linux_web_app.alwa.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.arg.name
}

output "random_suffix" {
  description = "The random suffix used for resources"
  value       = random_integer.ri.result
}