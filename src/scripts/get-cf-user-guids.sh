#!/bin/bash

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

