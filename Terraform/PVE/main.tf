terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.11"
    }
    tls = {
      source  = "hashicorp/tls"
    }
    local = {
      source  = "hashicorp/local"
    }
  }
}
provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
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

resource "proxmox_vm_qemu" "maestro" {
  name        = "maestro-vm"
  target_node = var.pm_target_node
  clone       = var.template_vm_name

  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  memory      = 4096
  disk {
    size     = "60G"
    type     = "scsi"
    storage  = var.pm_storage
  }

  ipconfig0   = "ip=dhcp"

  sshkeys     = local.ssh_public_key

  ciuser      = "ubuntu"
  cipassword  = var.vm_password

  cloudinit_cdrom_storage = var.pm_storage

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
      host        = self.ssh_host
    }
  }
}