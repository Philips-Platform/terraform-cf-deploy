#!/bin/bash -e
if [ -z "$TERRAFORMRC" ]; then
    echo "##vso[task.logissue type=error]Error: Terraform-RC [TERRAFORMRC] environment variable was not provided"
    exit 1
fi

if [ -z "$TERRAFORMINPUT" ]; then
    echo "##vso[task.logissue type=error]Error: Terraform-inputs [TERRAFORMINPUT] environment variable was not provided"
    exit 1
fi

echo "$TERRAFORMRC" > $1
echo "$TERRAFORMINPUT" > $2