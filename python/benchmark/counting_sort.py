import csv
from pathlib import Path
from time import perf_counter


RUNS = 30
SIZES = [
    ("pequena", 1_000),
    ("media", 10_000),
    ("grande", 1_000_000),
]
CASES = ("melhor", "medio", "pior")


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
    return (seed * 1_664_525 + 1_013_904_223) % (2**32)


def generate_vector(case_name, size, run):
    if case_name == "melhor":
        return list(range(size))
    if case_name == "pior":
        return list(range(size - 1, -1, -1))
    if case_name == "medio":
        seed = 42 + size + run
        values = []
        for _ in range(size):
            seed = next_lcg(seed)
            values.append(seed % size)
        return values

    raise ValueError(f"Caso desconhecido: {case_name}")


def is_sorted(values):
    return all(values[index] <= values[index + 1] for index in range(len(values) - 1))


def output_path():
    project_root = Path(__file__).resolve().parents[2]
    output_dir = project_root / "analise" / "dados"
    output_dir.mkdir(exist_ok=True)
    return output_dir / "resultados_python.csv"


def run_benchmark():
    csv_path = output_path()

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
                "tempo_segundos",
                "ordenado",
            ]
        )

        for size_label, size in SIZES:
            for case_name in CASES:
                for run in range(1, RUNS + 1):
                    base_values = generate_vector(case_name, size, run)
                    values = list(base_values)

                    start = perf_counter()
                    sorted_values = counting_sort(values)
                    elapsed = perf_counter() - start

                    writer.writerow(
                        [
                            "python",
                            case_name,
                            size_label,
                            size,
                            size,
                            run,
                            f"{elapsed:.9f}",
                            is_sorted(sorted_values),
                        ]
                    )

    print(f"CSV gerado: {csv_path}")


if __name__ == "__main__":
    run_benchmark()
