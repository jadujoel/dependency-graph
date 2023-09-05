#!/bin/bash

input="${1:-dependencies.txt}"
output="${2:-graph.dot}"

# Create a DOT file for Graphviz
echo "digraph G {" > "${output}"
awk '{print "  \"" $1 "\" -> \"" $2 "\";"}' "${input}" >> "${output}"
echo "}" >> "${output}"

echo "Wrote DOT file to ${output}"
