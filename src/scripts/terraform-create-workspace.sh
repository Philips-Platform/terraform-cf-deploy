#!/bin/bash
if [ -z "$CFSpaceName" ]; then
    echo "##vso[task.logissue type=error]Error: Cloud Foundry Space [CFSpaceName] environment variable was not provided"
    exit 1
fi

if [ -z "$TERRAFORM_API_TOKEN" ]; then
    echo "##vso[task.logissue type=error]Error: Terraform API Token [TERRAFORM_API_TOKEN] environment variable was not provided"
    exit 1
fi

if [ -z "$TERRAFORM_WORKSPACE_SUBSECTION" ]; then
    echo "##vso[task.logissue type=error]Error: Terraform API Token [TERRAFORM_WORKSPACE_SUBSECTION] environment variable was not provided"
    exit 1
fi

sed "s/#spacename#/$CFSpaceName/g" ./workspace.json > ./workspace-temp.json
sed -i "s/#subname#/$TERRAFORM_WORKSPACE_SUBSECTION/g" ./workspace-temp.json
curl --header "Authorization: Bearer $TERRAFORM_API_TOKEN" --header 'Content-Type: application/vnd.api+json' --request POST --data @'workspace-temp.json' 'https://app.terraform.io/api/v2/organizations/Philips-platform/workspaces'
rm -rf ./workspace-temp.json