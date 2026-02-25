resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Description = "Security group for ALB"
    Type        = "alb"
  }
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS from internet"
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP from internet"
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_to_app" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow traffic to App servers"
  security_group_id         = aws_security_group.alb.id
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for Application servers"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-app-sg"
    Description = "Security group for App servers"
    Type        = "app"
  }
}

resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow traffic from ALB"
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_ingress_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  description              = "Allow SSH from Bastion"
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_to_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  description              = "Allow traffic to Database"
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_to_internet" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS outbound to internet"
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for Database servers"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-db-sg"
    Description = "Security group for Database"
    Type        = "database"
  }
}

resource "aws_security_group_rule" "db_ingress_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow PostgreSQL from App servers"
  security_group_id        = aws_security_group.db.id
}

resource "aws_security_group_rule" "db_egress_local" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic to local VPC"
  security_group_id = aws_security_group.db.id
}

resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Description = "Security group for Bastion host"
    Type        = "bastion"
  }
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH from internet"
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.bastion.id
}
