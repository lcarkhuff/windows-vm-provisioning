terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus = var.cpu
  memory   = var.memory_mb
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware = "efi"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = true
  }



  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      network_interface {
        ipv4_address = var.ip_address
        ipv4_netmask = var.subnet_mask
      }

      ipv4_gateway    = var.gateway
      dns_server_list = var.dns_servers

      windows_options {
        computer_name = var.vm_name
        join_domain   = var.domain_name
        domain_ou     = var.domain_ou

        run_once_command_list = [
          "powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand ${local.bootstrap_b64}"
        ]
      }
    }
  }
}

locals {
  bootstrap_ps = <<-PS
$ErrorActionPreference='Stop';

$u='${var.local_admin_user}';

$p=ConvertTo-SecureString '${var.local_admin_password}' -AsPlainText -Force;

if (-not (Get-LocalUser -Name $u -ErrorAction SilentlyContinue)) {
  New-LocalUser -Name $u -Password $p -PasswordNeverExpires:$true -AccountNeverExpires:$true;
};

Add-LocalGroupMember -Group 'Administrators' -Member $u -ErrorAction SilentlyContinue;

Disable-LocalUser -Name 'Administrator';
PS

  
bootstrap_b64 = textencodebase64(local.bootstrap_ps, "UTF-16LE")
}

