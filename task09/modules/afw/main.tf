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
  allocation_method   = local.firewall_pip_allocation_method
  sku                 = local.firewall_pip_sku

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "afw" {
  name                = local.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = local.firewall_sku_name
  sku_tier            = local.firewall_sku_tier

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
    name                   = local.default_route_name
    address_prefix         = local.default_route_address_prefix
    next_hop_type          = local.default_route_next_hop_type
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
  priority            = local.app_rule_collection_priority
  action              = local.app_rule_collection_action

  dynamic "rule" {
    for_each = local.application_rules
    content {
      name             = rule.value.name
      source_addresses = rule.value.source_addresses
      target_fqdns     = rule.value.target_fqdns
      dynamic "protocol" {
        for_each = rule.value.protocols
        content {
          port = protocol.value.port
          type = protocol.value.type
        }
      }
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "net_rule_collection" {
  name                = local.net_rule_collection_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.resource_group_name
  priority            = local.net_rule_collection_priority
  action              = local.net_rule_collection_action

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
  priority            = local.nat_rule_collection_priority
  action              = local.nat_rule_collection_action

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

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_network_security_group" "aks_nsg" {
  name                = local.aks_nsg_name
  resource_group_name = data.azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

resource "azurerm_network_security_rule" "allow_firewall_to_loadbalancer" {
  name                        = local.nsg_rule_name
  priority                    = local.nsg_rule_priority
  direction                   = local.nsg_rule_direction
  access                      = local.nsg_rule_access
  protocol                    = local.nsg_rule_protocol
  source_port_range           = local.nsg_rule_source_port_range
  destination_port_range      = local.nsg_rule_destination_port_range
  source_address_prefix       = azurerm_public_ip.firewall_pip.ip_address
  destination_address_prefix  = var.aks_loadbalancer_ip
  resource_group_name         = data.azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  network_security_group_name = data.azurerm_network_security_group.aks_nsg.name
}
