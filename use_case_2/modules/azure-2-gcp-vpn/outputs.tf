# Outputs
output "ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "vnet_address_range" {
  value = azurerm_virtual_network.vnet.address_space
}