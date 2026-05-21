output "fitness_private_ip" {
  value = azurerm_network_interface.fitness_nic.ip_configuration[0].private_ip_address
}

output "organic_private_ip" {
  value = azurerm_network_interface.organic_nic.ip_configuration[0].private_ip_address
}
