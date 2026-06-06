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

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "==> Executando notebook de analise"
Invoke-NativeChecked {
    & $PythonBin -m jupyter nbconvert `
        --to notebook `
        --execute "$RootDir\analise\notebooks\padronizacao_graficos.ipynb" `
        --output "padronizacao_graficos_executado.ipynb" `
        --output-dir "$RootDir\analise\notebooks"
}

$stopwatch.Stop()
$duration = "{0:00}:{1:00}:{2:00}" -f [math]::Floor($stopwatch.Elapsed.TotalHours), $stopwatch.Elapsed.Minutes, $stopwatch.Elapsed.Seconds
Write-Host "Notebook executado em $duration."
