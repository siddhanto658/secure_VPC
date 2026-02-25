# VPC Architecture Documentation

## Overview

This document provides a detailed explanation of the VPC architecture implemented in this project.

---

## Network Architecture

### VPC (Virtual Private Cloud)

- **CIDR Block**: 10.0.0.0/16
- **DNS Hostnames**: Enabled
- **DNS Support**: Enabled

The VPC provides an isolated network environment with complete control over IP addressing, subnets, routing, and security.

---

## Subnet Design

### Why 3-Tier Architecture?

We use a 3-tier network architecture for security and isolation:

```
┌─────────────────────────────────────────────────────────────────┐
│                    3-TIER ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TIER 1: PUBLIC SUBNET                                         │
│  ───────────────────                                           │
│  • Directly connected to Internet Gateway                     │
│  • Resources that need public internet access                   │
│  • Examples: Load Balancers, NAT Gateways, Bastion Hosts       │
│  • CIDR: 10.0.1.0/24, 10.0.2.0/24                              │
│                                                                 │
│          │                                                      │
│          ▼                                                      │
│                                                                 │
│  TIER 2: PRIVATE SUBNET                                        │
│  ────────────────────                                          │
│  • No direct internet access (outbound via NAT)                │
│  • Application servers, web servers                            │
│  • Can initiate outbound connections but not receive inbound   │
│  • CIDR: 10.0.10.0/24, 10.0.20.0/24                            │
│                                                                 │
│          │                                                      │
│          ▼                                                      │
│                                                                 │
│  TIER 3: DATA SUBNET                                           │
│  ─────────────────                                             │
│  • NO internet access at all                                   │
│  • Databases, sensitive data storage                           │
│  • Most restrictive tier                                       │
│  • CIDR: 10.0.100.0/24, 10.0.200.0/24                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Availability Zones

The VPC spans 2 Availability Zones for High Availability:

| Availability Zone | Public Subnet | Private Subnet | Data Subnet |
|-------------------|---------------|----------------|-------------|
| us-east-1a | 10.0.1.0/24 | 10.0.10.0/24 | 10.0.100.0/24 |
| us-east-1b | 10.0.2.0/24 | 10.0.20.0/24 | 10.0.200.0/24 |

---

## Routing

### Route Tables

#### Public Route Table
```
┌─────────────────┬─────────────────┐
│ Destination    │ Target          │
├─────────────────┼─────────────────┤
│ 10.0.0.0/16    │ local           │
│ 0.0.0.0/0      │ igw-xxx         │
└─────────────────┴─────────────────┘
```

#### Private Route Table
```
┌─────────────────┬─────────────────┐
│ Destination    │ Target          │
├─────────────────┼─────────────────┤
│ 10.0.0.0/16    │ local           │
│ 0.0.0.0/0      │ nat-xxx         │
└─────────────────┴─────────────────┘
```

#### Data Route Table
```
┌─────────────────┬─────────────────┐
│ Destination    │ Target          │
├─────────────────┼─────────────────┤
│ 10.0.0.0/16    │ local           │
│ (no default)   │                 │
└─────────────────┴─────────────────┘
```

---

## Security Implementation

### Security Groups (Stateful)

Security Groups act as virtual firewalls at the instance level:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY GROUP CHAIN                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐              │
│   │   ALB    │────▶│   APP    │────▶│   DB     │              │
│   │   SG     │     │   SG     │     │   SG     │              │
│   └──────────┘     └──────────┘     └──────────┘              │
│        │                  │                  │                   │
│        ▼                  ▼                  ▼                   │
│   Port 443/80          Port 8080          Port 5432             │
│   from Internet        from ALB           from App              │
│                                                                 │
│   OUTBOUND:            OUTBOUND:          OUTBOUND:            │
│   to App:8080          to DB:5432         to VPC only          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Network ACLs (Stateless)

Network ACLs provide an additional layer of security at the subnet level:

```
┌─────────────────────────────────────────────────────────────────┐
│                    NACL LAYERS                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PUBLIC NACL                                                   │
│   ────────────                                                  │
│   • Allow HTTPS (443) from 0.0.0.0/0                          │
│   • Allow HTTP (80) from 0.0.0.0/0                            │
│   • Allow ephemeral ports (1024-65535)                         │
│                                                                 │
│   PRIVATE NACL                                                  │
│   ───────────                                                   │
│   • Allow all traffic from VPC (10.0.0.0/16)                  │
│   • Allow all outbound via NAT                                 │
│                                                                 │
│   DATA NACL                                                     │
│   ─────────                                                     │
│   • Allow PostgreSQL (5432) from VPC                          │
│   • Allow MySQL (3306) from VPC                                │
│   • NO internet access                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## NAT Gateways

NAT (Network Address Translation) Gateways allow instances in private subnets to connect to the internet or other AWS services, while preventing the internet from initiating connections with those instances.

```
┌─────────────────────────────────────────────────────────────────┐
│                    NAT GATEWAY FLOW                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Private Instance                                             │
│   (10.0.10.10)                                                 │
│        │                                                        │
│        │ "I want to fetch updates"                             │
│        ▼                                                        │
│   ┌─────────────┐                                              │
│   │ NAT Gateway │  Replaces private IP with Elastic IP        │
│   │ (10.0.1.5)  │                                              │
│   └──────┬──────┘                                              │
│          │                                                      │
│          │ "Request from 1.2.3.4"                              │
│          ▼                                                      │
│   ┌─────────────┐                                              │
│   │  Internet   │  Internet Gateway                           │
│   │  Gateway    │                                              │
│   └─────────────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   Internet Services                                            │
│   (yum update, pip install, etc.)                              │
│                                                                 │
│   RESPONSE:                                                    │
│   ─────────                                                    │
│   ◀──────────────│─────────────────────────────────────────    │
│                   │                                             │
│   NAT Gateway     │  Translates back to private IP            │
│   sends to ───────┘                                             │
│   instance                                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## VPC Endpoints

VPC Endpoints enable private connections between your VPC and supported AWS services:

| Endpoint | Service | Type | Benefit |
|----------|---------|------|---------|
| S3 | Amazon S3 | Gateway | Access S3 without internet |
| DynamoDB | Amazon DynamoDB | Gateway | Access DynamoDB without internet |
| Secrets Manager | AWS Secrets Manager | Interface | Secure secret retrieval |
| SSM | AWS Systems Manager | Interface | Manage instances without internet |
| SSM Messages | AWS Systems Manager | Interface | Session Manager functionality |

---

## VPC Flow Logs

VPC Flow Logs capture information about IP traffic going to and from network interfaces in your VPC:

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLOW LOG INFORMATION                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Log Fields:                                                  │
│   ───────────                                                  │
│   • Version                                                    │
│   • Account ID                                                │
│   • Interface ID                                              │
│   • Source IP Address                                         │
│   • Destination IP Address                                    │
│   • Source Port                                               │
│   • Destination Port                                          │
│   • Protocol                                                  │
│   • Number of Packets                                          │
│   • Number of Bytes                                           │
│   • Start Time                                                │
│   • End Time                                                  │
│   • Action (ACCEPT/REJECT)                                    │
│   • Log Status                                                │
│                                                                 │
│   Example Log Entry:                                           │
│   ───────────────                                             │
│   2 123456789012 eni-12345 10.0.10.10 10.0.1.5 54321 443 6    │
│   1000 5000 1234567890 1234567891 ACCEPT OK                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Traffic Flow Examples

### 1. User Accessing Application

```
Internet User
     │
     │ HTTPS Request (443)
     ▼
┌────────────────┐
│ Internet       │
│ Gateway        │
└───────┬────────┘
        │
        │ Route to Public Subnet
        ▼
┌────────────────┐
│ Application    │
│ Load Balancer  │
│ (Public Subnet)│
└───────┬────────┘
        │
        │ Forward to App Server
        ▼
┌────────────────┐
│ App Server     │
│ (Private       │
│  Subnet)       │
└───────┬────────┘
        │
        │ Query Database
        ▼
┌────────────────┐
│ Database       │
│ (Data Subnet) │
└────────────────┘
```

### 2. Application Fetching Updates

```
┌────────────────┐
│ App Server     │
│ (Private       │
│  Subnet)       │
└───────┬────────┘
        │
        │ Request updates (via NAT)
        ▼
┌────────────────┐
│ NAT Gateway    │
│ (Public Subnet)│
└───────┬────────┘
        │
        │ Outbound request
        ▼
┌────────────────┐
│ Internet       │
│ Gateway        │
└───────┬────────┘
        │
        ▼
Internet Services
(Yum, Pip, npm, etc.)
```

---

## Security Best Practices Implemented

1. **Defense in Depth**: Multiple security layers (NACLs + Security Groups)
2. **Least Privilege**: Each tier only allows necessary traffic
3. **Network Isolation**: Data tier has no internet access
4. **Reference-Based Security**: Security Groups reference other SGs, not CIDRs
5. **Logging**: VPC Flow Logs capture all traffic
6. **Private Access**: VPC Endpoints for AWS services

---

## Cost Considerations

| Resource | Monthly Cost (Estimate) |
|----------|------------------------|
| VPC | Free |
| NAT Gateway | ~$32 per gateway |
| Internet Gateway | Free |
| VPC Endpoints | $0.01 per endpoint (Gateway) |
| VPC Flow Logs | ~$0.50 per GB |
| NAT Gateway Data Processing | $0.045 per GB |

---

## Future Enhancements

- Add AWS Transit Gateway for multi-VPC connectivity
- Implement VPC Traffic Mirroring for security analysis
- Add AWS Network Firewall for deep packet inspection
- Implement PrivateLink for service access
- Add VPN connection for hybrid cloud setup
