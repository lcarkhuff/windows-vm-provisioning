#terraform build variables


variable "vsphere_server" { type = string }
variable "vsphere_user" { type = string }

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "allow_unverified_ssl" {
  type    = bool
  default = true
}

variable "datacenter" { type = string }
variable "cluster" { type = string }
variable "datastore" { type = string }
variable "network" { type = string }

variable "template_name" { type = string }

variable "vm_name" { type = string }
variable "vm_folder" { type = string }

variable "cpu" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 4096
}

variable "disk_gb" {
  type    = number
  default = null
}

variable "ip_address" {
  type = string
}

variable "subnet_mask" {
  type = number
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}


variable "domain_name" { type = string }

variable "domain_ou" { type = string } # "OU=Servers,DC=vermeermfg,DC=com"

variable "local_admin_user" { type = string }

variable "local_admin_password" {
  type      = string
  sensitive = true
}
