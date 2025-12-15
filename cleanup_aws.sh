#!/bin/bash
set -e

echo "============================================================"
echo " AWS CLEANUP SCRIPT"
echo "============================================================"

# 1. Delete Kubernetes Resources (Load Balancers cost money!)
# 1. Delete Kubernetes Resources (Load Balancers cost money!)
echo ">>> STEP 1: Deleting Kubernetes Resources..."

# Delete namespaces (Cascading delete removes Services, Deployments, PVCs, etc.)
echo "    Deleting namespaces..."
kubectl delete namespace monitoring --timeout=5m --ignore-not-found=true &
kubectl delete namespace devops-lab --timeout=5m --ignore-not-found=true &


# 2. Setup cleanup variables
CLUSTER_NAME="devops-lab-cluster"
REGION="us-east-1"

# 3. Aggressively clean up Load Balancers that K8s might have left behind
echo ">>> STEP 2: Nuke Lingering Load Balancers..."
# Find Classic ELBs tagged with the cluster ID
LBS=$(aws elb describe-load-balancers --region $REGION --query "LoadBalancerDescriptions[?contains(AvailabilityZones[0], 'us-east-1')].LoadBalancerName" --output text)

# Filter technically hard with JMESPath for tags in DescribeLoadBalancers (it doesn't return tags).
# Instead, we will list all LBs and check tags for each.
for lb in $LBS; do
  TAGS=$(aws elb describe-tags --load-balancer-names $lb --region $REGION --output json)
  if echo "$TAGS" | grep -q "kubernetes.io/cluster/$CLUSTER_NAME"; then
    echo "    Found lingering CLB: $lb. Deleting..."
    aws elb delete-load-balancer --load-balancer-name $lb --region $REGION
  fi
done

# 3.1 Nuke ALBs/NLBs (elbv2)
echo ">>> STEP 3.1: Nuke Lingering ALBs/NLBs..."
ALBS=$(aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[?contains(AvailabilityZones[0].ZoneName, 'us-east-1')].LoadBalancerArn" --output text)
for alb in $ALBS; do
  TAGS=$(aws elbv2 describe-tags --resource-arns $alb --region $REGION --output json)
  if echo "$TAGS" | grep -q "kubernetes.io/cluster/$CLUSTER_NAME"; then
    echo "    Found lingering ALB/NLB: $alb. Deleting..."
    aws elbv2 delete-load-balancer --load-balancer-arn $alb --region $REGION
    # Wait a bit for ALB deletion
    sleep 5
  fi
done

# 3.2 Nuke Lingering Security Groups created by K8s
echo ">>> STEP 3.2: Nuke Lingering Security Groups..."
# Find SGs tagged with the cluster
SGS=$(aws ec2 describe-security-groups --region $REGION --filters Name=tag-key,Values="kubernetes.io/cluster/$CLUSTER_NAME" --query "SecurityGroups[*].GroupId" --output text)
for sg in $SGS; do
  echo "    Attempting to delete SG: $sg..."
  # We use || true because some SGs might be dependent on others or already deleted
  aws ec2 delete-security-group --group-id $sg --region $REGION || echo "    Could not delete $sg yet (likely dependency). Terraform will retry."
done

# Wait for LB deletion to propagate (release ENIs)
echo "    Waiting 20s for LB deletion to propagate..."
sleep 20

# 3.3 Nuke Lingering ENIs (Elastic Network Interfaces)
echo ">>> STEP 3.3: Nuke Lingering ENIs..."
# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --filters "Name=tag:Name,Values=devops-final-lab-vpc" --query "Vpcs[0].VpcId" --output text)

if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo "    Found VPC: $VPC_ID. Checking for ENIs..."
    # Find ENIs in the VPC that are 'available' (not in use by running instances, hopefully)
    # We iterate all to be safe, but detaching might be needed if attached.
    
    ENIS=$(aws ec2 describe-network-interfaces --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkInterfaces[*].NetworkInterfaceId" --output text)
    
    for eni in $ENIS; do
        echo "    Deleting ENI: $eni..."
        # Detach first just in case
        aws ec2 detach-network-interface --force --network-interface-id $eni --region $REGION || true
        # Delete
        aws ec2 delete-network-interface --network-interface-id $eni --region $REGION || echo "    Could not delete $eni (might be critical/managed). Terraform will retry."
    done
else
    echo "    VPC not found or already deleted. Skipping ENI cleanup."
fi

# 1.5 Force delete ECR Repositories (Terraform can be picky about non-empty repos)
echo ">>> STEP 1.5: Force Deleting ECR Repositories..."
aws ecr delete-repository --repository-name devops-lab-app-backend --force --region us-east-1 || true
aws ecr delete-repository --repository-name devops-lab-app-frontend --force --region us-east-1 || true

# 2. Terraform Destroy
echo ">>> STEP 2: Destroying Infrastructure (This takes time)..."
cd infra
terraform destroy -auto-approve
cd ..

echo "============================================================"
echo " CLEANUP COMPLETE!"
echo "============================================================"
