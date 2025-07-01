locals {
  rg_name          = format("%s-rg", var.prefix)
  vnet_name        = format("%s-vnet", var.prefix)
  subnet_name      = "aks-snet"
  aks_cluster_name = format("%s-aks", var.prefix)
  public_ip_name   = format("%s-pip", var.prefix)
}