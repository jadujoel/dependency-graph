#!/bin/bash

dir="${1:-../ecas/packages/}"
outfile="${2:-dependencies.txt}"
match="${3:-.*}"

## Find all package.json files in the given directory, and run process_package.sh on each one
find "$dir" \
  -name 'node_modules' -prune -o \
  -name 'package.json' \
  -exec ./process_package.sh "${match}" {} \; \
  > "$outfile"

echo "Wrote dependencies to $outfile"
