# Counting Sort - Comparacao entre Python e Rust

Projeto de Teoria da Computacao para analisar o algoritmo Counting Sort em duas linguagens: Python e Rust.

## Estrutura

```text
Equipe7_TCB/
|- python/
|  |- benchmark/
|  |  |- entradas_benchmark.py
|  |  `- counting_sort.py
|  |- visualizacao/
|  |  `- counting_sort_visual.py
|  `- ambiente_execucao.py
|- rust/
|  |- Cargo.toml
|  `- src/
|     |- main.rs
|     `- bin/
|        `- visualizacao.rs
|- analise/
|  |- dados/
|  |- tabelas/
|  |- graficos/
|  |- notebooks/
|  `- ambiente/
|- scripts/
|  |- windows/
|  `- linux/
|- requirements.txt
|- README.md
`- .gitignore
```

## Principais arquivos

- `python/benchmark/entradas_benchmark.py`: gera o plano compartilhado de entradas usado pelas duas linguagens.
- `python/benchmark/counting_sort.py`: benchmark principal em Python.
- `rust/src/main.rs`: benchmark principal em Rust.
- `python/visualizacao/counting_sort_visual.py`: execucao didatica em Python.
- `rust/src/bin/visualizacao.rs`: execucao didatica em Rust.
- `python/ambiente_execucao.py`: gera resumo do ambiente de execucao.
- `analise/notebooks/padronizacao_graficos.ipynb`: notebook de tabelas e graficos.

## Metodologia

O Counting Sort tem complexidade teorica `O(n + k)`, onde:

- `n` e a quantidade de elementos do vetor;
- `k` e o intervalo de valores possiveis.

Como a ordem inicial do vetor nao altera significativamente o comportamento do Counting Sort, os cenarios do benchmark principal foram definidos variando `k` e mantendo `n` fixo:

| Cenario | n | k |
| --- | ---: | ---: |
| melhor | 1.000.000 | 100 |
| medio | 1.000.000 | 1.000.000 |
| pior | 1.000.000 | 100.000.000 |

Cada cenario e executado 30 vezes por linguagem.

Para garantir comparacao justa, o arquivo `analise/dados/entradas_benchmark.csv` registra o plano compartilhado de entradas com `caso`, `n`, `k`, `execucao` e `seed`. Python e Rust leem esse mesmo plano e reconstroem os mesmos vetores a partir das mesmas sementes.

Os CSVs de resultado tambem registram `checksum_entrada`, uma assinatura calculada sobre o vetor antes da ordenacao. O notebook valida que os checksums de Python e Rust sao iguais em cada execucao, comprovando que as duas linguagens processaram a mesma entrada.

## Como executar

### Windows / PowerShell

Prepare o ambiente Python e verifique Rust/Cargo:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\setup_windows.ps1
```

Rode o fluxo completo:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_all.ps1
```

Antes de iniciar, o fluxo completo remove automaticamente as saidas anteriores. Durante os benchmarks, uma barra textual atualizada na mesma linha mostra o progresso das 180 medicoes (`90` em Python e `90` em Rust) e a porcentagem concluida. Ao final, o script informa o tempo de cada etapa e o tempo total no formato `HH:MM:SS`.

Ou rode por partes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_benchmarks.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\windows\run_notebook.ps1
```

Para limpar somente as saidas geradas:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\clean_outputs.ps1
```

### Ubuntu / Bash

Prepare automaticamente o ambiente. Em Ubuntu/Debian, o script instala os pacotes ausentes com `apt-get`, cria `.venv`, instala as bibliotecas Python e instala Rust/Cargo pelo `rustup` se necessario:

```bash
bash scripts/linux/setup_ubuntu.sh
```

Rode o fluxo completo:

```bash
bash scripts/linux/run_all.sh
```

Antes de iniciar, o fluxo completo remove automaticamente as saidas anteriores. Durante os benchmarks, uma barra textual atualizada na mesma linha mostra o progresso das 180 medicoes (`90` em Python e `90` em Rust) e a porcentagem concluida. Ao final, o script informa o tempo de cada etapa e o tempo total no formato `HH:MM:SS`.

Ou rode por partes:

```bash
bash scripts/linux/run_benchmarks.sh
bash scripts/linux/run_notebook.sh
```

Para limpar somente as saidas geradas:

```bash
bash scripts/linux/clean_outputs.sh
```

## Saidas principais

Os benchmarks geram dados brutos em `analise/dados/`:

- `entradas_benchmark.csv`
- `resultados_python.csv`
- `resultados_rust.csv`

O notebook gera tabelas em `analise/tabelas/`:

- `plano_entradas_benchmark.csv`
- `verificacao_checksums.csv`
- `comparacao_checksums_entradas.csv`
- `resumo_tempos.csv`
- `resumo_tempos_com_teoria.csv`
- `resumo_cenarios.csv`
- `speedup_rust_vs_python.csv`
- `speedup_rust_vs_python_por_execucao.csv`
- `velocidade_linguagens.csv`

O notebook gera graficos em `analise/graficos/`:

- `00_verificacao_checksums.png`
- `01_tempo_por_k_com_desvio_log.png`
- `02_real_vs_teorico_por_k_log.png`
- `03_real_vs_teorico_tres_cenarios.png`
- `04_cenarios_com_desvio.png`
- `05_speedup_rust_vs_python_cenarios.png`
- `06_velocidade_linguagens_cenarios.png`

O ambiente de execucao fica em:

- `analise/ambiente/ambiente_execucao.txt`

## Observacoes para o relatorio

O ponto principal da analise e que Counting Sort nao apresenta melhor, medio e pior caso relevantes pela ordenacao inicial do vetor. O crescimento e explicado por `n + k`.

Como `n` permanece fixo em `1.000.000`, a diferenca entre os cenarios vem do aumento de `k`. O pior cenario exige um vetor de contagem muito grande, o que aumenta tempo de execucao e uso de memoria.

Os graficos exibem a media das 30 execucoes com desvio padrao. A curva teorica `c*(n+k)` e ajustada aos dados reais para mostrar a aderencia entre experimento e teoria.

O fluxo oficial do projeto usa `counting_sort.py`, `main.rs` e o plano compartilhado `entradas_benchmark.csv`.
