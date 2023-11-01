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
IMPORTS_RAW=$(find "$SOURCE_CODE_PATH" -type f \( -name "*.ts" -o -name "*.tsx" \) -exec awk '/import/,/from/' {} \; | grep -oE "from ['\"](@?[^'\"]+)['\"]" | grep -oE "['\"](@?[^'\"]+)['\"]" | tr -d "'\"" | grep -vE "^\.")

# Extract the base package or scoped name
IMPORTS=$(echo "$IMPORTS_RAW" | while read -r line; do
    if [[ $line == @* ]]; then
        # For scoped packages
        echo "$line" | awk -F"/" '{if (NF>1) print $1"/"$2; else print $1}'
    else
        # For regular packages
        echo "$line" | awk -F"/" '{print $1}'
    fi
done | sort | uniq)

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
