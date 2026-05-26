#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

echo "==> Gerando CSV principal do Python"
"$PYTHON_BIN" python/benchmark/counting_sort.py

echo "==> Gerando CSV principal do Rust"
cargo run --release --manifest-path rust/Cargo.toml

echo "==> Gerando CSV complementar de variacao de k em Python"
"$PYTHON_BIN" python/benchmark/variacao_k.py

echo "==> Gerando CSV complementar de variacao de k em Rust"
cargo run --release --manifest-path rust/Cargo.toml --bin variacao_k

echo "Benchmarks concluidos."
