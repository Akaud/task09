variable "resource_group_name" {
  description = "The name of the existing resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the existing virtual network."
  type        = string
}

variable "aks_subnet_id" {
  description = "The ID of the existing AKS subnet."
  type        = string
}

variable "aks_subnet_name" {
  description = "The name of the existing AKS subnet."
  type        = string
}

variable "aks_loadbalancer_ip" {
  description = "Public IP address of the AKS load balancer."
  type        = string
}

variable "firewall_public_ip_name" {
  description = "The name for the Azure Firewall Public IP."
  type        = string
}

variable "prefix" {
  description = "The common prefix for resource naming."
  type        = string
}