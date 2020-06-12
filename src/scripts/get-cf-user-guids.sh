#!/bin/bash
/bin/bash ./scripts/install-cf-cli.sh
/bin/bash ./scripts/cf-login.sh
/bin/bash ./scripts/get-cf-users.sh

# Always add service user to the list of users with access
CFSpaceUsers="${CFSpaceUsers},pca-acs-cicd-svc"
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

