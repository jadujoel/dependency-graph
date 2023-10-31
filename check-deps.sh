#!/bin/bash

PACKAGE_PATH="${1}"

# Path to the subpackage's package.json
PACKAGE_JSON_PATH="$PACKAGE_PATH/package.json"

echo "$PACKAGE_JSON_PATH"

# Extract dependencies and devDependencies
DEPENDENCIES=$(jq -r '.dependencies // {} | keys[]' "$PACKAGE_JSON_PATH")
DEV_DEPENDENCIES=$(jq -r '.devDependencies // {} | keys[]' "$PACKAGE_JSON_PATH")

# Merge the two lists and remove duplicates
ALL_DEPENDENCIES=$(echo "$DEPENDENCIES $DEV_DEPENDENCIES" | tr ' ' '\n' | sort | uniq)


# Path to the subpackage's source code directory
SOURCE_CODE_PATH="$PACKAGE_PATH/src"

# Find all imports in the source code, and remove duplicates
IMPORTS=$(grep -rhoE "import .* from ['\"](@[^'\"]+|[^./][^'\"]*)['\"]" "$SOURCE_CODE_PATH" | awk -F"from" '{print $2}' | tr -d " ;'" | sort | uniq)

echo "Found Dependencies:
$ALL_DEPENDENCIES
"

echo "Found Imports:
$IMPORTS
"

# Check each import against the list from package.json
EXIT_CODE=0
for import in $IMPORTS; do
    # If it's a local path dependency, continue to the next iteration without warning
    if [[ $(jq -r ".dependencies[\"$import\"] // .devDependencies[\"$import\"]" "$PACKAGE_JSON_PATH") == file:* ]]; then
        continue
    fi

    if [[ ! " $ALL_DEPENDENCIES " =~ " $import " ]]; then
        echo "$import is used but not listed in package.json"
        EXIT_CODE=1
    fi
done

if [[ $EXIT_CODE == 1 ]]; then
    # use red text
    tput setaf 1
    echo "ERROR: Some imports are missing from package.json"
    tput sgr0
else
    # use green text
    tput setaf 2
    echo "SUCCESS: All imports are listed in package.json"
    tput sgr0
fi

exit $EXIT_CODE
