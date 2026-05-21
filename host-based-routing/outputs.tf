output "resource_group_name" {
  value = module.rg.name
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "fitness_private_ip" {
  value = module.vm.fitness_private_ip
}

output "organic_private_ip" {
  value = module.vm.organic_private_ip
}

output "application_gateway_public_ip" {
  value = module.agw.public_ip
}

output "hosts_file_entry" {
  value = "${module.agw.public_ip != null ? module.agw.public_ip : "<AGW_PUBLIC_IP>"} ${var.fitness_hostname} ${var.organic_hostname}"
}
