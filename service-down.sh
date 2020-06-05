#!/bin/bash

# remove the service
echo ecs-cli compose service down...
ecs-cli compose \
    --project-name ecs-fargate-cli \
    service down \
    --cluster-config ecs-fargate-cli

# remove the cluster
echo ecs-cli down...
ecs-cli down \
    --force \
    --cluster-config ecs-fargate-cli