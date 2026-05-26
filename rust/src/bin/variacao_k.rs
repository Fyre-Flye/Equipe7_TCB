use std::env;
use std::fs::{File, create_dir_all};
use std::io::{BufWriter, Write};
use std::path::PathBuf;
use std::time::Instant;

const RUNS: usize = 30;
const SCENARIOS: [(&str, usize, usize); 3] = [
    ("k_pequeno", 100_000, 100),
    ("k_igual_n", 100_000, 100_000),
    ("k_grande", 100_000, 1_000_000),
];

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

fn generate_vector(size: usize, k: usize, run: usize) -> Vec<usize> {
    let mut seed = 7_777 + size as u64 + k as u64 + run as u64;
    let mut values = Vec::with_capacity(size);

    for _ in 0..size {
        seed = next_lcg(seed);
        values.push((seed % k as u64) as usize);
    }

    values
}

fn is_sorted(values: &[usize]) -> bool {
    values.windows(2).all(|pair| pair[0] <= pair[1])
}

fn output_path() -> std::io::Result<PathBuf> {
    let current_dir = env::current_dir()?;
    let project_root = find_project_root(&current_dir).unwrap_or(current_dir);

    let output_dir = project_root.join("analise").join("dados");
    create_dir_all(&output_dir)?;
    Ok(output_dir.join("resultados_rust_variacao_k.csv"))
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

fn run_benchmark() -> std::io::Result<()> {
    let csv_path = output_path()?;
    let file = File::create(&csv_path)?;
    let mut writer = BufWriter::new(file);

    writeln!(
        writer,
        "linguagem,cenario_k,n,k,execucao,tempo_segundos,ordenado"
    )?;

    for (scenario_name, size, k) in SCENARIOS {
        for run in 1..=RUNS {
            let base_values = generate_vector(size, k, run);
            let mut values = base_values.clone();

            let start = Instant::now();
            counting_sort(&mut values);
            let elapsed = start.elapsed().as_secs_f64();

            writeln!(
                writer,
                "rust,{},{},{},{},{:.9},{}",
                scenario_name,
                size,
                k,
                run,
                elapsed,
                is_sorted(&values)
            )?;
        }
    }

    writer.flush()?;
    println!("CSV gerado: {}", csv_path.display());
    Ok(())
}

fn main() -> std::io::Result<()> {
    run_benchmark()
}
