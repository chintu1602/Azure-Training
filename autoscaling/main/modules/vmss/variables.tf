variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vmss_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "backend_pool_id" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}