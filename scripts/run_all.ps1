$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

$VenvPython = Join-Path $RootDir ".venv\Scripts\python.exe"
$PythonBin = if (Test-Path $VenvPython) { $VenvPython } else { "python" }

Write-Host "==> Registrando ambiente de execucao"
& $PythonBin ".\python\ambiente_execucao.py"

Write-Host "==> Rodando benchmarks"
& ".\scripts\run_benchmarks.ps1"

Write-Host "==> Gerando tabelas e graficos"
& ".\scripts\run_notebook.ps1"

Write-Host "Fluxo completo concluido."

