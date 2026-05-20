resource "azurerm_monitor_action_group" "action" {
  name                = "traffic-action-group"
  resource_group_name = var.rg_name
  short_name          = "trafficag"

  email_receiver {
    name          = "email-alert"
    email_address = var.email_address
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "high-cpu-alert"
  resource_group_name = var.rg_name
  scopes              = [var.vmss_id]
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}