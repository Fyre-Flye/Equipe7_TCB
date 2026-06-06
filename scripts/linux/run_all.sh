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

format_duration() {
  local total_seconds="$1"
  printf '%02d:%02d:%02d' \
    $((total_seconds / 3600)) \
    $(((total_seconds % 3600) / 60)) \
    $((total_seconds % 60))
}

run_step() {
  local step="$1"
  local total="$2"
  local name="$3"
  shift 3

  echo "==> [$step/$total] $name"
  local start_time=$SECONDS
  "$@"
  echo "    Etapa concluida em $(format_duration $((SECONDS - start_time)))."
}

TOTAL_START=$SECONDS

run_step 1 4 "Limpando saidas anteriores" \
  bash scripts/linux/clean_outputs.sh
run_step 2 4 "Registrando ambiente de execucao" \
  "$PYTHON_BIN" python/ambiente_execucao.py
run_step 3 4 "Rodando benchmarks" \
  bash scripts/linux/run_benchmarks.sh
run_step 4 4 "Gerando tabelas e graficos" \
  bash scripts/linux/run_notebook.sh

echo "Fluxo completo concluido em $(format_duration $((SECONDS - TOTAL_START)))."
