variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the existing resource group."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the existing virtual network."
  type        = string
}

variable "virtual_network_address_space" {
  description = "The address space of the existing virtual network."
  type        = list(string)
}

variable "aks_subnet_name" {
  description = "The name of the existing AKS subnet."
  type        = string
}

variable "aks_subnet_address_space" {
  description = "The address space of the existing AKS subnet."
  type        = list(string)
}

variable "aks_cluster_name" {
  description = "The name of the existing AKS cluster."
  type        = string
}

variable "aks_loadbalancer_ip" {
  description = "Public IP address of the AKS load balancer."
  type        = string
}

variable "firewall_public_ip_name" {
  description = "The name for the Azure Firewall Public IP. It should follow the naming convention."
  type        = string
}