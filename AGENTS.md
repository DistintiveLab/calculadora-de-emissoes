# AGENTS.md

Guia de manutenção deste repositório (replicação em R da Calculadora de Emissões de GEE do DF).

## Visão geral

- `calculadoraemissoes/`: pacote R com 23 datasets (lazy-load `.rda`), 12 funções `calc_*()` e 2 utils.
- `notas_metodologicas.pdf` / `.txt`: fonte de TODOS os parâmetros e equações (Notas Metodológicas IPEDF, Apendices I–VIII).
- O código do servidor Shiny oficial (`ide.df.gov.br/calculadora_emissoes/`) não é público: equações foram derivadas do PDF e estão marcadas "a confirmar via LAI" nos `@details`.
- **NÃO parsear/commitar** `relatorios_finais_PDTT_PMU.rar` (291 MB).

## Comandos (executar do raiz do repo)

```bash
# Regenerar os 23 .rda (após editar dados em data-raw/)
cd calculadoraemissoes && Rscript data-raw/gerar_dados.R

# Regenerar docs (man/, NAMESPACE) após editar roxygen
Rscript -e 'roxygen2::roxygenise("calculadoraemissoes")'

# Testes (104 testes; esperar FAIL 0)
Rscript -e 'devtools::test("calculadoraemissoes")'

# Check final (Status: OK esperado — 0 ERROR/WARNING/NOTE)
rm -f calculadoraemissoes_0.1.0.tar.gz && R CMD build calculadoraemissoes && \
  R CMD check --no-manual calculadoraemissoes_0.1.0.tar.gz
```

Observações:
- `devtools::check()` via Rscript falha (callr/pkgbuild) — usar `R CMD build` + `R CMD check` direto.
- `.rda` são gravados com `version = 3` (exige `Depends: R (>= 3.5.0)`; version = 2 gera WARNING).
- `DESCRIPTION` tem email placeholder (`rodrigo@example.com`) em Authors@R — **substituir antes de publicar**.

## Convenções de código (críticas para passar no check)

1. **Literais em código executável 100% ASCII** — non-ASCII gera WARNING mesmo com `Encoding: UTF-8`. Acentos só em comentários/roxygen.
2. Entrada do usuário é normalizada com `padrao_busca()` (interno, minúsculas sem acento) e comparada dos dois lados — o pacote aceita "Ceilândia", "ceilandia", "CEILÂNDIA" etc.
3. Chaves internas de datasets: ASCII onde são comparadas em código (ex.: `fe_onibus` usa "Padron (basico)"/"Diesel B12").
4. `padronizar_ra(ra_id)` com nomes: índice > 33 significa que casou o `ra_nome` — subtrair 33 (66 chaves vs 33 linhas).
5. `map_classe_vegetacao()`: ordem de checagem importa — "sem cobertura" → "urbana" → "campestre" → "savânica" → "florestal" ("Campestre (gramíneas nativas)" contém "nativas").
6. `matriz_manejo_solo` (63 linhas): transição ILP→ILP usa chave lado-específica (ver `calc_manejo_baixo_carbono`).
7. Sinais: `emissoes_evitadas_*` positivo = evitou; `calc_recuperacao_degradadas` positivo = remoção (ganho de carbono).

## Proveniência e anos dos dados (fonte: notas_metodologicas.txt)

| Dataset | Fonte / Apendice | Ano |
|---|---|---|
| `ra_parametros`, `distancias_deslocamento` | Tab. 2–3 (PDAD/CODEPLAN) | 2021 |
| `parametros_viagens`, `viagens_pmu_2017` | Pesquisa PMU — **só existe p/ 2017** | 2017 |
| `venda_combustivel_df_2021`, `consumo_diesel_df_2021` | ANP | 2021 |
| `fe_veiculos_leves`, `frota_veicular_df` | Apendice II (frota DETRAN/FEs) | 2021 |
| `parametros_stc`, `fe_onibus` | Apendice III (STC; bus FE) | 2021 |
| `parametros_vkv` | Apendice II (Quadro 5) | — |
| `estoque_carbono_vegetacao`, `incremento_remocao`, `constantes_uso_solo`, `vegetacao_ra` | Apendice V (stocks; per-RA ~2937–2986) | 2018/2021 |
| `matriz_manejo_solo` | Apendice IV (matriz 13×16 sistemas) | — |
| `fe_energia_sin` | Apendice VI (matriz elétrica SIN) | 2014–2023 |
| `consumo_energia_ra` | Apendice VII | 2021 |
| `fe_residuos`, `composicao_gravimetrica`, `residuos_ra` | Apendice VIII | 2021 |

Ponteiros no `.txt` (linhas aprox.): Tab. 2 ~433–465; Tab. 3 ~488–514; Tab. 7 ~727–792; Apend. II ~1026–1130 e Quadro 5 ~1410–1436; Apend. III ~1696–1714 e bus FE ~1884–1915; Apend. V ~2695–2711 e per-RA ~2937–2986; Apend. VI ~3299–3518; Apend. VII ~3802–3926; Apend. VIII ~4138–4321.

## Fluxo de atualização de dados (via LAI)

1. Editar `calculadoraemissoes/data-raw/gerar_dados.R` (todas as tabelas estão lá como data.frames literais).
2. Re-executar o script (regenera `data/*.rda`).
3. Ajustar testes de spot-check em `tests/testthat/test-dados.R` se valores de referência mudarem.
4. Rodar testes + check (comandos acima).

Requisito do README original: dados **não** podem ficar fixos em 2021 — o script é a via de atualização.

## Gotchas de dados (documentados em `R/data.R`)

- Fercal: `NA` nas Tabelas 2/3. SCIA/SIA: população idêntica (artefato). Lago Sul energia = Gama (artefato).
- Ceilândia: 2.96 moradores/dom (Tab. 6) vs 3.0 publicado (~1,3%).
- `residuos_ra` tem só 30 RAs (faltam Águas Claras, Riacho Fundo II, Lago Norte → resultado `NA` com warning em compostagem/parcelamento).
- `vegetacao_ra$estoque_carbono_tc` = Σ AGB×ha (verificado); `remocoes_tco2e_ano` NÃO reproduzível das equações do texto — mantido como publicado.
- Números do PDF usam vírgula decimal: usar `numero_br()` (exportada) ao digitar novos dados do texto.
