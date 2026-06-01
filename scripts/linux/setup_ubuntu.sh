#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Este instalador automatico foi preparado para Ubuntu/Debian com apt-get."
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "sudo nao encontrado. Execute este script como root ou instale sudo."
  exit 1
fi

SYSTEM_PACKAGES=(
  python3
  python3-venv
  python3-pip
  curl
  ca-certificates
  build-essential
)

MISSING_PACKAGES=()
for package in "${SYSTEM_PACKAGES[@]}"; do
  if ! dpkg -s "$package" >/dev/null 2>&1; then
    MISSING_PACKAGES+=("$package")
  fi
done

if [ "${#MISSING_PACKAGES[@]}" -gt 0 ]; then
  echo "==> Instalando pacotes do sistema: ${MISSING_PACKAGES[*]}"
  $SUDO apt-get update
  $SUDO apt-get install -y "${MISSING_PACKAGES[@]}"
else
  echo "==> Pacotes do sistema ja instalados"
fi

echo "==> Criando ambiente virtual em .venv"
python3 -m venv .venv
source .venv/bin/activate

echo "==> Instalando dependencias Python"
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "==> Instalando Rust e Cargo pelo rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "==> Rust/Cargo ja instalados"
fi

echo "==> Validando ferramentas"
python --version
pip --version
rustc --version
cargo --version

echo "Ambiente pronto. Execute: bash scripts/linux/run_all.sh"
