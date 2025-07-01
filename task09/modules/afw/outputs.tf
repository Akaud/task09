output "azure_firewall_public_ip" {
  description = "The Public IP address of the Azure Firewall."
  value       = azurerm_public_ip.firewall_public_ip.ip_address
}

output "azure_firewall_private_ip" {
  description = "The Private IP address of the Azure Firewall."
  value       = azurerm_firewall.afw.ip_configuration[0].private_ip_address
}