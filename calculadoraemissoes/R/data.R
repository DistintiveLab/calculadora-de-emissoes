#' Parâmetros por Região Administrativa (RA) do DF
#'
#' Combiná as Tabelas 2 (ocupação por automóvel), 3 (moradores por domicílio) e
#' 7 (resultados por RA) do Apendice I das notas metodológicas do IPEDF
#' (PDAD 2021; frota DETRAN/DF 2023).
#'
#' @format data.frame com 33 linhas (uma por RA) e colunas:
#' \describe{
#' \item{ra_id}{identificador romano da RA (ex.: "RA IX").}
#' \item{ra}{nome canônico da RA.}
#' \item{populacao_pdad_2021, domicilios_pdad_2021}{população e domicílios (PDAD 2021).}
#' \item{renda_media_domiciliar}{renda média domiciliar em R$ (PDAD 2021).}
#' \item{pessoas_por_automovel}{ocupação média por automóvel (Tabela 2).}
#' \item{moradores_por_domicilio}{moradores por domicílio (Tabela 3).}
#' \item{lotes_ate_250_m2, lotes_250_500_m2, lotes_500_1000_m2}{quantidade de lotes por faixa de tamanho.}
#' \item{emissoes_veiculares_tco2_ano}{emissões veiculares estimadas (tCO2/ano, Tabela 7).}
#' \item{emissoes_kgco2_hab_ano}{emissões veiculares per capita (kgCO2/hab/ano, Tabela 7).}
#' }
#' @section Observações de extração:
#' Fercal (RA XXXI) não consta das Tabelas 2/3 (`NA`). SCIA e SIA aparecem com
#' população idêntica (37.527) no PDF, provável artefato de impressão - mantido
#' conforme publicado. O exemplo da Tabela 6 (1.000 domicílios na Ceilândia =
#' 594,3 tCO2/ano) implica 2,96 moradores/domicílio (valor não arredondado da
#' PDAD), enquanto a Tabela 3 publica 3,0 (diferença de ~1,3%).
#' @source IPEDF (2024), Apendice de Notas Metodologicas, Apendice I,
#'   Tabelas 2, 3 e 7.
"ra_parametros"

#' Distâncias médias de deslocamento (exemplo Ceilândia)
#'
#' Distância média por viagem (km) usada no exemplo da Tabela 6 do Apendice I
#' (domicílios da Ceilândia).
#'
#' @format data.frame com 4 linhas e colunas `ra`, `destino`, `distancia_km`.
#' @source IPEDF (2024), Apendice I, Quadro 3.
"distancias_deslocamento"

#' Viagens anuais por motivo
#'
#' Dias e viagens por ano por motivo (trabalho: 250 dias x 2 viagens; estudo:
#' 200 dias x 2 viagens), usadas na expansão de viagens diárias para anuais.
#'
#' @format data.frame com 2 linhas e colunas `motivo`, `dias_ano`, `viagens_ano`.
#' @source IPEDF (2024), Apendice I, seção 6.
"parametros_viagens"

#' Viagens por modo e motivo (PMU 2017)
#'
#' Totais diários de viagens da Pesquisa Domiciliar Urbana do DF (PMU 2017).
#' Único inquérito domiciliar disponível; 82,3% das viagens de ônibus e 67,7%
#' das de carro são por motivo trabalho/estudo (fatores de correção PMU/PDAD).
#'
#' @format data.frame com 2 linhas e colunas `modo`, `trabalho`, `estudo`,
#'   `outros`, `total`.
#' @source IPEDF (2024), Apendice I, Tabela 1 (PMU/SEMOB 2017).
"viagens_pmu_2017"

#' Venda de combustíveis no DF (ANP 2021) e emissões top-down
#'
#' Litros vendidos no DF em 2021 e emissões top-down resultantes
#' (tCO2e/ano, método top-down do Apendice I).
#'
#' @format data.frame com 3 linhas e colunas `combustivel`, `litros`,
#'   `emissoes_topdown_tco2e`.
#' @source IPEDF (2024), Apendice I, Tabelas 4/5 (ANP 2021).
"venda_combustivel_df_2021"

#' Fatores de emissão da frota de veículos leves
#'
#' Quadro 5 do Apendice II: rendimento e fator de emissão por tipo de
#' combustível, além das médias da frota (carro 133,4 gCO2e/km; moto 41,7
#' gCO2e/km). Renováveis (etanol) contabilizam apenas CH4+N2O (CO2 biogênico).
#'
#' @format data.frame com 10 linhas e colunas `classe`, `combustivel`,
#'   `distribuicao` (participação na frota), `km_por_l`, `fe_gco2e_por_l`,
#'   `fe_gco2e_por_km`. As linhas "Média frota" têm `distribuicao` `NA`.
#' @source IPEDF (2024), Apendice II, Quadro 5 (DETRAN 2023, ANP 2021,
#'   GHG Protocol Brasil).
"fe_veiculos_leves"

#' Frota veicular do DF
#'
#' Frota por classe em 23/08/2023 (DETRAN/DF).
#'
#' @format data.frame com 9 linhas e colunas `classe`, `quantidade`, `percentual`.
#' @source IPEDF (2024), Apendice II, Tabela 1.
"frota_veicular_df"

#' Consumo de diesel no DF em 2021 por classe
#'
#' Tabela 7 do Apendice II: partição do diesel vendido (ANP 2021) por classe.
#' O ônibus do STC responde por 35% do diesel.
#'
#' @format data.frame com 4 linhas e colunas `classe`, `quantidade_veiculos`,
#'   `rendimento_km_l`, `diesel_litros`.
#' @source IPEDF (2024), Apendice II, Tabela 7.
"consumo_diesel_df_2021"

#' Parâmetros do Sistema de Transporte Coletivo (STC)
#'
#' Tabela 1 do Apendice III: viagens, km, rendimento (2,1 km/L), diesel e
#' emissões anuais do STC do DF.
#'
#' @format data.frame com 1 linha e colunas `viagens_ano`, `km_ano`,
#'   `rendimento_km_l`, `diesel_litros_ano`, `emissoes_tco2e_ano`.
#' @source IPEDF (2024), Apendice III, Tabela 1 (SEMOB; ANP 2021).
"parametros_stc"

#' Rendimento e fator de emissão de ônibus por tipo e operação
#'
#' Quadro 1 do Apendice III: rendimento (km/L) e fator de emissão
#' (gCO2e/km) por tipo de veículo (Padron/Articulado), operação (trânsito
#' comum, faixa exclusiva, BRT) e combustível (diesel B12, biodiesel B100).
#' B100 consome 13% a mais que B12. Checagem interna: 2328,1/1,82 = 1279,2
#' ~ 1280,5 (arredondamento do rendimento).
#'
#' @format data.frame com 12 linhas e colunas `veiculo`, `operacao`,
#'   `combustivel`, `rendimento_km_l`, `fe_combustivel_gco2e_l`,
#'   `fe_veiculo_gco2e_km`.
#' @source IPEDF (2024), Apendice III, Quadro 1.
"fe_onibus"

#' Elasticidade VKT x expansão viária
#'
#' Elasticidade de ~0,993 entre veículo-km viajado e expansão de capacidade
#' (Chen et al., 2020). A calculadora usa o padrão editável VKV_induzido = 1.
#'
#' @format data.frame com 1 linha e colunas `parametro`, `valor`, `fonte`.
#' @source IPEDF (2024), Apendice IV.
"parametros_vkv"

#' Estoques de carbono por classe de vegetação
#'
#' Quadro 1 do Apendice V: estoques (tC/ha) de matéria lenhosa fina (FWD),
#' grossa (CWD) e biomassa aérea viva (AGB). Verificação: o estoque por RA da
#' Tabela 5 reproduz apenas a soma AGB x área (gramados/jardins excluídos).
#'
#' @format data.frame com 4 linhas e colunas `grupo`, `classe`, `fwd_tc_ha`,
#'   `cwd_tc_ha`, `agb_tc_ha`.
#' @source IPEDF (2024), Apendice V, Quadro 1.
"estoque_carbono_vegetacao"

#' Fatores de combustão por classe de vegetação
#'
#' Quadro 2 do Apendice V: frações combustíveis de FWD e CWD por classe.
#'
#' @format data.frame com 4 linhas e colunas `grupo`, `classe`, `fwd`, `cwd`.
#' @source IPEDF (2024), Apendice V, Quadro 2.
"fatores_combustao"

#' Fatores de emissão por queima de vegetação
#'
#' Tabela 1 do Apendice V: fatores de emissão (g/kg de matéria seca) por gás e
#' classe de vegetação.
#'
#' @format data.frame com 5 linhas (gases CO2, CO, CH4, N2O, NOx) e colunas
#'   `gas`, `campestre_savanica`, `florestal`, `florestal_urbana`.
#' @source IPEDF (2024), Apendice V, Tabela 1.
"fe_queimada"

#' Incremento anual de carbono por classe de vegetação
#'
#' Quadro 3 do Apendice V: incremento anual (MgC/ha/ano) segundo SEEG (flat
#' 0,20, rejeitado) e IPCC (adotado: Campestre 0,49; Savânica 0,49; Florestal
#' 1,17; Florestal Urbana 2,80).
#'
#' @format data.frame com 4 linhas e colunas `grupo`, `classe`, `seeg`, `ipcc`.
#' @source IPEDF (2024), Apendice V, Quadro 3.
"incremento_remocao"

#' Constantes do módulo de uso do solo
#'
#' Fração de carbono (0,49), razão CO2/C (44/12 = 3,6667) e GWP AR6
#' (CH4 = 27; N2O = 273).
#'
#' @format data.frame com 4 linhas e colunas `constante`, `valor`.
#' @source IPEDF (2024), Apendice V.
"constantes_uso_solo"

#' Cobertura vegetal, estoque e remoções por RA
#'
#' Tabela 5 do Apendice V: área por classe de vegetação (base 2021), estoque
#' de carbono (tC) e remoções anuais (tCO2e/ano) por RA, conforme publicado.
#' Nota: os totais publicados de remoção não foram reproduzíveis a partir das
#' equações do texto com os incrementos do Quadro 3 - valores mantidos como
#' publicados.
#'
#' @format data.frame com 33 linhas e colunas `ra_id`, `ra`,
#'   `floresta_urbana_ha`, `campo_ha`, `savana_ha`, `floresta_ha`,
#'   `gramados_jardins_ha`, `estoque_carbono_tc`, `remocoes_tco2e_ano`.
#' @source IPEDF (2024), Apendice V, Tabela 5.
"vegetacao_ra"

#' Matriz de emissões/remoções por transição de uso do solo
#'
#' Quadro 1 do Apendice VI: 63 transições com fator anual (tCO2e/ha/ano;
#' negativo = remoção) e referência bibliográfica. Os 13 valores únicos de
#' `uso_anterior` e 16 de `uso_atual` correspondem às opções dos menus da
#' calculadora.
#'
#' @format data.frame com 63 linhas e colunas `uso_anterior`, `uso_atual`,
#'   `tco2e_ha_ano`, `referencia`.
#' @source IPEDF (2024), Apendice VI, Quadro 1.
"matriz_manejo_solo"

#' Fatores de emissão médios do SIN
#'
#' Tabela 2 do Apendice VII: fator médio anual (tCO2/MWh) do Sistema
#' Interligado Nacional (MCTI, 2024). A calculadora usa 2021 = 0,1264.
#'
#' @format data.frame com 10 linhas (2014-2023) e colunas `ano`, `tco2_por_mwh`.
#' @source IPEDF (2024), Apendice VII, Tabela 2 (MCTI 2024).
"fe_energia_sin"

#' Consumo de energia elétrica por RA
#'
#' Tabela 1 do Apendice VII: consumo médio mensal por domicílio (kWh),
#' energia consumida em 1/2021-12/2021 (12º mês excluído por anomalia
#' tarifária; medianas usadas pela assimetria à direita), emissões e emissões
#' per capita (NEOENERGIA).
#'
#' @format data.frame com 33 linhas e colunas `ra`,
#'   `consumo_medio_mensal_kwh_domicilio`, `energia_2021_kwh`,
#'   `emissoes_tco2_2021`, `emissoes_kgco2_hab`.
#' @section Observações de extração:
#' Lago Sul apresenta energia 2021 idêntica à do Gama no PDF (provável artefato
#' de impressão); mantido conforme publicado.
#' @source IPEDF (2024), Apendice VII, Tabela 1 (NEOENERGIA).
"consumo_energia_ra"

#' Fatores de emissão de resíduos por material
#'
#' Tabela 1 do Apendice VIII: fatores líquidos específicos (kg CO2e/t;
#' GIEGRICH, 2021). Negativos indicam benefício líquido da reciclagem. O
#' aterro do DF tem fator 1,27 tCO2e/t (simulação ProteGEEr/GIZ).
#'
#' @format data.frame com 6 linhas e colunas `material`, `kgco2e_por_t`.
#' @source IPEDF (2024), Apendice VIII, Tabela 1.
"fe_residuos"

#' Composição gravimétrica dos resíduos do DF
#'
#' Tabela 2 do Apendice VIII: composição (% de resíduos úmidos, 2023, 3 lotes)
#' na coleta convencional e na coleta seletiva.
#'
#' @format data.frame com 13 linhas e colunas `componente`,
#'   `coleta_convencional_pct`, `coleta_seletiva_pct`.
#' @source IPEDF (2024), Apendice VIII, Tabela 2 (SLU 2023).
"composicao_gravimetrica"

#' Resíduos sólidos por RA
#'
#' Tabela 3 do Apendice VIII: geração e emissões de resíduos por RA (SLU 2021;
#' ferramenta GRS GEE). 30 das 33 RAs - Águas Claras, Riacho Fundo II e Lago
#' Norte não constam da tabela publicada.
#'
#' @format data.frame com 30 linhas e colunas `ra`, `residuo_domiciliar_t_ano`,
#'   `residuo_seletivo_t_ano`, `perc_reciclado`, `geracao_kg_hab_ano`,
#'   `emissoes_totais_tco2e_ano`, `emissoes_evitadas_tco2e_ano`,
#'   `emissoes_liquidas_tco2e_ano`, `emissoes_liquidas_kgco2_hab_ano`.
#' @source IPEDF (2024), Apendice VIII, Tabela 3 (SLU 2021).
"residuos_ra"
