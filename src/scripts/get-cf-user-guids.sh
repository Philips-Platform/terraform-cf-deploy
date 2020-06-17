#!/bin/bash -e
if [ -z "$CFSpaceUsers" ]; then
    echo "##vso[task.logissue type=error]Error: Cloud Foundry Space Users [CFSpaceUsers] environment variable was not provided"
    exit 1
fi

if [ ! -f "user-details.txt" ]; then
    echo "##vso[task.logissue type=error]Error: Cloud Foundry User details file was not provided"
    exit 1
fi

# Always add service user to the list of users with access 
# if not already present
if [[ "$CFSpaceUsers" != *"pca-acs-cicd-svc"* ]]; then
  CFSpaceUsers="${CFSpaceUsers},pca-acs-cicd-svc"
fi

IFS=', ' read -r -a usersArray <<< "$CFSpaceUsers"
userguids=()
while IFS= read -r line; do
	username=`echo $line | cut -d'.' -f 1`
    if [[ " ${usersArray[@]} " =~ " ${username} " ]]; then
		userguid=`echo $line | cut -d'.' -f 2`
		userguids+=( "\"${userguid}\"" )
	fi
done < "user-details.txt"
guids_string="${userguids[*]}"
echo "[$guids_string]" | sed 's/ /,/g'