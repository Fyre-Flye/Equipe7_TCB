import csv
import os
from pathlib import Path
from time import perf_counter

from entradas_benchmark import ensure_input_plan

LCG_MODULUS = 2**32
CHECKSUM_MODULUS = 2**64


def counting_sort(values):
    if not values:
        return []

    max_value = max(values)
    count = [0] * (max_value + 1)

    for value in values:
        count[value] += 1

    sorted_values = []
    for value, frequency in enumerate(count):
        sorted_values.extend([value] * frequency)

    return sorted_values


def next_lcg(seed):
    return (seed * 1_664_525 + 1_013_904_223) % LCG_MODULUS


def generate_vector(size, k, seed):
    values = [k - 1]

    for _ in range(size - 1):
        seed = next_lcg(seed)
        values.append(seed % k)

    return values


def input_checksum(values):
    checksum = 0
    for index, value in enumerate(values, start=1):
        checksum = (checksum + index * (value + 1)) % CHECKSUM_MODULUS
    return checksum


def format_duration(total_seconds):
    total_seconds = int(total_seconds)
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{hours:02d}:{minutes:02d}:{seconds:02d}"


def progress_bar(completed, total, width=30):
    filled = int(completed / total * width)
    return f"[{'#' * filled}{'-' * (width - filled)}]"


def is_sorted(values):
    return all(values[index] <= values[index + 1] for index in range(len(values) - 1))


def output_path():
    project_root = Path(__file__).resolve().parents[2]
    output_dir = project_root / "analise" / "dados"
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir / "resultados_python.csv"


def run_benchmark():
    csv_path = output_path()
    input_path = ensure_input_plan()
    benchmark_start = perf_counter()
    progress_offset = int(os.environ.get("BENCHMARK_PROGRESS_OFFSET", "0"))
    progress_total = int(os.environ.get("BENCHMARK_PROGRESS_TOTAL", "90"))
    completed_runs = 0

    with csv_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(
            [
                "linguagem",
                "caso",
                "tamanho_label",
                "n",
                "k",
                "execucao",
                "seed",
                "checksum_entrada",
                "tempo_segundos",
                "ordenado",
            ]
        )

        with input_path.open("r", newline="", encoding="utf-8") as input_file:
            reader = csv.DictReader(input_file)

            for row in reader:
                case_name = row["caso"]
                size_label = row["tamanho_label"]
                size = int(row["n"])
                k = int(row["k"])
                run = int(row["execucao"])
                seed = int(row["seed"])
                values = generate_vector(size, k, seed)
                checksum = input_checksum(values)

                start = perf_counter()
                sorted_values = counting_sort(values)
                elapsed = perf_counter() - start

                writer.writerow(
                    [
                        "python",
                        case_name,
                        size_label,
                        size,
                        k,
                        run,
                        seed,
                        checksum,
                        f"{elapsed:.9f}",
                        is_sorted(sorted_values),
                    ]
                )

                completed_runs += 1
                total_completed = progress_offset + completed_runs
                progress_percent = total_completed / progress_total * 100
                progress_message = (
                    f"[Python] {case_name} - execucao {run}/30 "
                    f"- {progress_bar(total_completed, progress_total)} "
                    f"{total_completed}/{progress_total} ({progress_percent:.1f}%)"
                )
                print(f"\r{progress_message:<170}", end="", flush=True)

    total_elapsed = perf_counter() - benchmark_start
    print()
    print(f"CSV gerado: {csv_path}")
    print(f"Benchmark Python concluido em {format_duration(total_elapsed)}")


if __name__ == "__main__":
    run_benchmark()
