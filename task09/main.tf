data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "afw" {
  source                     = "./modules/afw"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = var.location
  virtual_network_name       = data.azurerm_virtual_network.vnet.name
  aks_subnet_id              = data.azurerm_subnet.aks_subnet.id
  aks_subnet_name            = var.aks_subnet_name
  aks_loadbalancer_ip        = var.aks_loadbalancer_ip
  firewall_public_ip_name    = var.firewall_public_ip_name
  prefix                     = local.prefix
  aks_cluster_name           = var.aks_cluster_name
}