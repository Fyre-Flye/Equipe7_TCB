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

Write-Host "==> Gerando CSV principal do Python"
Invoke-NativeChecked { & $PythonBin ".\python\benchmark\counting_sort.py" }

Write-Host "==> Gerando CSV principal do Rust"
Invoke-NativeChecked { cargo run --release --manifest-path ".\rust\Cargo.toml" }

Write-Host "==> Gerando CSV complementar de variacao de k em Python"
Invoke-NativeChecked { & $PythonBin ".\python\benchmark\variacao_k.py" }

Write-Host "==> Gerando CSV complementar de variacao de k em Rust"
Invoke-NativeChecked { cargo run --release --manifest-path ".\rust\Cargo.toml" --bin variacao_k }

Write-Host "Benchmarks concluidos."
