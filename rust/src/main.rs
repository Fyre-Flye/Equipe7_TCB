use std::env;
use std::fs::{File, create_dir_all};
use std::io::{BufRead, BufReader, BufWriter, Write};
use std::path::PathBuf;
use std::time::Instant;

const RUNS: usize = 30;
const SCENARIOS: [(&str, &str, usize, usize); 3] = [
    ("melhor", "n_fixo_k_pequeno", 1_000_000, 100),
    ("medio", "n_fixo_k_igual_n", 1_000_000, 1_000_000),
    ("pior", "n_fixo_k_grande", 1_000_000, 100_000_000),
];

struct InputCase {
    case_name: String,
    size_label: String,
    n: usize,
    k: usize,
    run: usize,
    seed: u64,
}

fn counting_sort(values: &mut [usize]) {
    if values.is_empty() {
        return;
    }

    let max_value = *values.iter().max().unwrap();
    let mut count = vec![0usize; max_value + 1];

    for &value in values.iter() {
        count[value] += 1;
    }

    let mut index = 0;
    for (value, &frequency) in count.iter().enumerate() {
        for _ in 0..frequency {
            values[index] = value;
            index += 1;
        }
    }
}

fn next_lcg(seed: u64) -> u64 {
    (seed * 1_664_525 + 1_013_904_223) % (u32::MAX as u64 + 1)
}

fn generate_vector(size: usize, k: usize, mut seed: u64) -> Vec<usize> {
    let mut values = Vec::with_capacity(size);
    values.push(k - 1);

    for _ in 1..size {
        seed = next_lcg(seed);
        values.push((seed % k as u64) as usize);
    }

    values
}

fn input_checksum(values: &[usize]) -> u64 {
    let mut checksum = 0u64;

    for (index, &value) in values.iter().enumerate() {
        let position = index as u64 + 1;
        checksum = checksum.wrapping_add(position.wrapping_mul(value as u64 + 1));
    }

    checksum
}

fn format_duration(total_seconds: u64) -> String {
    let hours = total_seconds / 3_600;
    let minutes = (total_seconds % 3_600) / 60;
    let seconds = total_seconds % 60;
    format!("{hours:02}:{minutes:02}:{seconds:02}")
}

fn progress_bar(completed: usize, total: usize, width: usize) -> String {
    let filled = completed * width / total;
    format!("[{}{}]", "#".repeat(filled), "-".repeat(width - filled))
}

fn is_sorted(values: &[usize]) -> bool {
    values.windows(2).all(|pair| pair[0] <= pair[1])
}

fn output_path() -> std::io::Result<PathBuf> {
    let current_dir = env::current_dir()?;
    let project_root = find_project_root(&current_dir).unwrap_or(current_dir);

    let output_dir = project_root.join("analise").join("dados");
    create_dir_all(&output_dir)?;
    Ok(output_dir.join("resultados_rust.csv"))
}

fn input_plan_path() -> std::io::Result<PathBuf> {
    let current_dir = env::current_dir()?;
    let project_root = find_project_root(&current_dir).unwrap_or(current_dir);

    let output_dir = project_root.join("analise").join("dados");
    create_dir_all(&output_dir)?;
    Ok(output_dir.join("entradas_benchmark.csv"))
}

fn find_project_root(start_dir: &std::path::Path) -> Option<PathBuf> {
    for dir in start_dir.ancestors() {
        if dir.join("rust").join("Cargo.toml").exists() {
            return Some(dir.to_path_buf());
        }

        if dir
            .file_name()
            .is_some_and(|name| name.to_string_lossy().eq_ignore_ascii_case("rust"))
            && dir.join("Cargo.toml").exists()
        {
            return dir.parent().map(std::path::Path::to_path_buf);
        }
    }

    None
}

fn seed_for(case_name: &str, n: usize, k: usize, run: usize) -> u64 {
    let case_offset = match case_name {
        "melhor" => 11,
        "medio" => 17,
        "pior" => 23,
        _ => panic!("Caso desconhecido: {}", case_name),
    };

    9_973 + case_offset + n as u64 + k as u64 + run as u64
}

fn ensure_input_plan() -> std::io::Result<PathBuf> {
    let csv_path = input_plan_path()?;
    if csv_path.exists() {
        return Ok(csv_path);
    }

    let file = File::create(&csv_path)?;
    let mut writer = BufWriter::new(file);

    writeln!(writer, "caso,tamanho_label,n,k,execucao,seed")?;
    for (case_name, size_label, n, k) in SCENARIOS {
        for run in 1..=RUNS {
            writeln!(
                writer,
                "{},{},{},{},{},{}",
                case_name,
                size_label,
                n,
                k,
                run,
                seed_for(case_name, n, k, run)
            )?;
        }
    }

    writer.flush()?;
    Ok(csv_path)
}

fn read_input_plan() -> std::io::Result<Vec<InputCase>> {
    let csv_path = ensure_input_plan()?;
    let file = File::open(csv_path)?;
    let reader = BufReader::new(file);
    let mut inputs = Vec::new();

    for (line_index, line_result) in reader.lines().enumerate() {
        let line = line_result?;
        if line_index == 0 {
            continue;
        }

        let fields: Vec<&str> = line.split(',').collect();
        if fields.len() != 6 {
            continue;
        }

        inputs.push(InputCase {
            case_name: fields[0].to_string(),
            size_label: fields[1].to_string(),
            n: fields[2].parse().expect("n invalido no plano de entradas"),
            k: fields[3].parse().expect("k invalido no plano de entradas"),
            run: fields[4].parse().expect("execucao invalida no plano de entradas"),
            seed: fields[5].parse().expect("seed invalido no plano de entradas"),
        });
    }

    Ok(inputs)
}

fn run_benchmark() -> std::io::Result<()> {
    let csv_path = output_path()?;
    let inputs = read_input_plan()?;
    let file = File::create(&csv_path)?;
    let mut writer = BufWriter::new(file);
    let benchmark_start = Instant::now();
    let progress_offset = env::var("BENCHMARK_PROGRESS_OFFSET")
        .ok()
        .and_then(|value| value.parse::<usize>().ok())
        .unwrap_or(0);
    let progress_total = env::var("BENCHMARK_PROGRESS_TOTAL")
        .ok()
        .and_then(|value| value.parse::<usize>().ok())
        .unwrap_or(RUNS * SCENARIOS.len());
    let mut completed_runs = 0usize;

    writeln!(
        writer,
        "linguagem,caso,tamanho_label,n,k,execucao,seed,checksum_entrada,tempo_segundos,ordenado"
    )?;

    for input in inputs {
        let mut values = generate_vector(input.n, input.k, input.seed);
        let checksum = input_checksum(&values);

        let start = Instant::now();
        counting_sort(&mut values);
        let elapsed = start.elapsed().as_secs_f64();

        writeln!(
            writer,
            "rust,{},{},{},{},{},{},{},{:.9},{}",
            input.case_name,
            input.size_label,
            input.n,
            input.k,
            input.run,
            input.seed,
            checksum,
            elapsed,
            is_sorted(&values)
        )?;

        completed_runs += 1;
        let total_completed = progress_offset + completed_runs;
        let progress_percent = total_completed as f64 / progress_total as f64 * 100.0;
        let bar = progress_bar(total_completed, progress_total, 30);
        let progress_message = format!(
            "[Rust] {} - execucao {}/{} - {} {}/{} ({:.1}%)",
            input.case_name,
            input.run,
            RUNS,
            bar,
            total_completed,
            progress_total,
            progress_percent
        );
        print!("\r{:<170}", progress_message);
        std::io::stdout().flush()?;
    }

    writer.flush()?;
    println!();
    println!("CSV gerado: {}", csv_path.display());
    println!(
        "Benchmark Rust concluido em {}",
        format_duration(benchmark_start.elapsed().as_secs())
    );
    Ok(())
}

fn main() -> std::io::Result<()> {
    run_benchmark()
}
