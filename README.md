# AWS Security Group Dependency Checker

A bash script to identify all AWS resources that are currently using a specific security group. This tool is essential for security group management, cleanup operations, and understanding resource dependencies before making changes.

## Purpose

This script helps you discover which AWS resources are associated with a security group before:
- Deleting a security group
- Modifying security group rules
- Auditing security group usage
- Troubleshooting connectivity issues

## Prerequisites

- **AWS CLI** installed and configured
- **Appropriate IAM permissions** to describe resources across multiple AWS services
- **Bash shell** (Linux, macOS, or WSL on Windows)

### Required IAM Permissions

Your AWS credentials need the following permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "elbv2:DescribeLoadBalancers",
                "elb:DescribeLoadBalancers",
                "rds:DescribeDBInstances",
                "lambda:ListFunctions",
                "elasticache:DescribeCacheClusters",
                "autoscaling:DescribeLaunchConfigurations",
                "redshift:DescribeClusters"
            ],
            "Resource": "*"
        }
    ]
}
```

## Usage

### Method 1: Edit the Script
1. Open the script file
2. Delete the one line version of the script
3. Replace `sg-xxxxxxxxxx` with your security group ID:
   ```bash
   SG="sg-0280c44d67cb8660f"  # Replace with your security group ID
   ```
4. Run the script:
   ```bash
   ./security-group-checker.sh
   ```

### Method 2: Single-Line Command - Copy and paste into cloudshell (easiest, recommended)
Use the one-liner version (replace the security group ID):
```bash
SG="sg-0280c44d67cb8660f"; echo "=== EC2 Instances ==="; RESULT=$(aws ec2 describe-instances --filters "Name=instance.group-id,Values=$SG" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Network Interfaces ==="; RESULT=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SG" --query 'NetworkInterfaces[*].[NetworkInterfaceId,Description]' --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== ALB/NLB ==="; RESULT=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(SecurityGroups, '$SG')].[LoadBalancerName,Type]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Classic LB ==="; RESULT=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?contains(SecurityGroups, '$SG')].[LoadBalancerName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== RDS ==="; RESULT=$(aws rds describe-db-instances --query "DBInstances[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG']].[DBInstanceIdentifier,Engine]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Lambda ==="; RESULT=$(aws lambda list-functions --query "Functions[?VpcConfig.SecurityGroupIds[?contains(@, '$SG')]].[FunctionName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== ElastiCache ==="; RESULT=$(aws elasticache describe-cache-clusters --query "CacheClusters[?SecurityGroups[?SecurityGroupId=='$SG']].[CacheClusterId,Engine]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== ASG Launch Configs ==="; RESULT=$(aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?contains(SecurityGroups, '$SG')].[LaunchConfigurationName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Redshift ==="; RESULT=$(aws redshift describe-clusters --query "Clusters[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG']].[ClusterIdentifier]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Security Group Refs ==="; RESULT=$(aws ec2 describe-security-groups --query "SecurityGroups[?IpPermissions[?UserIdGroupPairs[?GroupId=='$SG']] || IpPermissionsEgress[?UserIdGroupPairs[?GroupId=='$SG']]].[GroupId,GroupName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== DONE ==="
```

## What the Script Checks

The script examines the following AWS services for security group usage:

| Service | What It Finds |
|---------|---------------|
| **EC2 Instances** | Instance ID and Name tag |
| **Network Interfaces** | Interface ID and description |
| **ALB/NLB** | Load balancer name and type |
| **Classic Load Balancer** | Load balancer name |
| **RDS** | Database instance identifier and engine |
| **Lambda** | Function names (VPC-enabled only) |
| **ElastiCache** | Cache cluster ID and engine |
| **ASG Launch Configs** | Launch configuration names |
| **Redshift** | Cluster identifiers |
| **Security Group References** | Other security groups that reference this one |

## Sample Output

```
=== EC2 Instances ===
i-0123456789abcdef0    web-server-01
i-0fedcba9876543210    web-server-02

=== Network Interfaces ===
eni-0123456789abcdef0    Primary network interface

=== ALB/NLB ===
my-application-lb    application

=== Classic LB ===
None found

=== RDS ===
my-database-instance    mysql

=== Lambda ===
my-vpc-lambda-function

=== ElastiCache ===
None found

=== ASG Launch Configs ===
my-launch-config

=== Redshift ===
None found

=== Security Group References ===
sg-0987654321fedcba0    database-sg

=== DONE ===
```

## Important Notes

- **Cross-Region**: This script only checks the current AWS region. Run it in each region where you need to check dependencies.
- **Permissions**: Ensure your AWS credentials have read permissions for all the services being checked.
- **Launch Templates**: The script checks launch configurations but not launch templates (newer ASG feature).
- **Error Handling**: Errors are suppressed (`2>/dev/null`) to keep output clean, but this may hide permission issues.

## Troubleshooting

### No Output or Errors
1. Verify AWS CLI is installed: `aws --version`
2. Check AWS credentials: `aws sts get-caller-identity`
3. Verify the security group ID exists: `aws ec2 describe-security-groups --group-ids sg-xxxxxxxxxx`

### Permission Denied
Ensure your IAM user/role has the required permissions listed above.

### "None found" for Everything
- Double-check the security group ID
- Verify you're in the correct AWS region
- Confirm the security group actually exists and has resources attached

## License

This script is provided as-is for educational and operational purposes. Use at your own risk and always test in non-production environments first.

## Contributing

Feel free to extend this script to check additional AWS services like:
- ECS services
- EKS node groups  
- ElasticSearch domains
- Launch templates (vs launch configurations)
- NAT gateways
- VPC endpoints
