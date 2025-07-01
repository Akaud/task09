locals {
  firewall_subnet_name     = "AzureFirewallSubnet"
  firewall_name            = format("%s-afw", var.prefix)
  route_table_name         = format("%s-rt", var.prefix)
  app_rule_collection_name = format("%s-arc", var.prefix)
  net_rule_collection_name = format("%s-nrc", var.prefix)
  nat_rule_collection_name = format("%s-natrc", var.prefix)
  application_rules = [
    {
      name         = "AllowNginxHttp"
      target_fqdns = ["*"]
      protocols = [
        { port = "80", type = "Http" },
        { port = "443", type = "Https" }
      ]
    }
  ]

  network_rules = [
    {
      name                  = "AllowOutboundDNS"
      source_addresses      = data.azurerm_subnet.aks_subnet.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols             = ["UDP", "TCP"]
    },
    {
      name                  = "AllowOutboundHttps"
      source_addresses      = data.azurerm_subnet.aks_subnet.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    },
    {
      name                  = "AllowAzureServices"
      source_addresses      = data.azurerm_subnet.aks_subnet.address_prefixes
      destination_addresses = ["AzureCloud"]
      destination_ports     = ["*"]
      protocols             = ["TCP"]
    }
  ]

  nat_rules = [
    {
      name                  = "NginxLoadBalancerAccess"
      source_addresses      = ["*"]
      destination_addresses = [azurerm_public_ip.firewall_public_ip.ip_address]
      destination_ports     = ["80"]
      translated_address    = var.aks_loadbalancer_ip
      translated_port       = "80"
      protocols             = ["TCP"]
    }
  ]
}