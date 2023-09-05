#!/bin/bash

input_dir="${1:-../ecas/packages/}"
output_dir="${2:-output/}"
selection="${3:-ecas}"

mkdir -p "${output_dir}"

uuid=$(uuidgen)

dep="gens/deps-${uuid}.txt"
dot="gens/graph-${uuid}.dot"
png="gens/graph-${uuid}.png"

# Generate a list of dependencies (replace `packages/*` with your package locations if different)
./find_dependencies.sh "${input_dir}" "${dep}" "${selection}"

# Generate a DOT file from the list of dependencies
./generate_dot_file.sh "${dep}" "${dot}"

# Generate a PNG from the DOT file
./generate_png.sh "${dot}" "${png}"
