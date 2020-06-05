#!/bin/bash

# create the cluster
echo ecs-cli up...
ecs-cli up \
    --cluster-config ecs-fargate-cli \
    --tags Name=ecs-fargate-cli

# vpc id
VPC=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=ecs-fargate-cli" \
    --query "Vpcs[].VpcId" \
    --output text)
echo VPC:$VPC

# subnet 1 id
SUBNET_1=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=ecs-fargate-cli" \
    --query "Subnets[0].SubnetId" \
    --output text)
echo SUBNET_1:$SUBNET_1

# subnet 2 id
SUBNET_2=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=ecs-fargate-cli" \
    --query "Subnets[1].SubnetId" \
    --output text)
echo SUBNET_2:$SUBNET_2

# security group id
SG=$(aws ec2 describe-security-groups \
    --query "SecurityGroups[?VpcId == '$VPC'].GroupId" \
    --output text)
echo SG:$SG

# open the port 80
echo aws ec2 authorize-security-group-ingress...
aws ec2 authorize-security-group-ingress \
  --group-id $SG \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region eu-west-3

# user id
USER=$(aws sts get-caller-identity --output text --query 'Account')
echo USER:$USER

# create the docker-compose.yml file
echo create docker-compose.yml file...
sed --expression "s|{{USER}}|$USER|" \
    docker-compose.sample.yml \
    > docker-compose.yml

# create the ecs-params.yml file
echo create ecs-params.yml file...
sed --expression "s|{{SUBNET_1}}|$SUBNET_1|" \
    --expression "s|{{SUBNET_2}}|$SUBNET_2|" \
    --expression "s|{{SG}}|$SG|" \
    ecs-params.sample.yml \
    > ecs-params.yml

# create the service
echo ecs-cli compose service up...
ecs-cli compose \
  --project-name ecs-fargate-cli \
  service up \
  --create-log-groups \
  --cluster-config ecs-fargate-cli

# service status
echo ecs-cli compose service ps...
ecs-cli compose \
    --project-name ecs-fargate-cli \
    service ps \
    --cluster-config ecs-fargate-cli

# task arn
TASK=$(aws ecs list-tasks \
    --cluster ecs-fargate-cli \
    --query 'taskArns' \
    --output text)
echo TASK:$TASK

# network interface id
ENI=$(aws ecs describe-tasks \
    --cluster ecs-fargate-cli \
    --tasks "$TASK" \
    --query "tasks[0].attachments[0].details[?name == 'networkInterfaceId'].value" \
    --output text)
echo ENI:$ENI

# get the public ip
echo aws ec2 describe-network-interfaces...
aws ec2 describe-network-interfaces \
    --network-interface-ids $ENI \
    --query 'NetworkInterfaces[*].Association.PublicIp' \
    --output text