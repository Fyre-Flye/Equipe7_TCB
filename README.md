# Counting Sort - Comparacao entre Python e Rust

Projeto de Teoria da Computacao para analisar o algoritmo Counting Sort em duas linguagens: Python e Rust.

## Estrutura

- `python/counting_sort.py`: benchmark do Counting Sort em Python.
- `python/counting_sort_visual.py`: execucao didatica do Counting Sort em Python.
- `python/variacao_k.py`: experimento complementar variando o intervalo `k`.
- `python/ambiente_execucao.py`: gera um resumo do ambiente de execucao.
- `rust/src/main.rs`: benchmark do Counting Sort em Rust.
- `rust/src/bin/visualizacao.rs`: execucao didatica do Counting Sort em Rust.
- `rust/src/bin/variacao_k.rs`: experimento complementar em Rust variando `k`.
- `analise/resultados_python.csv`: medicoes geradas pelo Python.
- `analise/resultados_rust.csv`: medicoes geradas pelo Rust.
- `analise/padronizacao_graficos.ipynb`: notebook para tabelas, graficos e curva teorica.
- `analise/graficos/`: imagens geradas pelo notebook.

## Metodologia

Os benchmarks executam o Counting Sort em tres tamanhos de entrada:

- pequena: `1.000` elementos;
- media: `10.000` elementos;
- grande: `1.000.000` elementos.

Para cada tamanho, sao testados tres casos:

- melhor caso: vetor ja ordenado;
- caso medio: vetor pseudoaleatorio;
- pior caso: vetor em ordem inversa.

Cada combinacao de linguagem, tamanho e caso e executada `30` vezes. Os CSVs registram a linguagem, o caso, o tamanho `n`, o valor de `k`, a rodada, o tempo em segundos e se a saida ficou ordenada.

No Counting Sort, a complexidade teorica e `O(n + k)`, onde `n` e o tamanho da entrada e `k` e o intervalo de valores. Nos testes atuais, `k = n`.

## Como executar

Gere o CSV do Python:

```powershell
python .\python\counting_sort.py
```

Gere o CSV do Rust em modo otimizado:

```powershell
cargo run --release --manifest-path .\rust\Cargo.toml
```

Gere os CSVs complementares da variacao de `k`:

```powershell
python .\python\variacao_k.py
cargo run --release --manifest-path .\rust\Cargo.toml --bin variacao_k
```

Execute as versoes didaticas para visualizar o funcionamento do algoritmo:

```powershell
python .\python\counting_sort_visual.py
cargo run --manifest-path .\rust\Cargo.toml --bin visualizacao
```

Essas versoes usam um pequeno atraso automatico entre as etapas. Para controlar a velocidade:

```powershell
python .\python\counting_sort_visual.py --fast
python .\python\counting_sort_visual.py --slow
python .\python\counting_sort_visual.py --no-delay

cargo run --manifest-path .\rust\Cargo.toml --bin visualizacao -- --fast
cargo run --manifest-path .\rust\Cargo.toml --bin visualizacao -- --slow
cargo run --manifest-path .\rust\Cargo.toml --bin visualizacao -- --no-delay
```

Gere o arquivo do ambiente de execucao:

```powershell
python .\python\ambiente_execucao.py
```

Abra o notebook de analise:

```powershell
jupyter notebook .\analise\padronizacao_graficos.ipynb
```

## Saidas principais

Os benchmarks geram:

- `analise/resultados_python.csv`
- `analise/resultados_rust.csv`
- `analise/resultados_python_variacao_k.csv`
- `analise/resultados_rust_variacao_k.csv`

O notebook gera:

- `analise/resumo_tempos.csv`
- `analise/resumo_tempos_com_teoria.csv`
- `analise/resumo_variacao_k.csv`
- `analise/speedup_rust_vs_python.csv`
- `analise/graficos/01_tempos_reais_log.png`
- `analise/graficos/02_real_vs_teorico_log.png`
- `analise/graficos/03_comparacao_linguagens_barras_log.png`
- `analise/graficos/04_speedup_rust_vs_python.png`

## Observacoes para o relatorio

Embora os casos ordenado, aleatorio e inversamente ordenado sejam usados conforme o protocolo experimental, a ordem inicial do vetor influencia pouco o Counting Sort. O fator mais relevante e o intervalo `k`, pois o algoritmo precisa alocar e percorrer o vetor de contagem.

Por isso, uma conclusao importante e que Counting Sort e eficiente quando `k` nao e muito maior que `n`, mas pode se tornar inadequado quando o intervalo de valores e muito grande.

O experimento complementar de variacao de `k` mantem `n = 100.000` e mede tres cenarios: `k = 100`, `k = 100.000` e `k = 1.000.000`. Esses dados nao substituem os cenarios exigidos pelo professor; eles servem para evidenciar a parcela `k` da complexidade `O(n + k)`.
