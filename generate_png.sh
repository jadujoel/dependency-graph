#!/bin/bash
input="${1:-graph.dot}"
output="${2:-graph.png}"
dot -Tpng "${input}" -o "${output}"
echo "Wrote PNG file to ${output}"
