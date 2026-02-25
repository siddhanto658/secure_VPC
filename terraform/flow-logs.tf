resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = var.flow_log_cloudwatch_log_group_name
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.project_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-flow-logs-role"
  }
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  name = "${var.project_name}-vpc-flow-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = aws_cloudwatch_log_group.flow_logs.arn
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-flow-logs-policy"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_attachment" {
  role       = aws_iam_role.vpc_flow_logs_role.name
  policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
}

resource "aws_flow_log" "vpc_flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  log_destination_type = "cloud-watch-logs"
  log_group_name      = var.flow_log_cloudwatch_log_group_name
  
  traffic_type = "ALL"
  vpc_id       = module.vpc.vpc_id

  iam_role_arn = aws_iam_role.vpc_flow_logs_role.arn

  tags = {
    Name = "${var.project_name}-flow-log"
  }
}

resource "aws_s3_bucket" "flow_logs" {
  count = var.enable_vpc_flow_logs && var.flow_logs_destination == "s3" ? 1 : 0

  bucket = var.flow_logs_s3_bucket_name != "" ? var.flow_logs_s3_bucket_name : "${var.project_name}-${var.environment}-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-flow-logs-s3"
  }
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  count = var.enable_vpc_flow_logs && var.flow_logs_destination == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  count = var.enable_vpc_flow_logs && var.flow_logs_destination == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  count = var.enable_vpc_flow_logs && var.flow_logs_destination == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}
