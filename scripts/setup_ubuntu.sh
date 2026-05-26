#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Verificando Python"
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 nao encontrado. Instale com: sudo apt install python3 python3-venv python3-pip"
  exit 1
fi

echo "==> Criando ambiente virtual em .venv"
python3 -m venv .venv
source .venv/bin/activate

echo "==> Instalando dependencias Python"
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

echo "==> Verificando Rust/Cargo"
if ! command -v cargo >/dev/null 2>&1; then
  echo "Cargo nao encontrado."
  echo "Instale Rust pelo rustup: https://rustup.rs/"
  echo "Comando comum: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  exit 1
fi

echo "Ambiente pronto."

