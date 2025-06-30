locals {
  firewall_subnet_name       = "AzureFirewallSubnet"
  firewall_subnet_address_prefix = "10.0.1.0/24"
  firewall_name              = format("%s-afw", var.prefix)
  route_table_name           = format("%s-rt", var.prefix)
  app_rule_collection_name   = format("%s-arc", var.prefix)
  net_rule_collection_name   = format("%s-nrc", var.prefix)
  nat_rule_collection_name   = format("%s-natrc", var.prefix)
}