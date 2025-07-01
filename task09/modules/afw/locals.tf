locals {
  firewall_subnet_name           = "AzureFirewallSubnet"
  firewall_subnet_address_prefix = "10.0.1.0/24"
  firewall_name                  = format("%s-afw", var.prefix)
  route_table_name               = format("%s-rt", var.prefix)

  firewall_pip_allocation_method = "Static"
  firewall_pip_sku               = "Standard"

  firewall_sku_name = "AZFW_VNet"
  firewall_sku_tier = "Standard"

  aks_nsg_name = "aks-agentpool-22974405-nsg"

  default_route_name           = "default-route-to-firewall"
  default_route_address_prefix = "0.0.0.0/0"
  default_route_next_hop_type  = "VirtualAppliance"

  app_rule_collection_name = format("%s-arc", var.prefix)
  net_rule_collection_name = format("%s-nrc", var.prefix)
  nat_rule_collection_name = format("%s-natrc", var.prefix)

  app_rule_collection_priority = 100
  app_rule_collection_action   = "Allow"

  net_rule_collection_priority = 200
  net_rule_collection_action   = "Allow"

  nat_rule_collection_priority = 300
  nat_rule_collection_action   = "Dnat"

  nsg_rule_name                   = "AllowAccessFromFirewallPublicIPToLoadBalancerIP"
  nsg_rule_priority               = 400
  nsg_rule_direction              = "Inbound"
  nsg_rule_access                 = "Allow"
  nsg_rule_protocol               = "*"
  nsg_rule_source_port_range      = "*"
  nsg_rule_destination_port_range = "80"

  dynamic_aks_nsg_name = length(data.azurerm_resources.aks_nsgs_in_node_rg.resources) > 0 ? (
    data.azurerm_resources.aks_nsgs_in_node_rg.resources[0].name
  ) : ""

  application_rules = [
    {
      name             = "AllowNginxHttp"
      source_addresses = [data.azurerm_subnet.aks_subnet_details.address_prefixes[0]]
      target_fqdns     = ["nginx.org", "www.nginx.org"]
      protocols = [
        { port = "80", type = "Http" },
        { port = "443", type = "Https" }
      ]
    }
  ]

  network_rules = [
    {
      name                  = "AllowOutboundDNS"
      source_addresses      = data.azurerm_subnet.aks_subnet_details.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols             = ["UDP", "TCP"]
    },
    {
      name                  = "AllowOutboundHttps"
      source_addresses      = data.azurerm_subnet.aks_subnet_details.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    },
    {
      name                  = "AllowAzureServices"
      source_addresses      = data.azurerm_subnet.aks_subnet_details.address_prefixes
      destination_addresses = ["AzureCloud"]
      destination_ports     = ["*"]
      protocols             = ["TCP"]
    }
  ]

  nat_rules = [
    {
      name                  = "NginxLoadBalancerAccess"
      source_addresses      = ["*"]
      destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]
      destination_ports     = ["80"]
      translated_address    = var.aks_loadbalancer_ip
      translated_port       = "80"
      protocols             = ["TCP"]
    }
  ]
}
