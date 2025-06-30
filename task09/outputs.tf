output "azure_firewall_public_ip" {
  description = "The Public IP address of the Azure Firewall."
  value       = module.afw.azure_firewall_public_ip
}

output "azure_firewall_private_ip" {
  description = "The Private IP address of the Azure Firewall."
  value       = module.afw.azure_firewall_private_ip
}