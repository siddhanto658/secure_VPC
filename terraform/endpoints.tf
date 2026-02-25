resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.database_route_table_ids
  )

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.database_route_table_ids
  )

  tags = {
    Name = "${var.project_name}-dynamodb-endpoint"
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [aws_security_group.app.id]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-secrets-manager-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [aws_security_group.app.id]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [aws_security_group.app.id]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ssm-messages-endpoint"
  }
}
