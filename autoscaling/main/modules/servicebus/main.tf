resource "azurerm_servicebus_namespace" "sb" {
  name                = "organic-servicebus-ns"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "topic" {
  name         = "traffic-topic"
  namespace_id = azurerm_servicebus_namespace.sb.id
}

resource "azurerm_servicebus_subscription" "subscription" {
  name     = "email-subscription"
  topic_id = azurerm_servicebus_topic.topic.id
  max_delivery_count = 10
}