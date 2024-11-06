# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "ansible_password" {
  type    = string
  default = "password"
}

variable "ansible_user" {
  type    = string
  default = "user"
}

variable "cpus" {
  type    = string
  default = "8"
}
variable "ram" {
  type    = string
  default = "16384"
}

variable "version" {
  type    = string
  default = "1"
}

variable "virtualbox_disk_size" {
  type    = string
  default = "81200"
}

variable "headless" {
  type    = string
}

variable "iso_checksum" {
  type    = string
}

variable "iso_url" {
  type    = string
}

variable "vm_name" {
  type    = string
}