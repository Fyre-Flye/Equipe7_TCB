#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [ -d ".venv" ]; then
  source .venv/bin/activate
fi

if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

if [ -z "${PYTHON_BIN:-}" ]; then
  if command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  else
    PYTHON_BIN="python3"
  fi
fi

echo "==> Registrando ambiente de execucao"
"$PYTHON_BIN" python/ambiente_execucao.py

echo "==> Rodando benchmarks"
bash scripts/linux/run_benchmarks.sh

echo "==> Gerando tabelas e graficos"
bash scripts/linux/run_notebook.sh

echo "Fluxo completo concluido."
