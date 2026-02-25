output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_name" {
  description = "The VPC name tag"
  value       = module.vpc.vpc_tags["Name"]
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_arns" {
  description = "ARNs of public subnets"
  value       = module.vpc.public_subnet_arns
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnet_arns" {
  description = "ARNs of private subnets"
  value       = module.vpc.private_subnet_arns
}

output "data_subnet_ids" {
  description = "IDs of data subnets"
  value       = module.vpc.database_subnets
}

output "data_subnet_arns" {
  description = "ARNs of data subnets"
  value       = module.vpc.database_subnet_arns
}

output "internet_gateway_id" {
  description = "The Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = [for gw in module.vpc.nat_gateway_ids : gw]
  sensitive   = true
}

output "nat_gateway_ips" {
  description = "NAT Gateway Elastic IPs"
  value       = [for gw in module.vpc.nat_public_ips : gw]
  sensitive   = true
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

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = module.vpc.public_route_table_ids[0]
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = module.vpc.private_route_table_ids[0]
}

output "data_route_table_id" {
  description = "Data Route Table ID"
  value       = module.vpc.database_route_table_ids[0]
}

output "azs" {
  description = "Availability Zones"
  value       = var.availability_zones
}
