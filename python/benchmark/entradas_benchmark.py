import csv
from pathlib import Path


RUNS = 30
SCENARIOS = [
    ("melhor", "n_fixo_k_pequeno", 1_000_000, 100),
    ("medio", "n_fixo_k_igual_n", 1_000_000, 1_000_000),
    ("pior", "n_fixo_k_grande", 1_000_000, 100_000_000),
]


def project_root():
    return Path(__file__).resolve().parents[2]


def input_plan_path():
    output_dir = project_root() / "analise" / "dados"
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir / "entradas_benchmark.csv"


def seed_for(case_name, n, k, run):
    case_offset = {"melhor": 11, "medio": 17, "pior": 23}[case_name]
    return 9_973 + case_offset + n + k + run


def generate_input_plan():
    csv_path = input_plan_path()

    with csv_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["caso", "tamanho_label", "n", "k", "execucao", "seed"])

        for case_name, size_label, n, k in SCENARIOS:
            for run in range(1, RUNS + 1):
                writer.writerow([case_name, size_label, n, k, run, seed_for(case_name, n, k, run)])

    return csv_path


def ensure_input_plan():
    csv_path = input_plan_path()
    if not csv_path.exists():
        generate_input_plan()
    return csv_path


if __name__ == "__main__":
    path = generate_input_plan()
    print(f"Plano de entradas gerado: {path}")
