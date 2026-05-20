fn counting_sort(arr: &mut [usize]) {
    if arr.is_empty() {
        return;
    }

    // Find the maximum value
    let max_value = *arr.iter().max().unwrap();

    // Create count array
    let mut count = vec![0usize; max_value + 1];

    // Count occurrences
    for &num in arr.iter() {
        count[num] += 1;
    }

    // Rebuild the sorted array
    let mut index = 0;
    for value in 0..count.len() {
        for _ in 0..count[value] {
            arr[index] = value;
            index += 1;
        }
    }
}

fn main() {
    let mut data = vec![4, 2, 2, 8, 3, 3, 1];

    println!("Before sorting: {:?}", data);

    counting_sort(&mut data);

    println!("After sorting:  {:?}", data);
}