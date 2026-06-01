#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "==> Removendo saidas geradas"
rm -f \
  analise/dados/*.csv \
  analise/tabelas/*.csv \
  analise/graficos/*.png \
  analise/notebooks/padronizacao_graficos_executado.ipynb \
  analise/ambiente/ambiente_execucao.txt

echo "Saidas removidas. Codigo-fonte e notebook editavel foram preservados."
