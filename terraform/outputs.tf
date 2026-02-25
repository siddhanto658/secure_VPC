output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "data_subnet_ids" {
  description = "IDs of data subnets"
  value       = module.vpc.database_subnets
}

output "internet_gateway_id" {
  description = "The Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "security_group_alb" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "security_group_app" {
  description = "App Security Group ID"
  value       = aws_security_group.app.id
}

output "security_group_db" {
  description = "Database Security Group ID"
  value       = aws_security_group.db.id
}

output "security_group_bastion" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion.id
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = module.vpc.public_route_table_ids[0]
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = module.vpc.private_route_table_ids[0]
}

output "azs" {
  description = "Availability Zones"
  value       = var.availability_zones
}
