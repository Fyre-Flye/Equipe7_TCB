import ctypes
import os
import platform
import subprocess
import sys
from pathlib import Path


def run_command(command):
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
            timeout=10,
        )
    except (OSError, subprocess.SubprocessError):
        return "Nao encontrado"

    output = (result.stdout or result.stderr).strip()
    return output.splitlines()[0] if output else "Nao encontrado"


def total_ram_gb():
    if platform.system().lower() != "windows":
        return "Nao identificado automaticamente"

    class MemoryStatusEx(ctypes.Structure):
        _fields_ = [
            ("dwLength", ctypes.c_ulong),
            ("dwMemoryLoad", ctypes.c_ulong),
            ("ullTotalPhys", ctypes.c_ulonglong),
            ("ullAvailPhys", ctypes.c_ulonglong),
            ("ullTotalPageFile", ctypes.c_ulonglong),
            ("ullAvailPageFile", ctypes.c_ulonglong),
            ("ullTotalVirtual", ctypes.c_ulonglong),
            ("ullAvailVirtual", ctypes.c_ulonglong),
            ("ullAvailExtendedVirtual", ctypes.c_ulonglong),
        ]

    status = MemoryStatusEx()
    status.dwLength = ctypes.sizeof(MemoryStatusEx)
    if not ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)):
        return "Nao identificado automaticamente"

    return f"{status.ullTotalPhys / (1024**3):.2f} GB"


def output_path():
    project_root = Path(__file__).resolve().parents[1]
    output_dir = project_root / "analise"
    output_dir.mkdir(exist_ok=True)
    return output_dir / "ambiente_execucao.txt"


def main():
    info = {
        "Sistema operacional": platform.platform(),
        "Processador": platform.processor() or platform.uname().processor or "Nao identificado",
        "Nucleos logicos": str(os.cpu_count() or "Nao identificado"),
        "RAM total": total_ram_gb(),
        "Python": sys.version.replace("\n", " "),
        "Rust": run_command(["rustc", "--version"]),
        "Cargo": run_command(["cargo", "--version"]),
        "Modo recomendado para Rust": "cargo run --release",
        "Observacao": "Fechar programas em segundo plano antes de coletar os tempos finais.",
    }

    path = output_path()
    with path.open("w", encoding="utf-8") as file:
        file.write("Ambiente de execucao\n")
        file.write("====================\n\n")
        for key, value in info.items():
            file.write(f"{key}: {value}\n")

    print(f"Arquivo gerado: {path}")


if __name__ == "__main__":
    main()
