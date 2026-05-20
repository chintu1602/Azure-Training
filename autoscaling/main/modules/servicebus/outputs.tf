output "topic_id" {
  value = azurerm_servicebus_topic.topic.id
}

output "namespace_id" {
  value = azurerm_servicebus_namespace.sb.id
}