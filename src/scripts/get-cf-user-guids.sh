#!/bin/bash -e

# Always add service user to the list of users with access 
# if not already present
if [[ "$CFSpaceUsers" != *"pca-acs-cicd-svc"* ]]; then
  CFSpaceUsers="${CFSpaceUsers},pca-acs-cicd-svc"
fi
users=$CFSpaceUsers
IFS=', ' read -r -a usersArray <<< "$users"
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