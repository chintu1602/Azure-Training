resource "azurerm_web_application_firewall_policy" "mywaf" {
  name                = "mywaf"
  resource_group_name = var.rg_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_public_ip" "agw_pip" {
  name                = "agw-pip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  frontend_port_name             = "http-port"
  frontend_ip_configuration_name = "my-frontend-ip-configuration"
  gateway_ip_configuration_name  = "my-gateway-ip-configuration"
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw"
  resource_group_name = var.rg_name
  location            = var.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.mywaf.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 3
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.gateway_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  # Fitness Backend Pool & Settings
  backend_address_pool {
    name         = "fitness-pool"
    ip_addresses = [var.fitness_vm_ip]
  }

  backend_http_settings {
    name                  = "fitness-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  # Organic Backend Pool & Settings
  backend_address_pool {
    name         = "organic-pool"
    ip_addresses = [var.organic_vm_ip]
  }

  backend_http_settings {
    name                  = "organic-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  # Listeners (Multi-site domain based)
  http_listener {
    name                           = "fitness-pool-listener"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = var.fitness_hostname
  }

  http_listener {
    name                           = "organic-pool-listener"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = var.organic_hostname
  }

  # Routing Rules
  request_routing_rule {
    name                       = "fitness-rule"
    priority                   = 102
    rule_type                  = "Basic"
    http_listener_name         = "fitness-pool-listener"
    backend_address_pool_name  = "fitness-pool"
    backend_http_settings_name = "fitness-http-settings"
  }

  request_routing_rule {
    name                       = "organic-rule"
    priority                   = 103
    rule_type                  = "Basic"
    http_listener_name         = "organic-pool-listener"
    backend_address_pool_name  = "organic-pool"
    backend_http_settings_name = "organic-http-settings"
  }
}
