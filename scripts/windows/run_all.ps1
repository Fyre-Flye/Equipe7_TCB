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

function Format-Duration {
    param([TimeSpan]$Duration)
    return "{0:00}:{1:00}:{2:00}" -f [math]::Floor($Duration.TotalHours), $Duration.Minutes, $Duration.Seconds
}

function Invoke-TimedStep {
    param(
        [int]$Step,
        [int]$Total,
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host "==> [$Step/$Total] $Name"

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    & $Command
    $stopwatch.Stop()

    Write-Host "    Etapa concluida em $(Format-Duration $stopwatch.Elapsed)."
}

$totalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    Invoke-TimedStep 1 4 "Limpando saidas anteriores" {
        & ".\scripts\windows\clean_outputs.ps1"
    }

    Invoke-TimedStep 2 4 "Registrando ambiente de execucao" {
        Invoke-NativeChecked { & $PythonBin ".\python\ambiente_execucao.py" }
    }

    Invoke-TimedStep 3 4 "Rodando benchmarks" {
        & ".\scripts\windows\run_benchmarks.ps1"
    }

    Invoke-TimedStep 4 4 "Gerando tabelas e graficos" {
        & ".\scripts\windows\run_notebook.ps1"
    }
}
finally {
    $totalStopwatch.Stop()
}

Write-Host "Fluxo completo concluido em $(Format-Duration $totalStopwatch.Elapsed)."
