provider "aws" {
  region = "us-east-1"
}

# Backup Vault
resource "aws_backup_vault" "default" {
  name = "my-backup-vault"
}

# Backup Plan
resource "aws_backup_plan" "ec2_plan" {
  name = "ec2-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.default.name
    schedule          = "cron(0 0 ? * * *)" # Every day at midnight UTC
    lifecycle {
      delete_after = 7 # Retain last 7 days
    }
  }

  rule {
    rule_name         = "weekly-backup"
    target_vault_name = aws_backup_vault.default.name
    schedule          = "cron(0 0 ? * 7 SAT *)" # Every Saturday
    lifecycle {
      delete_after = 28 # Retain last 4 weeks
    }
  }

  rule {
    rule_name         = "monthly-backup"
    target_vault_name = aws_backup_vault.default.name
    schedule          = "cron(0 0 1 * ? *)" # 1st day of every month
    lifecycle {
      delete_after = 365 # 12 months
    }
  }

  rule {
    rule_name         = "yearly-backup"
    target_vault_name = aws_backup_vault.default.name
    schedule          = "cron(0 0 1 1 ? *)" # January 1st
    lifecycle {
      delete_after = 1825 # 5 years
    }
  }
}