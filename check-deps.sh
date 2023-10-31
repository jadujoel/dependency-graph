#!/bin/bash

PACKAGE_PATH="${1}"
VERBOSE="${2:-false}"

# Path to the subpackage's package.json
PACKAGE_JSON_PATH="$PACKAGE_PATH/package.json"

# Get the last part of the path, which is the package name
PACKAGE_NAME=$(echo "$PACKAGE_PATH" | awk -F"/" '{print $NF}')

# Extract dependencies and devDependencies
DEPENDENCIES=$(jq -r '.dependencies // {} | keys[]' "$PACKAGE_JSON_PATH")
DEV_DEPENDENCIES=$(jq -r '.devDependencies // {} | keys[]' "$PACKAGE_JSON_PATH")

# Merge the two lists and remove duplicates
ALL_DEPENDENCIES=$(echo "$DEPENDENCIES $DEV_DEPENDENCIES" | tr ' ' '\n' | sort | uniq)

# Path to the subpackage's source code directory
SOURCE_CODE_PATH="$PACKAGE_PATH/src"


# Find all imports in the source code from .ts and .tsx files, and remove duplicates
IMPORTS=$(find $SOURCE_CODE_PATH -type f \( -name "*.ts" -o -name "*.tsx" \) -exec grep -hoE "^import .* from ['\"](@[^'\"]+|[^./][^'\"]*)['\"]" {} \; | awk -F"from" '{print $2}' | tr -d " ;'" | sort | uniq)


if [[ $VERBOSE == true ]]; then
  echo "Found Dependencies:
$ALL_DEPENDENCIES
Found Imports:
$IMPORTS
"
fi

# Check each import against the list from package.json
EXIT_CODE=0

NOT_LISTED_IMPORTS=""

for import in $IMPORTS; do
    import=$(echo "$import" | tr -d '"')
    # If it's a local path dependency, continue to the next iteration without warning
    if [[ $(jq -r ".dependencies[\"$import\"] // .devDependencies[\"$import\"]" "$PACKAGE_JSON_PATH") == file:* ]]; then
        continue
    fi

    if [[ ! " $ALL_DEPENDENCIES " =~ " $import " ]]; then
        NOT_LISTED_IMPORTS="$NOT_LISTED_IMPORTS $import"
        EXIT_CODE=1
    fi
done

if [[ $EXIT_CODE == 1 ]]; then
    # use red text
    tput setaf 1
    echo "ERROR: [$PACKAGE_NAME] Missing imports:"
    echo "$NOT_LISTED_IMPORTS"
    tput sgr0
else
    # use green text
    tput setaf 2
    echo "SUCCESS: [$PACKAGE_NAME]"
    tput sgr0
fi

exit $EXIT_CODE
