$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

$VenvPython = Join-Path $RootDir ".venv\Scripts\python.exe"
$PythonBin = if (Test-Path $VenvPython) { $VenvPython } else { "python" }

$env:JUPYTER_ALLOW_INSECURE_WRITES = "1"
$env:IPYTHONDIR = Join-Path $RootDir "analise\ipython"
$env:JUPYTER_CONFIG_DIR = Join-Path $RootDir "analise\jupyter_config"
$env:JUPYTER_DATA_DIR = Join-Path $RootDir "analise\jupyter_data"
$env:JUPYTER_RUNTIME_DIR = Join-Path $RootDir "analise\jupyter_runtime"
$env:MPLCONFIGDIR = Join-Path $RootDir "analise\matplotlib_config"

New-Item -ItemType Directory -Force -Path `
    $env:IPYTHONDIR, `
    $env:JUPYTER_CONFIG_DIR, `
    $env:JUPYTER_DATA_DIR, `
    $env:JUPYTER_RUNTIME_DIR, `
    $env:MPLCONFIGDIR | Out-Null

Write-Host "==> Executando notebook de analise"
& $PythonBin -m jupyter nbconvert `
    --to notebook `
    --execute "$RootDir\analise\notebooks\padronizacao_graficos.ipynb" `
    --output "padronizacao_graficos_executado.ipynb" `
    --output-dir "$RootDir\analise\notebooks"

Write-Host "Notebook executado."

