terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.47.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "proxmox" {
  endpoint = var.pm_api_url
  username = var.pm_user
  password = var.pm_password
  insecure = true
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/maestro.key"
  file_permission = "0400"
}

locals {
  ssh_public_key = tls_private_key.ssh.public_key_openssh
}

resource "proxmox_virtual_environment_vm" "maestro" {
  name      = "biztechapps-vm"
  node_name = var.pm_target_node

  clone {
    vm_id = var.template_vm_id
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.pm_storage
    size         = 60
  }

  network_device {
    model    = "virtio"
    bridge   = "vmbr0"
    ipv4     = {
      mode = "dhcp"
    }
  }

  agent {
    enabled = true
  }

  initialization {
    user_account {
      username = "ubuntu"
      password = var.vm_password
      keys     = [local.ssh_public_key]
    }

    dns {
      domain  = "local"
      servers = ["8.8.8.8"]
    }

    ip_config {
      ipv4 {
        mode = "dhcp"
      }
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /mnt/DriveDATA",
      "sudo mkfs.ext4 /dev/sdb",
      "echo '/dev/sdb /mnt/DriveDATA ext4 defaults 0 0' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "mkdir -p /mnt/DriveDATA/Deploy-config",
      "curl -o /mnt/DriveDATA/Deploy-config/deploy-maestroapp.sh https://raw.githubusercontent.com/techeAI/appscripts/main/Terraform/AWS-Cloud/deploy-maestroapp.sh",
      "chmod +x /mnt/DriveDATA/Deploy-config/deploy-maestroapp.sh",
      "/mnt/DriveDATA/Deploy-config/deploy-maestroapp.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh.private_key_pem
      host        = self.ipv4_addresses[0]
    }
  }
}
