import sys
from time import sleep


def wait(delay):
    if delay > 0:
        sleep(delay)


def counting_sort_visual(values, delay=0.8):
    print("Counting Sort - visualizacao em Python")
    print(f"Vetor original: {values}")
    wait(delay)

    if not values:
        print("Vetor vazio. Nada a ordenar.")
        return []

    max_value = max(values)
    count = [0] * (max_value + 1)
    print(f"\nMaior valor encontrado: {max_value}")
    print(f"Vetor de contagem inicial: {count}")
    wait(delay)

    print("\n1) Contando ocorrencias")
    for value in values:
        count[value] += 1
        print(f"Valor {value}: count[{value}] = {count[value]} -> {count}")
        wait(delay)

    print("\n2) Reconstruindo o vetor ordenado")
    wait(delay)
    sorted_values = []
    for value, frequency in enumerate(count):
        if frequency > 0:
            print(f"Valor {value} aparece {frequency} vez(es).")
            wait(delay)
        for _ in range(frequency):
            sorted_values.append(value)
            print(f"Adiciona {value}: {sorted_values}")
            wait(delay)

    print(f"\nVetor ordenado: {sorted_values}")
    return sorted_values


if __name__ == "__main__":
    delay_seconds = 0.8
    if "--no-delay" in sys.argv:
        delay_seconds = 0
    elif "--fast" in sys.argv:
        delay_seconds = 0.25
    elif "--slow" in sys.argv:
        delay_seconds = 1.5

    example = [4, 2, 2, 8, 3, 3, 1]
    counting_sort_visual(example, delay=delay_seconds)
