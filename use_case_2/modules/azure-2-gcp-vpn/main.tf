#----------------------------------------
# Create a resource group
#----------------------------------------
resource "azurerm_resource_group" "azure_vpn_rg" {
  name     = "rg-azure-2-gcp-vpn"
  location = var.azure_location
}

#-------------------------------
# Generieren von PSK
#-------------------------------
resource "random_password" "shared_key" {
  length           = 64
  special          = true
  override_special = "_%@"
}

#----------------------------------------
# Create public ip
#----------------------------------------
resource "azurerm_public_ip" "pip" {
  name                = "pip-vpn-gw"
  location            = azurerm_resource_group.azure_vpn_rg.location
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name
  allocation_method   = "Dynamic"

}

#----------------------------------------
# Create a azure vnet and subnet
#----------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-vpn-gateway"
  location            = azurerm_resource_group.azure_vpn_rg.location
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet-gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.azure_vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/26"]
}

#----------------------------------------
# Create virtual Network gateway
#----------------------------------------
resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "azure-to-gcp-vpn"
  location            = azurerm_resource_group.azure_vpn_rg.location
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet-gw.id
  }
}

#----------------------------------------
# Create local gateway
#----------------------------------------
resource "azurerm_local_network_gateway" "local_gcp" {
  name                = "local-network-gcp"
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name
  location            = azurerm_resource_group.azure_vpn_rg.location
  gateway_address     = google_compute_address.gcp_vpn_ip.address
  address_space       = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16"
    ]
}

#----------------------------------------
# Create local gateway
#----------------------------------------

resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.azure_vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.128/26"]
}

resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-fw"
  location            = azurerm_resource_group.azure_vpn_rg.location
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "fwpolicy" {
  name                = "fwpolicy"
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name
  location            = azurerm_resource_group.azure_vpn_rg.location
  sku                 = "Premium"

  dns {
      proxy_enabled = "true"

  }
}

resource "azurerm_firewall" "firewall" {
  name                = "firewall"
  location            = azurerm_resource_group.azure_vpn_rg.location
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

#----------------------------------------
# Create VPN Connection
#----------------------------------------
resource "azurerm_virtual_network_gateway_connection" "gcp_connection" {
  name                = "onpremise"
  location            = azurerm_resource_group.azure_vpn_rg.location
  resource_group_name = azurerm_resource_group.azure_vpn_rg.name

  type                       = "IPsec"
  connection_protocol = "IKEv2"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gcp.id

  shared_key = random_password.shared_key.result
}

#----------------------------------------
# Create a public IP GCP
#----------------------------------------
resource "google_compute_network" "network" {
  name = "gcp-network"
}

#----------------------------------------
# Create a public IP GCP
#----------------------------------------

resource "google_compute_address" "gcp_vpn_ip" {
  name = "gcp-vpn-pip"
  region = var.gcp_region

}

#----------------------------------------
# Create a gcp vpn gateway
#----------------------------------------
resource "google_compute_vpn_gateway" "gcp_vpn_gateway" {
  name    = "gcp-vpn-gw"
  network = google_compute_network.network.id
  region = var.gcp_region
}

#----------------------------------------
# Create loose forwarding rules
#----------------------------------------
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gcp_vpn_ip.address
  target      = google_compute_vpn_gateway.gcp_vpn_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.gcp_vpn_ip.address
  target      = google_compute_vpn_gateway.gcp_vpn_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.gcp_vpn_ip.address
  target      = google_compute_vpn_gateway.gcp_vpn_gateway.id
}

#----------------------------------------
# Create gcp vpn tunnel
#----------------------------------------
resource "google_compute_vpn_tunnel" "tunnel" {
  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
    azurerm_public_ip.pip
  ]

  name          = "gcp-vpn-tunnel"
#  peer_ip       = azurerm_public_ip.pip.ip_address
  shared_secret = random_password.shared_key.result

  target_vpn_gateway = google_compute_vpn_gateway.gcp_vpn_gateway.id


}

#----------------------------------------
# Create gcp route
#----------------------------------------

resource "google_compute_route" "route" {
  name       = "route1"
  network    = google_compute_network.network.name
  dest_range = "10.0.0.0/16"
  priority   = 100

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
}


