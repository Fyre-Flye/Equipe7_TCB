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


def operating_system():
    system = platform.system()
    if system.lower() == "linux":
        description = run_command(["lsb_release", "-ds"])
        if description != "Nao encontrado":
            return f"{description.strip('\"')} ({platform.release()})"

    return platform.platform()


def processor_name():
    system = platform.system().lower()
    if system == "linux":
        cpuinfo_path = Path("/proc/cpuinfo")
        if cpuinfo_path.exists():
            for line in cpuinfo_path.read_text(encoding="utf-8", errors="ignore").splitlines():
                if line.lower().startswith("model name"):
                    return line.split(":", maxsplit=1)[-1].strip()

    return platform.processor() or platform.uname().processor or "Nao identificado"


def total_ram_gb():
    system = platform.system().lower()
    if system == "linux":
        meminfo_path = Path("/proc/meminfo")
        if meminfo_path.exists():
            for line in meminfo_path.read_text(encoding="utf-8", errors="ignore").splitlines():
                if line.startswith("MemTotal:"):
                    total_kib = int(line.split()[1])
                    return f"{total_kib / (1024**2):.2f} GB"
        return "Nao identificado automaticamente"

    if system != "windows":
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


def processor_frequency():
    system = platform.system().lower()
    if system == "linux":
        cpuinfo_path = Path("/proc/cpuinfo")
        if cpuinfo_path.exists():
            for line in cpuinfo_path.read_text(encoding="utf-8", errors="ignore").splitlines():
                if line.lower().startswith("cpu mhz"):
                    mhz = float(line.split(":", maxsplit=1)[-1].strip())
                    return f"{mhz / 1000:.2f} GHz"

        frequency_khz_path = Path("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
        if frequency_khz_path.exists():
            frequency_khz = int(frequency_khz_path.read_text(encoding="utf-8").strip())
            return f"{frequency_khz / 1_000_000:.2f} GHz"

    if system == "windows":
        try:
            import winreg

            with winreg.OpenKey(
                winreg.HKEY_LOCAL_MACHINE,
                r"HARDWARE\DESCRIPTION\System\CentralProcessor\0",
            ) as key:
                mhz, _ = winreg.QueryValueEx(key, "~MHz")
                return f"{mhz / 1000:.2f} GHz"
        except (OSError, ImportError):
            pass

        powershell_result = run_command(
            [
                "powershell",
                "-NoProfile",
                "-Command",
                "(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty MaxClockSpeed)",
            ]
        )
        if powershell_result.isdigit():
            return f"{int(powershell_result) / 1000:.2f} GHz"

        wmic_result = run_command(["wmic", "cpu", "get", "MaxClockSpeed", "/format:list"])
        if "=" in wmic_result:
            mhz = int(wmic_result.split("=", maxsplit=1)[-1])
            return f"{mhz / 1000:.2f} GHz"

    return "Nao identificado automaticamente"


def output_path():
    project_root = Path(__file__).resolve().parents[1]
    output_dir = project_root / "analise" / "ambiente"
    output_dir.mkdir(exist_ok=True)
    return output_dir / "ambiente_execucao.txt"


def main():
    info = {
        "Sistema operacional": operating_system(),
        "Processador": processor_name(),
        "Arquitetura": platform.architecture()[0],
        "Frequencia do processador": processor_frequency(),
        "Nucleos logicos": str(os.cpu_count() or "Nao identificado"),
        "RAM total": total_ram_gb(),
        "Python": sys.version.replace("\n", " "),
        "Rust": run_command(["rustc", "--version"]),
        "Cargo": run_command(["cargo", "--version"]),
        "Modo recomendado para Rust": "cargo run --release"
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
