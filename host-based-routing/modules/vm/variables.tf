variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "backend_subnet_id" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

# Application Setup Scripts
variable "fitness_setup_script" {
  type = string
}

variable "organic_setup_script" {
  type = string
}
