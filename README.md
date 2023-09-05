# Dependency Graph

## Requirements

- [Graphvitz](https://graphviz.gitlab.io/download/)
- [ja](https://jqlang.github.io/jq/download/)

## Get Started

Install the requirements above.

Make the scripts executable

```bash
chmod +x ./*
```

Generate the png file

```bash
./main.sh <path_to_my_monorepo> <path_to_output_directory> <match_selection>
# ex:
./main.sh ../ecas ./output ecas
```

This will look in the ecas monorepo for any dependency that includes ecas in the name.
