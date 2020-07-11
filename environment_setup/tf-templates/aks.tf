resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix = "${var.base_name}-${terraform.workspace}-aks01"
  location = var.location
  name = "${var.base_name}-${terraform.workspace}-aks01"
  resource_group_name = var.resource_group
  default_node_pool {
    name = "small"
    vm_size = var.vm_size
    node_count = 3
  }
  identity {
    type = "SystemAssigned"
  }
  addon_profile{
    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_workspace.id
    }
    http_application_routing {
      enabled = false
    }
    aci_connector_linux {
      enabled = false
    }
    kube_dashboard {
      enabled = true
    }
    azure_policy {
      enabled = false
    }
  }
}

resource "azurerm_log_analytics_workspace" "aks_workspace" {
  name                = "${var.base_name}-${terraform.workspace}-ws"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
