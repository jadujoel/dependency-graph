#!/bin/bash
input="${1}"
# Create a string list with name of packages
PACKAGES=$(ls -d "$input"/*)
echo "Found packages:
$PACKAGES
"

for package in $PACKAGES; do
    bash ./check-deps.sh "$package"
done
