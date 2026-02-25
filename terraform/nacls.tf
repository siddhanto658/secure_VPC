resource "aws_network_acl" "public" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "${var.project_name}-public-nacl"
  }
}

resource "aws_network_acl_rule" "public_ingress_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = 443
  to_port        = 443
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_ingress_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = 80
  to_port        = 80
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_ingress_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_egress_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  from_port      = 0
  to_port        = 65535
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl" "private" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-private-nacl"
  }
}

resource "aws_network_acl_rule" "private_ingress_from_vpc" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = false
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "private_egress_to_nat" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl" "data" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.project_name}-data-nacl"
  }
}

resource "aws_network_acl_rule" "data_ingress_postgres" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = 5432
  to_port        = 5432
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "data_ingress_mysql" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 110
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = 3306
  to_port        = 3306
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "data_egress_local" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  cidr_block     = var.vpc_cidr
}
