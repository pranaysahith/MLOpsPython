provider "azurerm" {
  version = "=2.7.0"
  features {}
}

#--------------------------------------------------------------------------------

#Set the already-existing resource group
resource "azurerm_resource_group" "amlrg" {
  name     = var.resource_group
  location = var.location
}

#Set client config for a.o. tenant id
data "azurerm_client_config" "currentconfig" {
}

#--------------------------------------------------------------------------------

# Storage account for AML Service
resource "azurerm_storage_account" "amlstor" {
  name                     = "${var.base_name}amlsa${terraform.workspace}"
  location                 = azurerm_resource_group.amlrg.location
  resource_group_name      = azurerm_resource_group.amlrg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Keyvault for AML Service
resource "azurerm_key_vault" "amlkv" {
  name                = "${var.base_name}-AML-KV-${terraform.workspace}"
  location            = azurerm_resource_group.amlrg.location
  resource_group_name = azurerm_resource_group.amlrg.name
  tenant_id           = data.azurerm_client_config.currentconfig.tenant_id
  sku_name            = "standard"
}

# App Insights for AML Service
resource "azurerm_application_insights" "amlai" {
  name                = "${var.base_name}-AML-AI-${terraform.workspace}"
  location            = azurerm_resource_group.amlrg.location
  resource_group_name = azurerm_resource_group.amlrg.name
  application_type    = "web"
}

# Container registry for AML Service
resource "azurerm_container_registry" "amlacr" {
  name                = "${var.base_name}amlcr${terraform.workspace}"
  resource_group_name = azurerm_resource_group.amlrg.name
  location            = azurerm_resource_group.amlrg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# ML Workspace for AML Service, depending on the storage account, Keyvault, App Insights and ACR.
resource "azurerm_machine_learning_workspace" "amlws" {
  name                    = "${var.workspace_name}-${terraform.workspace}"
  location                = azurerm_resource_group.amlrg.location
  resource_group_name     = azurerm_resource_group.amlrg.name
  application_insights_id = azurerm_application_insights.amlai.id
  key_vault_id            = azurerm_key_vault.amlkv.id
  storage_account_id      = azurerm_storage_account.amlstor.id
  container_registry_id   = azurerm_container_registry.amlacr.id

  identity {
    type = "SystemAssigned"
  }
}
