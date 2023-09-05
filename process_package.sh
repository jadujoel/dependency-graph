#!/bin/bash

# Default to a regex that matches everything
match="${1:-.*}"

str="select(.dependencies != null or .devDependencies != null) |
  .name as \$parent |
  (.dependencies // {}) + (.devDependencies // {}) |
  to_entries[] |
  select(.key | test(\"${match}\"; \"i\")) |
  \"\(\$parent) \(.key)\""

jq -r "${str}" "$2"
