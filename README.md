# 🔒 Production-Grade VPC with Infrastructure as Code

A production-ready, secure VPC implementation in AWS using Terraform - following security best practices and the AWS Well-Architected Framework.

![AWS](https://img.shields.io/badge/AWS-VPC-orange) ![Terraform](https://img.shields.io/badge/Terraform-1.6+-blue) ![Security](https://img.shields.io/badge/Security-High-green) ![Status](https://img.shields.io/badge/Status-Complete-green)

---

## 📋 Project Overview

This project demonstrates how to build a **secure, production-grade VPC** in AWS using Terraform with Infrastructure as Code principles.

### Why This Matters

| Problem | Solution |
|---------|----------|
| Clicking in console = no version control | Terraform = code in Git |
| No network security | Multi-layer defense (NACLs + SGs) |
| Exposed resources | Private subnets for sensitive stuff |
| No visibility | VPC Flow Logs enabled |
| Data leaks | No internet access for data tier |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              AWS REGION (ap-south-1)                             │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                           VPC (10.0.0.0/16)                               │  │
│  │                                                                           │  │
│  │   ┌─────────────────────────────────────────────────────────────────┐     │  │
│  │   │                    AVAILABILITY ZONE A                          │     │  │
│  │   │  ┌─────────────────────┐      ┌─────────────────────┐          │     │  │
│  │   │  │   PUBLIC SUBNET     │      │   PRIVATE SUBNET    │          │     │  │
│  │   │  │   10.0.1.0/24       │      │   10.0.10.0/24      │          │     │  │
│  │   │  │                     │      │                     │          │     │  │
│  │   │  │  ┌───────────────┐  │      │  ┌───────────────┐  │          │     │  │
│  │   │  │  │  NAT Gateway  │──┼──────┼─▶│  App Servers  │  │          │     │  │
│  │   │  │  └───────────────┘  │      │  └───────────────┘  │          │     │  │
│  │   │  │  ┌───────────────┐  │      │  ┌───────────────┐  │          │     │  │
│  │   │  │  │      ALB      │  │      │  │   Databases   │  │          │     │  │
│  │   │  │  └───────────────┘  │      │  └───────────────┘  │          │     │  │
│  │   │  └─────────────────────┘      └─────────────────────┘          │     │  │
│  │   └─────────────────────────────────────────────────────────────────┘     │  │
│  │                                                                           │  │
│  │   ┌─────────────────────────────────────────────────────────────────┐     │  │
│  │   │                    AVAILABILITY ZONE B                          │     │  │
│  │   │  ┌─────────────────────┐      ┌─────────────────────┐          │     │  │
│  │   │  │   PUBLIC SUBNET     │      │   PRIVATE SUBNET    │          │     │  │
│  │   │  │   10.0.2.0/24       │      │   10.0.20.0/24      │          │     │  │
│  │   │  │                     │      │                     │          │     │  │
│  │   │  │  ┌───────────────┐  │      │  ┌───────────────┐  │          │     │  │
│  │   │  │  │  NAT Gateway  │──┼──────┼─▶│  App Servers  │  │          │     │  │
│  │   │  │  └───────────────┘  │      │  └───────────────┘  │          │     │  │
│  │   │  └─────────────────────┘      └─────────────────────┘          │     │  │
│  │   └─────────────────────────────────────────────────────────────────┘     │  │
│  │                                                                           │  │
│  │   ┌─────────────────────────────────────────────────────────────────┐     │  │
│  │   │                      DATA SUBNET TIER                           │     │  │
│  │   │  ┌─────────────────────┐      ┌─────────────────────┐          │     │  │
│  │   │  │   DATA SUBNET A     │      │   DATA SUBNET B     │          │     │  │
│  │   │  │   10.0.100.0/24     │      │   10.0.200.0/24     │          │     │  │
│  │   │  │   (No Internet)     │      │   (No Internet)     │          │     │  │
│  │   │  └─────────────────────┘      └─────────────────────┘          │     │  │
│  │   └─────────────────────────────────────────────────────────────────┘     │  │
│  │                                                                           │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│       ┌─────────────┐                                                          │
│       │   Internet  │                                                          │
│       │   Gateway  │◀──── Public internet access                              │
│       └─────────────┘                                                          │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 What's Included

| File | Description |
|------|-------------|
| `terraform/main.tf` | Provider and backend configuration |
| `terraform/vpc.tf` | VPC and subnet creation |
| `terraform/subnets.tf` | Detailed subnet configuration |
| `terraform/security-groups.tf` | Security groups for ALB, App, DB |
| `terraform/routing.tf` | Route tables and associations |
| `terraform/nat.tf` | NAT Gateways configuration |
| `terraform/nacls.tf` | Network ACL rules |
| `terraform/endpoints.tf` | VPC Endpoints for AWS services |
| `terraform/flow-logs.tf` | VPC Flow Logs to CloudWatch & S3 |
| `terraform/variables.tf` | Input variables |
| `terraform/outputs.tf` | Output values |
| `terraform/terraform.tfvars` | Variable values |
| `docs/architecture.md` | Detailed architecture explanation |

---

## 🚀 Quick Start (Terraform)

### Prerequisites

- [ ] AWS Account
- [ ] Terraform installed (v1.6+)
- [ ] AWS CLI configured
- [ ] IAM user with appropriate permissions

> Note: This VPC was initially built using Terraform and then destroyed. Now rebuilt using AWS Console (GUI) in ap-south-1 region.

### Installation Steps

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/secure-vpc-terraform.git
cd secure-vpc-terraform/terraform

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars

# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Apply the configuration
terraform apply

# Verify the VPC is created
terraform output
```

---

## 🔒 Security Features

### 1. Multi-Layer Defense

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEFENSE IN DEPTH                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 1: Network ACLs (Subnet Level - Stateless)              │
│  ──────────────────────────────────────────────────────────    │
│  • Default deny all inbound                                     │
│  • Explicit allows for specific traffic                        │
│  • Ephemeral ports handled properly                             │
│                                                                 │
│         ▼                                                       │
│                                                                 │
│  LAYER 2: Security Groups (Instance Level - Stateful)          │
│  ──────────────────────────────────────────────────────────     │
│  • Reference other SGs, not CIDR blocks                        │
│  • Least privilege rules                                        │
│  • State: ALB → App → Database                                  │
│                                                                 │
│         ▼                                                       │
│                                                                 │
│  LAYER 3: Private Subnets                                       │
│  ──────────────────────────────────────────────────────────     │
│  • App tier: Outbound via NAT only                              │
│  • Data tier: No internet access at all                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Security Groups Design

| Security Group | Inbound | Outbound | Purpose |
|----------------|---------|----------|---------|
| `sg-alb` | HTTPS 443 from 0.0.0.0/0 | To sg-app:8080 | Public ALB |
| `sg-app` | TCP 8080 from sg-alb | To sg-db:5432 | App servers |
| `sg-db` | PostgreSQL 5432 from sg-app | To local only | Databases |

### 3. Data Tier Isolation

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA TIER ISOLATION                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Public Subnet    Private Subnet     Data Subnet              │
│   ────────────    ──────────────    ─────────────              │
│        │                │                  │                    │
│   Internet         NAT GW              NO internet            │
│   Access          (outbound           (completely              │
│   ✓               only)              isolated)               │
│                                                                 │
│   Resources:       Resources:         Resources:               │
│   - ALB            - App Servers      - Databases             │
│   - NAT GW         - Bastion Host     - Sensitive data         │
│                                                                 │
│                        │                                        │
│                        ▼                                        │
│              Uses VPC Endpoints                                │
│              for AWS services                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4. VPC Flow Logs

```
┌─────────────────────────────────────────────────────────────────┐
│                    VPC FLOW LOGS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     ┌─────────────┐                                            │
│     │    VPC      │                                            │
│     │  (Source)   │                                            │
│     └──────┬──────┘                                            │
│            │                                                    │
│            │ All traffic metadata                              │
│            ▼                                                    │
│     ┌─────────────┐         ┌─────────────┐                    │
│     │  Flow Logs  │────────▶│ CloudWatch  │                    │
│     │             │         │    Logs     │                    │
│     └─────────────┘         └─────────────┘                    │
│            │                        │                          │
│            │ Long-term storage       │ Real-time monitoring    │
│            ▼                        ▼                          │
│     ┌─────────────┐         ┌─────────────┐                    │
│     │     S3      │         │   Alerts    │                    │
│     │  (Archive)  │         │  (Anomaly)  │                    │
│     └─────────────┘         └─────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Subnet Design

| Subnet Type | CIDR Range | AZ | Internet Access | Resources |
|-------------|------------|-----|-----------------|-----------|
| Public A | 10.0.1.0/24 | ap-south-1a | Direct (IGW) | ALB, NAT GW |
| Public B | 10.0.2.0/24 | ap-south-1b | Direct (IGW) | ALB, NAT GW |
| Private A | 10.0.10.0/24 | ap-south-1a | Outbound (NAT) | App servers |
| Private B | 10.0.20.0/24 | ap-south-1b | Outbound (NAT) | App servers |
| Data A | 10.0.100.0/24 | ap-south-1a | None | Databases |
| Data B | 10.0.200.0/24 | ap-south-1b | None | Databases |

---

## 🔑 VPC Endpoints

| Endpoint | Service | Type | Purpose |
|----------|---------|------|---------|
| `s3-endpoint` | s3 | Gateway | Private S3 access |
| `dynamodb-endpoint` | dynamodb | Gateway | Private DynamoDB access |

---

## 📝 Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name for resource tagging | `secure-vpc` |
| `environment` | Environment (dev/staging/prod) | `prod` |
| `aws_region` | AWS region | `ap-south-1` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `availability_zones` | List of AZs | `["ap-south-1a", "ap-south-1b"]` |

---

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | The VPC ID |
| `vpc_cidr` | The VPC CIDR block |
| `public_subnet_ids` | IDs of public subnets |
| `private_subnet_ids` | IDs of private subnets |
| `data_subnet_ids` | IDs of data subnets |
| `security_group_alb` | ALB security group ID |
| `security_group_app` | App security group ID |
| `security_group_db` | Database security group ID |

---

## 🧪 Testing Your VPC

### 1. Verify VPC Creation

```bash
# Check VPC exists
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Check subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

### 2. Test Internet Connectivity from Private Subnet

```bash
# Launch an EC2 in private subnet
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --subnet-id $(terraform output -raw private_subnet_ids | jq -r '.[0]') \
  --key-name your-key-pair

# SSH into bastion host, then SSH to private instance
# Test outbound internet
curl https://google.com
```

### 3. Verify Flow Logs

```bash
# Check CloudWatch Logs
aws logs describe-log-groups --log-group-name-prefix /aws/vpc/flow-logs/

# Check S3 bucket
aws s3 ls s3://your-flow-logs-bucket/
```

---

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm with "yes"
```

---

## 🎓 What You'll Learn

1. **Terraform Fundamentals** - Writing Infrastructure as Code
2. **AWS VPC Design** - Multi-tier network architecture
3. **Security Best Practices** - Defense in depth
4. **Network Security** - SGs, NACLs, routing
5. **Logging & Monitoring** - VPC Flow Logs
6. **AWS Well-Architected Framework** - Security pillar

---

## 📚 Further Reading

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws)
- [AWS Security Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [AWS Well-Architected Framework - Security](https://aws.amazon.com/architecture/well-architected/)

---

## ⚠️ Important Notes

1. **Cost Warning**: NAT Gateways incur charges. Delete resources when not in use.
2. **Region**: This project uses `ap-south-1` by default. Change in `terraform.tfvars`.
3. **SSH Key**: You'll need to create or use an existing key pair for EC2 access.
4. **Permissions**: Ensure your IAM user has permissions to create all these resources.

---

## 🤝 Author

Built by **siddhanto657**

---

## 📝 License

MIT License - feel free to use this for learning and personal projects.

---

*Last Updated: February 2026*
