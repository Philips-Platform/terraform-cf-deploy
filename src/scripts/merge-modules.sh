#!/bin/bash -e

echo "{\"module\":{" >> all_modules.json
ITER=0
for module in "$@"
do
    if [[ "$ITER" != 0 ]]; then
        echo "," >> all_modules.json
    fi
    echo "\"$module\":" >> all_modules.json 
    cat "./monitoring-templates/$module.json" | jq ".module | .$module" >> all_modules.json
    ITER=$(expr $ITER + 1)
done
echo "}}" >> all_modules.json