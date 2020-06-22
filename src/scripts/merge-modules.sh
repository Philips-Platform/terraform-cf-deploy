#!/bin/bash -e

rm -rf all_modules.json
echo "{\"module\":{" >> all_modules.json
for module in "$@"
do
    cat "./monitoring-templates/$module.json" | jq -r '.module | keys[] as $k | "\"\($k)\":\(.[$k]),"' >> all_modules.json
done
# remove trailing comma
sed -i '$s/,$//' all_modules.json 
echo "}}" >> all_modules.json