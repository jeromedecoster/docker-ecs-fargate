#!/bin/bash
VERSION=$(node -e "console.log(require('./package.json').version)")
docker image build \
    --file env.prod.dockerfile \
    --tag jeromedecoster/site \
    --tag jeromedecoster/site:$VERSION \
    .