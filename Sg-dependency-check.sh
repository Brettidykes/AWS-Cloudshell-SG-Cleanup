#Must use single-line command in cloudshell, below code is just describing what the single line command does so its readable

SG="sg-xxxxxxxxxx"; echo "=== EC2 Instances ==="; RESULT=$(aws ec2 describe-instances --filters "Name=instance.group-id,Values=$SG" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Network Interfaces ==="; RESULT=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SG" --query 'NetworkInterfaces[*].[NetworkInterfaceId,Description]' --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== ALB/NLB ==="; RESULT=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(SecurityGroups, '$SG')].[LoadBalancerName,Type]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Classic LB ==="; RESULT=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?contains(SecurityGroups, '$SG')].[LoadBalancerName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== RDS ==="; RESULT=$(aws rds describe-db-instances --query "DBInstances[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG']].[DBInstanceIdentifier,Engine]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Lambda ==="; RESULT=$(aws lambda list-functions --query "Functions[?VpcConfig.SecurityGroupIds[?contains(@, '$SG')]].[FunctionName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== ElastiCache ==="; RESULT=$(aws elasticache describe-cache-clusters --query "CacheClusters[?SecurityGroups[?SecurityGroupId=='$SG']].[CacheClusterId,Engine]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== ASG Launch Configs ==="; RESULT=$(aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?contains(SecurityGroups, '$SG')].[LaunchConfigurationName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Redshift ==="; RESULT=$(aws redshift describe-clusters --query "Clusters[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG']].[ClusterIdentifier]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== Security Group Refs ==="; RESULT=$(aws ec2 describe-security-groups --query "SecurityGroups[?IpPermissions[?UserIdGroupPairs[?GroupId=='$SG']] || IpPermissionsEgress[?UserIdGroupPairs[?GroupId=='$SG']]].[GroupId,GroupName]" --output text 2>/dev/null); [ -n "$RESULT" ] && echo "$RESULT" || echo "None found"; echo "=== DONE ==="

###################################################################
###################################################################
SG="sg-xxxxxxxxxx" #replace with SG id

echo "=== EC2 Instances ==="
RESULT=$(aws ec2 describe-instances --filters "Name=instance.group-id,Values=$SG" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== Network Interfaces ==="
RESULT=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SG" --query 'NetworkInterfaces[*].[NetworkInterfaceId,Description]' --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== ALB/NLB ==="
RESULT=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(SecurityGroups, '$SG')].[LoadBalancerName,Type]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== Classic LB ==="
RESULT=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?contains(SecurityGroups, '$SG')].[LoadBalancerName]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== RDS ==="
RESULT=$(aws rds describe-db-instances --query "DBInstances[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG']].[DBInstanceIdentifier,Engine]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== Lambda ==="
RESULT=$(aws lambda list-functions --query "Functions[?VpcConfig.SecurityGroupIds[?contains(@, '$SG')]].[FunctionName]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== ElastiCache ==="
RESULT=$(aws elasticache describe-cache-clusters --query "CacheClusters[?SecurityGroups[?SecurityGroupId=='$SG']].[CacheClusterId,Engine]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== ASG Launch Configs ==="
RESULT=$(aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?contains(SecurityGroups, '$SG')].[LaunchConfigurationName]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== Redshift ==="
RESULT=$(aws redshift describe-clusters --query "Clusters[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG']].[ClusterIdentifier]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== Security Group Refs ==="
RESULT=$(aws ec2 describe-security-groups --query "SecurityGroups[?IpPermissions[?UserIdGroupPairs[?GroupId=='$SG']] || IpPermissionsEgress[?UserIdGroupPairs[?GroupId=='$SG']]].[GroupId,GroupName]" --output text 2>/dev/null)
[ -n "$RESULT" ] && echo "$RESULT" || echo "None found"

echo "=== DONE ==="
