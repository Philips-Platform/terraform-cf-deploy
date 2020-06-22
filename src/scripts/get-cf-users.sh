#!/bin/bash -e
cf curl "/v3/users" -X GET | jq '.resources[] | .username + "." + .guid' | sed 's/"//g'  > user-details.txt
