$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RootDir

$Targets = @(
    ".\analise\dados\*.csv",
    ".\analise\tabelas\*.csv",
    ".\analise\graficos\*.png",
    ".\analise\notebooks\padronizacao_graficos_executado.ipynb",
    ".\analise\ambiente\ambiente_execucao.txt"
)

Write-Host "==> Removendo saidas geradas"
foreach ($Target in $Targets) {
    Remove-Item -Path $Target -Force -ErrorAction SilentlyContinue
}

Write-Host "Saidas removidas. Codigo-fonte e notebook editavel foram preservados."
