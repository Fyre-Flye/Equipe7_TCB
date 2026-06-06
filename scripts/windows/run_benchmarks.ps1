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

function Invoke-BenchmarkStep {
    param(
        [int]$Step,
        [int]$Total,
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host "    -> [$Step/$Total] $Name"
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    & $Command
    $stopwatch.Stop()
    Write-Host "       Concluido em $(Format-Duration $stopwatch.Elapsed)."
}

$totalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Invoke-BenchmarkStep 1 3 "Gerando plano compartilhado de entradas" {
    Invoke-NativeChecked { & $PythonBin ".\python\benchmark\entradas_benchmark.py" }
}

Invoke-BenchmarkStep 2 3 "Executando benchmark do Python" {
    $env:BENCHMARK_PROGRESS_OFFSET = "0"
    $env:BENCHMARK_PROGRESS_TOTAL = "180"
    try {
        Invoke-NativeChecked { & $PythonBin ".\python\benchmark\counting_sort.py" }
    }
    finally {
        Remove-Item Env:BENCHMARK_PROGRESS_OFFSET -ErrorAction SilentlyContinue
        Remove-Item Env:BENCHMARK_PROGRESS_TOTAL -ErrorAction SilentlyContinue
    }
}

Invoke-BenchmarkStep 3 3 "Executando benchmark do Rust" {
    $env:BENCHMARK_PROGRESS_OFFSET = "90"
    $env:BENCHMARK_PROGRESS_TOTAL = "180"
    try {
        Invoke-NativeChecked { cargo run --release --manifest-path ".\rust\Cargo.toml" }
    }
    finally {
        Remove-Item Env:BENCHMARK_PROGRESS_OFFSET -ErrorAction SilentlyContinue
        Remove-Item Env:BENCHMARK_PROGRESS_TOTAL -ErrorAction SilentlyContinue
    }
}

$totalStopwatch.Stop()
Write-Host "Benchmarks concluidos em $(Format-Duration $totalStopwatch.Elapsed)."
