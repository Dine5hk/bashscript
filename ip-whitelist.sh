#!/bin/bash

# Prompt for inputs
read -p "Enter EC2 instance ID: " instance_id
read -p "Enter port to allow: " port
read -p "Enter IP address (CIDR format): " ip_address
read -p "Enter action (a: add, r: remove): " action

# Ensure IP is in CIDR format
case "$ip_address" in
  */*) ;;  # If already in CIDR format
  *) ip_address="$ip_address/32" ;;  # Append /32 if not
esac

# Check if instance ID is provided
if [ -z "$instance_id" ] || [ -z "$port" ] || [ -z "$ip_address" ] || [ -z "$action" ]; then
  echo "Instance ID, port, IP address, and action are required." && exit 1
fi

# Fetch the security group ID of the specified EC2 instance
security_group_id=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

# Check if the security group ID was fetched successfully
if [ "$security_group_id" == "None" ] || [ -z "$security_group_id" ]; then
  echo "Failed to retrieve security group ID for instance $instance_id." && exit 1
fi

echo "Security Group ID for instance $instance_id is $security_group_id."

# Add or Remove rule
if [ "$action" = "a" ]; then
  aws ec2 authorize-security-group-ingress --group-id "$security_group_id" --protocol tcp --port "$port" --cidr "$ip_address" && echo "Rule added." || echo "Failed to add rule."
elif [ "$action" = "r" ]; then
  aws ec2 revoke-security-group-ingress --group-id "$security_group_id" --protocol tcp --port "$port" --cidr "$ip_address" && echo "Rule removed." || echo "Failed to remove rule."
else
  echo "Invalid action. Please use 'a' for add or 'r' for remove." && exit 1
fi
