$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RootDir

$VenvPython = Join-Path $RootDir ".venv\Scripts\python.exe"
$PythonBin = if (Test-Path $VenvPython) { $VenvPython } else { "python" }

function Invoke-NativeChecked {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Comando falhou com codigo de saida $LASTEXITCODE"
    }
}

Write-Host "==> Registrando ambiente de execucao"
Invoke-NativeChecked { & $PythonBin ".\python\ambiente_execucao.py" }

Write-Host "==> Rodando benchmarks"
& ".\scripts\windows\run_benchmarks.ps1"

Write-Host "==> Gerando tabelas e graficos"
& ".\scripts\windows\run_notebook.ps1"

Write-Host "Fluxo completo concluido."
