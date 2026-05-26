# Counting Sort - Comparacao entre Python e Rust

Projeto de Teoria da Computacao para analisar o algoritmo Counting Sort em duas linguagens: Python e Rust.

## Estrutura

```text
Equipe7_TCB/
├─ python/
│  ├─ benchmark/
│  │  ├─ counting_sort.py
│  │  └─ variacao_k.py
│  ├─ visualizacao/
│  │  └─ counting_sort_visual.py
│  └─ ambiente_execucao.py
├─ rust/
│  ├─ Cargo.toml
│  └─ src/
│     ├─ main.rs
│     └─ bin/
│        ├─ variacao_k.rs
│        └─ visualizacao.rs
├─ analise/
│  ├─ dados/
│  ├─ tabelas/
│  ├─ graficos/
│  ├─ notebooks/
│  └─ ambiente/
├─ README.md
└─ .gitignore
```

## Principais arquivos

- `python/benchmark/counting_sort.py`: benchmark principal em Python.
- `python/benchmark/variacao_k.py`: experimento complementar em Python variando `k`.
- `python/visualizacao/counting_sort_visual.py`: execucao didatica em Python.
- `python/ambiente_execucao.py`: gera resumo do ambiente de execucao.
- `rust/src/main.rs`: benchmark principal em Rust.
- `rust/src/bin/variacao_k.rs`: experimento complementar em Rust variando `k`.
- `rust/src/bin/visualizacao.rs`: execucao didatica em Rust.
- `analise/notebooks/padronizacao_graficos.ipynb`: notebook de tabelas e graficos.

## Metodologia

Os benchmarks principais executam o Counting Sort em tres tamanhos de entrada:

- pequena: `1.000` elementos;
- media: `10.000` elementos;
- grande: `1.000.000` elementos.

Para cada tamanho, sao testados tres casos:

- melhor caso: vetor ja ordenado;
- caso medio: vetor pseudoaleatorio;
- pior caso: vetor em ordem inversa.

Cada combinacao de linguagem, tamanho e caso e executada `30` vezes. Os CSVs registram a linguagem, o caso, o tamanho `n`, o valor de `k`, a rodada, o tempo em segundos e se a saida ficou ordenada.

No Counting Sort, a complexidade teorica e `O(n + k)`, onde `n` e o tamanho da entrada e `k` e o intervalo de valores. Nos testes principais, `k = n`.

## Como executar

Gere o CSV principal do Python:

```powershell
python .\python\benchmark\counting_sort.py
```

Gere o CSV principal do Rust em modo otimizado:

```powershell
cargo run --release --manifest-path .\rust\Cargo.toml
```

Gere os CSVs complementares da variacao de `k`:

```powershell
python .\python\benchmark\variacao_k.py
cargo run --release --manifest-path .\rust\Cargo.toml --bin variacao_k
```

Execute as versoes didaticas para visualizar o funcionamento do algoritmo:

```powershell
python .\python\visualizacao\counting_sort_visual.py
cargo run --manifest-path .\rust\Cargo.toml --bin visualizacao
```

Essas versoes usam um pequeno atraso automatico entre as etapas. Para controlar a velocidade:

```powershell
python .\python\visualizacao\counting_sort_visual.py --fast
python .\python\visualizacao\counting_sort_visual.py --slow
python .\python\visualizacao\counting_sort_visual.py --no-delay

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
jupyter notebook .\analise\notebooks\padronizacao_graficos.ipynb
```

## Saidas principais

Os benchmarks geram dados brutos em `analise/dados/`:

- `resultados_python.csv`
- `resultados_rust.csv`
- `resultados_python_variacao_k.csv`
- `resultados_rust_variacao_k.csv`

O notebook gera tabelas em `analise/tabelas/`:

- `resumo_tempos.csv`
- `resumo_tempos_com_teoria.csv`
- `resumo_variacao_k.csv`
- `speedup_rust_vs_python.csv`

O notebook gera graficos em `analise/graficos/`:

- `01_tempos_reais_log.png`
- `02_real_vs_teorico_log.png`
- `03_comparacao_linguagens_barras_log.png`
- `04_velocidade_linguagens_log.png`
- `05_speedup_rust_vs_python.png`
- `06_variacao_k_tempos_log.png`
- `07_variacao_k_real_vs_teorico_log.png`

O ambiente de execucao fica em:

- `analise/ambiente/ambiente_execucao.txt`

## Observacoes para o relatorio

Embora os casos ordenado, aleatorio e inversamente ordenado sejam usados conforme o protocolo experimental, a ordem inicial do vetor influencia pouco o Counting Sort. O fator mais relevante e o intervalo `k`, pois o algoritmo precisa alocar e percorrer o vetor de contagem.

Por isso, uma conclusao importante e que Counting Sort e eficiente quando `k` nao e muito maior que `n`, mas pode se tornar inadequado quando o intervalo de valores e muito grande.

O experimento complementar de variacao de `k` mantem `n = 100.000` e mede tres cenarios: `k = 100`, `k = 100.000` e `k = 1.000.000`. Esses dados nao substituem os cenarios exigidos pelo professor; eles servem para evidenciar a parcela `k` da complexidade `O(n + k)`.
