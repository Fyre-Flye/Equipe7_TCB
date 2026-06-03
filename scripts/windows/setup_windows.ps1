$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RootDir

function Invoke-NativeChecked {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Comando falhou com codigo de saida $LASTEXITCODE"
    }
}

Write-Host "==> Verificando Python"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python nao encontrado. Instale Python 3 e marque a opcao para adiciona-lo ao PATH."
}

Write-Host "==> Criando ambiente virtual em .venv"
Invoke-NativeChecked { python -m venv .venv }

Write-Host "==> Ativando ambiente virtual"
& ".\.venv\Scripts\Activate.ps1"

Write-Host "==> Instalando dependencias Python"
Invoke-NativeChecked { python -m pip install --upgrade pip }
Invoke-NativeChecked { python -m pip install -r requirements.txt }

Write-Host "==> Verificando Rust/Cargo"
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    throw "Cargo nao encontrado. Instale Rust pelo rustup: https://rustup.rs/"
}

Write-Host "Ambiente pronto."
