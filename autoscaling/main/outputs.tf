output "vmss_id" {
  value = module.vmss.vmss_id
}

output "subnet_id" {
  value = module.network.subnet_id
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "lb_public_ip" {
  value = module.lb.public_ip
}

output "autoscale_name" {
  value = module.autoscale.autoscale_name
}

output "alert_name" {
  value = module.monitor.alert_name
}

output "servicebus_topic_id" {
  value = module.servicebus.topic_id
}