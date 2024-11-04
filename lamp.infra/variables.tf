variable "project_name" {
  type = string
  default = "lamp_stack"
}

variable "project_location" {
  type = string
  default = "West Us"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "address_space" {
  type = list(string)
  default = [ "10.21.0.0/16" ]
}

variable "address_prefixes" {
  type = list(string)
  default = [ "10.21.0.0/24", "10.21.1.0/24" ]
}

variable "vm_size" {
  type = string
  default = "Standard_B4ms"
}
variable "open_ports" {
  type = list(number)
  default = [ 80, 22, 8080, 3306 ]
}