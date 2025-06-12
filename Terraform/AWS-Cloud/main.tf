provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  key_name_suffix = formatdate("YYYY-MM-DD-HH-mm", timestamp())
  key_name        = "maestro-${local.key_name_suffix}"
  key_file        = "${path.module}/${local.key_name}.key"
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = local.key_file
  file_permission = "0400"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
}

resource "aws_security_group" "maestro_sg" {
  name        = "maestro-sg"
  description = "maestro-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami                    = var.biztechami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.maestro_sg.id]
  subnet_id = data.aws_subnet.default.id
  root_block_device {
    volume_size = 60
    volume_type = "gp2"
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = true
    
  }

user_data = <<-EOF
            #!/bin/bash
            # Save logs for debugging
            exec > /var/log/user-data.log 2>&1
            set -x  # Enable debug mode

            # Format and mount the additional EBS volume
            mkfs -t ext4 /dev/xvdf
            mkdir -p /mnt/DriveDATA
            echo "/dev/xvdf /mnt/DriveDATA ext4 defaults,nofail 0 0" >> /etc/fstab
            mount -a

            # Create directory for deployment script
            mkdir -p /mnt/DriveDATA/Deploy-config

            # Save the urls.conf file
            cat << 'EODEPLOY1' > /mnt/DriveDATA/Deploy-config/urls.conf
            ${replace(file("${path.module}/urls.conf"), "$", "$$")}
            EODEPLOY1
             
            # Save the deploy-maestroapp.sh script
            curl -o /mnt/DriveDATA/Deploy-config/deploy-maestroapp.sh https://raw.githubusercontent.com/techeAI/appscripts/main/Terraform/AWS-Cloud/deploy-maestroapp.sh

              chmod +x /mnt/DriveDATA/Deploy-config/deploy-maestroapp.sh
              /mnt/DriveDATA/Deploy-config/deploy-maestroapp.sh
            EOF

  tags = {
    Name = "Maestro-EC2"
  }
}

#Cretae IP Block start (incase want to create new IP and attach to instance)
/*
resource "aws_eip" "maestro_ip" {
  instance = aws_instance.example.id
  domain = "vpc"
}
*/
#Cretae IP Block end

# Use Existing IP Block start (incase want to use existing/reserved IP)
resource "aws_eip_association" "maestro_ip_assoc" {
  instance_id   = aws_instance.example.id
  allocation_id = var.existing_eip_allocation_id
}
data "aws_eip" "existing" {
  id = var.existing_eip_allocation_id
}
# Use Existing IP BLock end