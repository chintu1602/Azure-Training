variable "rg_name" {
    type = string
}
variable "location" {
    type = string
}
variable "vnet_name" {
    type = string
}
variable "vnet_address_space" {
    type = list(string)
}
variable "subnet_name" {
    type = string
}
variable "subnet_prefix" {
    type = list(string)
}
variable "lb_name" {
    type = string
}
variable "lb_pubip" {
    type = string
}
variable "vmss_name" {
    type = string
}
variable "admin_username" {
    type = string
}
variable "admin_password" {
    type = string
}
variable "autoscale_name" {
    type = string
}
variable "email_address" {
    type = string
}
