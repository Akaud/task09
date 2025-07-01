data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = local.firewall_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "firewall_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
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
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  dns_proxy_enabled   = true
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }
}

resource "azurerm_route_table" "rt" {
  name                = local.route_table_name
  resource_group_name = var.resource_group_name
  location            = var.location
  route {
    name                   = "default-route-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.afw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = data.azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_firewall_application_rule_collection" "app_rule_collection" {
  name                = local.app_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"
  dynamic "rule" {
    for_each = local.application_rules
    content {
      name             = rule.value.name
      fqdn_tags        = ["AzureKubernetesService"]
      source_addresses = [data.azurerm_subnet.aks_subnet.address_prefixes[0]]
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "net_rule_collection" {
  name                = local.net_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"
  dynamic "rule" {
    for_each = local.network_rules
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
    }
  }
}

resource "azurerm_firewall_nat_rule_collection" "nat_rule_collection" {
  name                = local.nat_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = 300
  action              = "Dnat"
  dynamic "rule" {
    for_each = local.nat_rules
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      translated_address    = rule.value.translated_address
      translated_port       = rule.value.translated_port
      protocols             = rule.value.protocols
    }
  }
}