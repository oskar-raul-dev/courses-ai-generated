#!/usr/bin/env bash
# Ejecuta un comando dentro del devcontainer amd64 del proyecto (etiqueta curso=angular-8-legacy).
set -euo pipefail
cd "$(dirname "$0")/../proyecto/clinical-lab"
exec npx -y @devcontainers/cli@0.89.0 exec --workspace-folder . --config .devcontainer/amd64/devcontainer.json --id-label curso=angular-8-legacy "$@"
