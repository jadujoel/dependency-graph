# Dependency Graph

## Requirements

- [Graphvitz](https://graphviz.gitlab.io/download/)
- [jq](https://jqlang.github.io/jq/download/)

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

## Example

```bash
brew install graphviz
bash main.sh "../ecas" "./gens" "ecas"
bash main.sh "../ecas" "./gens" "^(?!.*ecas-docs).*ecas.*$"
```

There is also another script included that checks that you dont use any unlisted dependencies.
The check-deps.sh.

```bash
bash check-deps.sh "../ecas/packages/ecas-engine"
```
