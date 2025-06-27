variable "vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "rules" {
  description = "List of backup rules with name, schedule and retention"
  type = list(object({
    name      = string
    schedule  = string
    retention = number
  }))
}

variable "resource_arns" {
  description = "List of resource ARNs to include in the backup selection"
  type        = list(string)
  default     = []
}

variable "iam_role_arn" {
  description = "IAM role ARN to use for backup"
  type        = string
}