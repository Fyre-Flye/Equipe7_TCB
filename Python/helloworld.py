def counting_sort(arr):
    if not arr:
        return arr

    # Find the maximum value
    max_value = max(arr)

    # Create count array
    count = [0] * (max_value + 1)

    # Count occurrences
    for num in arr:
        count[num] += 1

    # Rebuild the sorted array
    sorted_arr = []
    for value, freq in enumerate(count):
        sorted_arr.extend([value] * freq)

    return sorted_arr


# Example usage
data = [4, 2, 2, 8, 3, 3, 1]

print("Before sorting:", data)

sorted_data = counting_sort(data)

print("After sorting: ", sorted_data)