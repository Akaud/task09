locals {
  firewall_subnet_name     = "AzureFirewallSubnet"
  firewall_name            = format("%s-afw", var.prefix)
  route_table_name         = format("%s-rt", var.prefix)
  app_rule_collection_name = format("%s-arc", var.prefix)
  net_rule_collection_name = format("%s-nrc", var.prefix)
  nat_rule_collection_name = format("%s-natrc", var.prefix)
  application_rules = [
    {
      name = "AllowWeb"
      protocols = [
        { port = 80, type = "Http" },
        { port = 443, type = "Https" }
      ]
    }
  ]
  network_rules = [
    {
      name = "AllowAllOutbound"
    }
  ]

  nat_rules = [
    {
      name = "NginxLoadBalancerAccess"
    }
  ]
}