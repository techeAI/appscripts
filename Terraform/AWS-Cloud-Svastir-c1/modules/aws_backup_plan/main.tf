resource "aws_backup_vault" "this" {
  name = var.vault_name
}

resource "aws_backup_plan" "this" {
  name = var.plan_name

  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name         = rule.value.name
      target_vault_name = aws_backup_vault.this.name
      schedule          = rule.value.schedule
      lifecycle {
        delete_after = rule.value.retention
      }
    }
  }
}

resource "aws_backup_selection" "this" {
  count         = length(var.resource_arns) > 0 ? 1 : 0
  name          = "${var.plan_name}-selection"
  iam_role_arn  = var.iam_role_arn
  plan_id       = aws_backup_plan.this.id
  resources     = var.resource_arns
}