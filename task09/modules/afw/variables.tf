variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the existing resource group."
  type        = string
}

variable "vnet_name" {
  description = "The name of the existing virtual network."
  type        = string
}

variable "aks_subnet_name" {
  description = "The name of the existing AKS subnet."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space of the existing virtual network."
  type        = list(string)
}

variable "aks_loadbalancer_ip" {
  description = "Public IP address of the AKS load balancer."
  type        = string
}

variable "prefix" {
  description = "A unique identifier for resource naming."
  type        = string
}

variable "public_ip_name" {
  description = "Name for the Azure Firewall Public IP address."
  type        = string
}

variable "aks_cluster_name" {
  description = "The name of your AKS cluster."
  type        = string
}