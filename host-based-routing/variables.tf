variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_cidr" {
  type = string

}

variable "backend_subnet_cidr" {
  type = string
}

variable "gateway_subnet_cidr" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "fitness_hostname" {
  type = string
}

variable "organic_hostname" {
  type = string
}

