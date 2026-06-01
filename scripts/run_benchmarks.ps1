$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

$VenvPython = Join-Path $RootDir ".venv\Scripts\python.exe"
$PythonBin = if (Test-Path $VenvPython) { $VenvPython } else { "python" }

Write-Host "==> Gerando CSV principal do Python"
& $PythonBin ".\python\benchmark\counting_sort.py"

Write-Host "==> Gerando CSV principal do Rust"
cargo run --release --manifest-path ".\rust\Cargo.toml"

Write-Host "==> Gerando CSV complementar de variacao de k em Python"
& $PythonBin ".\python\benchmark\variacao_k.py"

Write-Host "==> Gerando CSV complementar de variacao de k em Rust"
cargo run --release --manifest-path ".\rust\Cargo.toml" --bin variacao_k

Write-Host "Benchmarks concluidos."

