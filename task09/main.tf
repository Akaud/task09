data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = local.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "afw" {
  source              = "./modules/afw"
  prefix              = var.prefix
  location            = var.location
  vnet_name           = data.azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.rg.name
  aks_subnet_id       = data.azurerm_subnet.aks_subnet.id
  public_ip_name      = local.public_ip_name
  aks_loadbalancer_ip = var.aks_loadbalancer_ip
  vnet_address_space  = data.azurerm_virtual_network.vnet.address_space
  aks_subnet_name     = data.azurerm_subnet.aks_subnet.name
  aks_cluster_name    = local.aks_cluster_name 
}