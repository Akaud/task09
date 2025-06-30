resource "azurerm_subnet" "firewall_subnet" {
  name                 = local.firewall_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [local.firewall_subnet_address_prefix]
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = var.firewall_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "afw" {
  name                = local.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_route_table" "firewall_route_table" {
  name                = local.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name           = "default-route-to-firewall"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.afw.ip_configuration[0].private_ip_address
  }
}

data "azurerm_subnet" "aks_subnet_details" {
  name                 = var.aks_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet_route_table_association" "aks_subnet_route_table_association" {
  subnet_id      = var.aks_subnet_id
  route_table_id = azurerm_route_table.firewall_route_table.id
}

resource "azurerm_firewall_application_rule_collection" "app_rule_collection" {
  name                = local.app_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "AllowNginxHttp"
    source_addresses = [data.azurerm_subnet.aks_subnet_details.address_prefixes[0]]
    target_fqdns     = ["nginx.org", "www.nginx.org"]
    protocol {
      port = "80"
      type = "Http"
    }
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "net_rule_collection" {
  name                = local.net_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name                  = "AllowOutboundDNS"
    source_addresses      = data.azurerm_subnet.aks_subnet_details.address_prefixes
    destination_addresses = ["*"]
    destination_ports     = ["53"]
    protocols             = ["UDP", "TCP"]
  }

  rule {
    name                  = "AllowOutboundHttps"
    source_addresses      = data.azurerm_subnet.aks_subnet_details.address_prefixes
    destination_addresses = ["*"]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
  }

  rule {
    name                  = "AllowAzureServices"
    source_addresses      = data.azurerm_subnet.aks_subnet_details.address_prefixes
    destination_addresses = ["AzureCloud.${var.location}"]
    destination_ports     = ["*"]
    protocols             = ["TCP"]
  }
}

resource "azurerm_firewall_nat_rule_collection" "nat_rule_collection" {
  name                = local.nat_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = 300
  action              = "Dnat"

  rule {
    name                = "NginxLoadBalancerAccess"
    source_addresses    = ["*"]
    destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]
    destination_ports   = ["80"]
    translated_address  = var.aks_loadbalancer_ip
    translated_port     = "80"
    protocols           = ["TCP"]
  }
}