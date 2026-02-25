project_name     = "secure-vpc"
environment      = "prod"
aws_region       = "ap-south-1"
vpc_cidr         = "10.0.0.0/16"

availability_zones = ["ap-south-1a", "ap-south-1b"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
data_subnet_cidrs    = ["10.0.100.0/24", "10.0.200.0/24"]

enable_nat_gateway   = true
single_nat_gateway   = false

enable_vpc_flow_logs         = false
flow_logs_destination       = "cloud-watch-logs"
flow_log_cloudwatch_log_group_name = "/aws/vpc/flow-logs"
flow_logs_s3_bucket_name     = ""
