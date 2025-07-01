variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "virtual_network_address_space" {
  description = "The address space of the existing virtual network."
  type        = list(string)
}

variable "aks_subnet_address_space" {
  description = "The address space of the existing AKS subnet."
  type        = list(string)
}

variable "aks_loadbalancer_ip" {
  description = "Public IP address of the AKS load balancer."
  type        = string
}

variable "prefix" {
  description = "Prefix for Azure resources"
  type        = string
}