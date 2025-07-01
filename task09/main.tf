module "afw" {
  source              = "./modules/afw"
  prefix              = var.prefix
  location            = var.location
  vnet_name           = local.vnet_name
  vnet_address_space  = var.virtual_network_address_space
  resource_group_name = local.rg_name
  public_ip_name      = local.public_ip_name
  aks_loadbalancer_ip = var.aks_loadbalancer_ip
  aks_subnet_name     = local.subnet_name
  aks_cluster_name    = local.aks_cluster_name
}