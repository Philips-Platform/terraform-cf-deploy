#!/bin/bash
if [ -z "$CLOUD_FOUNDRY_API" ]; then
    echo "##vso[task.logissue type=error]Error: Cloud Foundry Api [CLOUD_FOUNDRY_API] environment variable was not provided"
    exit 1
fi

if [ -z "$CLOUD_FOUNDRY_USERNAME" ]; then
    echo "##vso[task.logissue type=error]Error: Cloud Foundry Username [CLOUD_FOUNDRY_USERNAME] environment variable was not provided"
    exit 1
fi

if [ -z "$CLOUD_FOUNDRY_PASSWORD" ]; then
    echo "##vso[task.logissue type=error]Error: Cloud Foundry Password [CLOUD_FOUNDRY_PASSWORD] environment variable was not provided"
    exit 1
fi

cf api $CLOUD_FOUNDRY_API
cf auth $CLOUD_FOUNDRY_USERNAME $CLOUD_FOUNDRY_PASSWORD