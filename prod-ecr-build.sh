#!/bin/bash
VERSION=$(node -e "console.log(require('./package.json').version)")
docker image build \
    --file env.prod.dockerfile \
    --tag ecs-fargate \
    --tag ecs-fargate:$VERSION \
    .

URL=$(aws ecr describe-repositories \
    --query "repositories[?repositoryName == 'ecs-fargate'].repositoryUri" \
    --output text)
docker tag ecs-fargate:latest "$URL:latest"