# Calculadora de Emissões de GEE do DF — Replicação em R

Replicação, como pacote R, da [Calculadora de Emissões de GEE do DF](https://www.ide.df.gov.br/calculadora_emissoes/), com parâmetros e equações extraídos do [Apendice de Notas Metodologicas do IPEDF](https://www.ipe.df.gov.br/avaliacao-de-emissoes-de-gases-de-efeito-estufa/) (`notas_metodologicas.pdf`).

O código do servidor Shiny oficial não é público — as equações foram derivadas das notas metodológicas e estão documentadas em cada função (ver `@details`), com nota "a confirmar via LAI" onde há interpretação.

## Pacote `calculadoraemissoes/`

Pacote R base (sem dependências), com 23 datasets (lazy-load) e 14 funções:

- **Transporte**: `calc_ciclovia()`, `calc_faixa_exclusiva()`, `calc_brt()`, `calc_obras_viarias()`, `calc_metro()`
- **Uso do solo**: `calc_parcelamento_solo()`, `calc_combate_grilagem()`, `calc_recuperacao_degradadas()`, `calc_manejo_baixo_carbono()`
- **Energia e resíduos**: `calc_eficiencia_energetica()`, `calc_compostagem()`, `calc_reciclagem()`
- **Utils**: `padronizar_ra()` (aceita nome/ID de RA com ou sem acento), `numero_br()` (converte "1.234,56" → 1234.56)

```r
install.packages("calculadoraemissoes", repos = NULL, type = "source")  # após R CMD build
# ou: devtools::load_all("calculadoraemissoes")

calculadoraemissoes::calc_ciclovia("Ceilândia", qtde_domicilios = 1000)
#> ~602 t CO2e/ano evitadas (594,3 t no PDF; diferença por arredondamento
#> de moradores por domicílio — ver AGENTS.md, gotchas)
```

Comandos de desenvolvimento (dados, docs, testes, check) estão em [`AGENTS.md`](AGENTS.md).

### Atualização dos dados

Todos os dados ficam em `calculadoraemissoes/data-raw/gerar_dados.R` como tabelas editáveis; re-executar o script regenera os `.rda`. Os dados-base são de 2021 (PDAD/CODEPLAN, ANP, DETRAN, SIN) e 2017 (pesquisa de mobilidade PMU/Metrô — única disponível).

## Roadmap de pedidos via LAI

Objetivo: confirmar as equações do servidor oficial e viabilizar atualização anual dos parâmetros.

| # | Órgão | Objeto | Uso no pacote | Prioridade |
|---|---|---|---|---|
| 1 | IDE/IPE-DF | Código-fonte do servidor Shiny da calculadora (`ide.df.gov.br/calculadora_emissoes/`) | Confirmar equações marcadas "a confirmar" | Alta |
| 2 | DETRAN-DF | Frota veicular por RA e tipo/combustível (série anual) | `frota_veicular_df`, FEs ponderados | Alta |
| 3 | SLU-DF | Pesagem caracterização de resíduos por RA (série anual) | `residuos_ra`, `composicao_gravimetrica` | Alta |
| 4 | NEOENERGIA/CEB | Consumo de energia elétrica por município/RA | `consumo_energia_ra` | Média |
| 5 | SEMOB/DFTRAN | Levantamento de extensão de ciclovias, faixas exclusivas e BRT | Parâmetros de `calc_*` transporte | Média |
| 6 | CODEPLAN | Microdados PDAD (domicílios, moradores, renda por RA) | `ra_parametros`, `distancias_deslocamento` | Média |
| 7 | Metrô-DF | Nova pesquisa de mobilidade (PMU) — última é 2017 | `viagens_pmu_2017`, `parametros_viagens` | Baixa |
| 8 | ANP | Venda de combustíveis no DF (série) | `venda_combustivel_df_2021`, `consumo_diesel_df_2021` | Baixa (dado público, atualizar anualmente) |

### Minutas de requerimento

**1. IDE/IPE-DF — código da calculadora**

> Solicito, com fundamento na Lei nº 12.527/2011 (LAI), acesso ao código-fonte do sistema "Calculadora de Emissões de Gases de Efeito Estufa" disponível em https://www.ide.df.gov.br/calculadora_emissoes/, incluindo: (a) equações e fatores de emissão implementados; (b) parâmetros e anos de referência de cada variável; (c) memória de cálculo das estimativas publicadas. Caso o sistema tenha sido desenvolvido por terceiros sob contrato, solicito também cópia dos trechos contratuais que tratarem da titularidade e do acesso ao código.

**2. DETRAN-DF — frota por RA**

> Solicito, nos termos da Lei nº 12.527/2011, a frota de veículos registrada no DF, detalhada por Região Administrativa, tipo de veículo (motocicleta, automóvel, caminhão, ônibus) e combustível, para os anos de 2015 a 2025 (ou o período disponível), em formato aberto e legível por máquina (CSV). Caso a quebra por RA não exista, solicito a quebra disponível mais fina (município/UF).

**3. SLU-DF — resíduos por RA**

> Solicito, nos termos da Lei nº 12.527/2011: (a) a pesagem mensal dos resíduos sólidos urbanos coletados por Região Administrativa, série 2015–2025; (b) a última caracterização gravimétrica dos resíduos do DF (frações: orgânicos, papel/papelão, plástico, vidro, metal, alumínio); (c) a quantidade destinada a compostagem, reciclagem e aterro, por ano.

**4. NEOENERGIA/CEB — consumo elétrico**

> Solicito, nos termos da Lei nº 12.527/2011, o consumo de energia elétrica (MWh) por classe e por município/Região Administrativa do DF, série 2015–2025, em formato aberto. Sendo o dado comercialmente sensível, solicito, ao menos, os agregados anuais por RA.

**5. SEMOB/DFTRAN — infraestrutura de mobilidade**

> Solicito, nos termos da Lei nº 12.527/2011, a extensão em km, por Região Administrativa, de: (a) ciclovias, ciclofaixas e ciclorrotas; (b) faixas exclusivas de ônibus; (c) corredores BRT; além do volume diário de viagens por modo (PDU/POLO/PMU mais recente).

**6. CODEPLAN — microdados PDAD**

> Solicito, nos termos da Lei nº 12.527/2011, os microdados da Pesquisa Distrital por Amostra de Domicílios (PDAD), com dicionário de variáveis, para todas as edições disponíveis, incluindo número de moradores por domicílio e consumo mensal de energia elétrica por RA.

**7. Metrô-DF — pesquisa de mobilidade**

> Solicito, nos termos da Lei nº 12.527/2011, os microdados e tabelas da pesquisa de mobilidade (PMU) mais recente do DF, incluindo matriz origem-destino, repartição modal e motivo da viagem. Caso não exista pesquisa posterior a 2017, solicito informação de data prevista da próxima edição.

**8. ANP — combustíveis (dado público)**

Atualização anual direta dos dados públicos de venda de derivados por UF (Sistema de Informações de Hidrocarbonetos / levantamento de preços e comercialização), sem necessidade de LAI.

## Estrutura do repositório

```
calculadoraemissoes/          # pacote R (R/, data/, data-raw/, tests/, man/)
notas_metodologicas.pdf|.txt  # fonte dos parâmetros (txt: ~4400 linhas; índice em AGENTS.md)
AGENTS.md                     # guia de manutenção, comandos e gotchas
```
