$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

Write-Host "==> Verificando Python"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python nao encontrado. Instale Python 3 e marque a opcao para adiciona-lo ao PATH."
}

Write-Host "==> Criando ambiente virtual em .venv"
python -m venv .venv

Write-Host "==> Ativando ambiente virtual"
& ".\.venv\Scripts\Activate.ps1"

Write-Host "==> Instalando dependencias Python"
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

Write-Host "==> Verificando Rust/Cargo"
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    throw "Cargo nao encontrado. Instale Rust pelo rustup: https://rustup.rs/"
}

Write-Host "Ambiente pronto."

