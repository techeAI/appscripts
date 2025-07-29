variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-094b5b539e1023ba3"
}

variable "biztechami_id" {
  description = "BizTech AMI (included Container Image) ID for the EC2 instance"
  default     = "ami-060d8dd2f09f541e9"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.large"
}
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

# Uncomment incase existing IP to use
variable "existing_eip_allocation_id" {
  description = "Allocation ID of the existing Elastic IP"
  type        = string
}