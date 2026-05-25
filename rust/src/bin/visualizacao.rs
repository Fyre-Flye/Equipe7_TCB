use std::env;
use std::thread::sleep;
use std::time::Duration;

fn wait(delay: Duration) {
    if !delay.is_zero() {
        sleep(delay);
    }
}

fn counting_sort_visual(values: &[usize], delay: Duration) -> Vec<usize> {
    println!("Counting Sort - visualizacao em Rust");
    println!("Vetor original: {:?}", values);
    wait(delay);

    if values.is_empty() {
        println!("Vetor vazio. Nada a ordenar.");
        return Vec::new();
    }

    let max_value = *values.iter().max().unwrap();
    let mut count = vec![0usize; max_value + 1];

    println!("\nMaior valor encontrado: {}", max_value);
    println!("Vetor de contagem inicial: {:?}", count);
    wait(delay);

    println!("\n1) Contando ocorrencias");
    for &value in values {
        count[value] += 1;
        println!(
            "Valor {}: count[{}] = {} -> {:?}",
            value, value, count[value], count
        );
        wait(delay);
    }

    println!("\n2) Reconstruindo o vetor ordenado");
    wait(delay);
    let mut sorted_values = Vec::with_capacity(values.len());

    for (value, &frequency) in count.iter().enumerate() {
        if frequency > 0 {
            println!("Valor {} aparece {} vez(es).", value, frequency);
            wait(delay);
        }

        for _ in 0..frequency {
            sorted_values.push(value);
            println!("Adiciona {}: {:?}", value, sorted_values);
            wait(delay);
        }
    }

    println!("\nVetor ordenado: {:?}", sorted_values);
    sorted_values
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let delay = if args.iter().any(|argument| argument == "--no-delay") {
        Duration::from_millis(0)
    } else if args.iter().any(|argument| argument == "--fast") {
        Duration::from_millis(250)
    } else if args.iter().any(|argument| argument == "--slow") {
        Duration::from_millis(1500)
    } else {
        Duration::from_millis(800)
    };

    let example = vec![4, 2, 2, 8, 3, 3, 1];
    counting_sort_visual(&example, delay);
}
