#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [ -d ".venv" ]; then
  source .venv/bin/activate
fi

if [ -z "${PYTHON_BIN:-}" ]; then
  if command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  else
    PYTHON_BIN="python3"
  fi
fi

export MPLCONFIGDIR="$ROOT_DIR/analise/matplotlib_config"
mkdir -p "$MPLCONFIGDIR"

echo "==> Executando notebook de analise"
"$PYTHON_BIN" -m jupyter nbconvert \
  --to notebook \
  --execute "$ROOT_DIR/analise/notebooks/padronizacao_graficos.ipynb" \
  --output "padronizacao_graficos_executado.ipynb" \
  --output-dir "$ROOT_DIR/analise/notebooks"

echo "Notebook executado."
