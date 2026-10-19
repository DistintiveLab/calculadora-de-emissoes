# Geracao dos dados do pacote `calculadoraemissoes`
#
# Fonte unica: Apendice de Notas Metodologicas - "Avaliacao de emissões de GEE
# de ações governamentais do DF" (IPEDF, 2024), PDF disponivel em
# https://www.ipe.df.gov.br/documents/9915964/10231005/
# Todos os valores do PDF usam virgula decimal; aqui ja convertidos para ponto.
# Ao atualizar dados (novas PDAD/DETRAN/ANP/SLU via LAI), edite este script e
# re-execute com:  Rscript data-raw/gerar_dados.R

# == Apendice I ==============================================================

# Tabela 2 (ocupacao por automovel) + Tabela 3 (moradores por domicilio)
# + Tabela 7 (resultados por RA; fonte DETRAN/DF 2023, PDAD 2021)
ra_parametros <- data.frame(
  ra_id = c("RA I","RA II","RA III","RA IV","RA V","RA VI","RA VII","RA VIII",
            "RA IX","RA X","RA XI","RA XII","RA XIII","RA XIV","RA XV","RA XVI",
            "RA XVII","RA XVIII","RA XIX","RA XX","RA XXI","RA XXII","RA XXIII",
            "RA XXIV","RA XXV","RA XXVI","RA XXVII","RA XXVIII","RA XXIX",
            "RA XXX","RA XXXI","RA XXXII","RA XXXIII"),
  ra = c("Plano Piloto","Gama","Taguatinga","Brazlândia","Sobradinho",
         "Planaltina","Paranoá","Núcleo Bandeirante","Ceilândia","Guará",
         "Cruzeiro","Samambaia","Santa Maria","São Sebastião","Recanto das Emas",
         "Lago Sul","Riacho Fundo","Lago Norte","Candangolândia","Águas Claras",
         "Riacho Fundo II","Sudoeste e Octogonal","Varjão","Park Way","SCIA",
         "Sobradinho II","Jardim Botânico","Itapoã","SIA","Vicente Pires",
         "Fercal","Sol Nascente / Pôr do Sol","Arniqueira"),
  populacao_pdad_2021 = c(224848,137331,210498,55879,73438,186498,69858,24093,
                          350347,142083,30860,247629,130970,118972,133564,
                          30446,44464,37539,16339,120107,72988,55366,8953,
                          23081,37527,78837,53045,65373,37527,78561,9388,
                          90574,47045),
  domicilios_pdad_2021 = c(91294,46819,76553,15408,23131,49852,20969,8308,
                           110111,47060,11323,68788,38190,31776,36420,9018,
                           12667,13897,4703,52014,16722,23546,2497,6098,
                           10640,25951,21237,17168,905,25292,1848,29114,14493),
  renda_media_domiciliar = c(14087.00,5034.40,5816.30,3425.60,6010.80,3114.20,
                             2843.60,5486.00,4491.10,7979.00,9858.60,4128.20,
                             3813.90,2649.50,3226.30,31322.90,5101.60,15867.10,
                             5612.50,14056.70,3863.50,15390.60,2907.20,18138.20,
                             2014.00,3808.80,14908.40,2475.20,5998.40,7775.30,
                             2186.10,2188.30,7052.90),
  pessoas_por_automovel = c(1.36,1.33,1.30,1.31,1.33,1.40,1.39,1.22,1.34,1.38,
                            1.40,1.34,1.33,1.45,1.31,1.38,1.40,1.30,1.32,1.36,
                            1.40,1.35,1.30,1.27,1.34,1.25,1.43,1.20,1.40,1.50,
                            NA,1.33,1.44),
  moradores_por_domicilio = c(2.2,2.8,2.6,3.2,2.7,3.0,2.9,2.3,3.0,2.6,2.6,2.7,
                              2.9,3.1,3.1,3.2,3.0,2.7,2.7,2.6,2.8,2.1,3.0,2.6,
                              3.4,2.8,2.9,2.9,2.5,2.8,NA,2.9,2.8),
  lotes_ate_250_m2 = c(4089,7570,17328,8926,3599,15563,7348,3154,63623,17126,
                       1945,44486,18649,6877,26024,32,5106,61,3038,0,10673,0,
                       1209,3,7787,4643,160,13078,108,327,1422,3355,222),
  lotes_250_500_m2 = c(1187,11631,14678,526,4601,3598,149,375,1620,580,339,
                       1061,93,633,195,3,39,0,42,261,301,178,18,0,190,809,498,
                       1336,60,1700,568,777,271),
  lotes_500_1000_m2 = c(1765,110,988,100,3975,1037,5,81,252,155,27,1368,141,
                        116,59,8131,5,5119,14,148,91,107,2,0,23,760,4817,66,4,
                        2234,199,103,365),
  emissoes_veiculares_tco2_ano = c(102901,67071,97646,29871,62694,110154,19549,
                                   10147,70335,90935,9022,80214,115140,28510,
                                   36486,40298,20185,49213,12037,82364,52005,
                                   25995,3981,48616,5958,98448,104300,48922,
                                   27845,61711,5054,19713,46942),
  emissoes_kgco2_hab_ano = c(457.65,488.39,463.88,534.57,853.70,590.64,279.84,
                             421.16,200.76,640.01,292.35,323.93,879.13,239.64,
                             273.17,1323.59,453.96,1310.98,736.70,685.76,712.51,
                             469.51,444.66,2106.32,158.77,1248.75,1966.26,748.35,
                             742.00,785.52,538.35,217.65,997.81)
)
# Observacoes de extração:
# - Fercal (RA XXXI) nao consta das Tabelas 2/3 do Apendice I (NA).
# - Tabela 7: SCIA e SIA aparecem com populacao 37527 iguais no PDF (possivel
#   artefato de impressao); mantido conforme publicado.
# - O exemplo do PDF (Tabela 6: 1000 domicilios em Ceilandia = 594,3 tCO2/ano)
#   implica 2,96 moradores/domicilio (valor nao arredondado da PDAD), enquanto a
#   Tabela 3 publica 3,0; diferenca ~1,3%.

# Distancias medias de deslocamento (Quadro 3, exemplo Ceilandia; km por viagem)
distancias_deslocamento <- data.frame(
  ra = "Ceilândia",
  destino = c("Plano Piloto","Taguatinga/Ceilândia","Demais locais",
              "Na própria RA"),
  distancia_km = c(27.6, 4.7, 31.1, 3.1)
)

# Viagens anuais por motivo (Apendice I, secao 6)
parametros_viagens <- data.frame(
  motivo = c("Trabalho","Estudo"),
  dias_ano = c(250, 200),
  viagens_ano = c(500, 400)
)

# Tabela 1 (PMU 2017): totais de viagens por modo e motivo
viagens_pmu_2017 <- data.frame(
  modo = c("Público coletivo","Privado individual"),
  trabalho = c(640875, 1017054),
  estudo = c(352555, 600074),
  outros = c(213595, 768566),
  total = c(1206870, 2385178)
)
# Fatores de correcao PMU/PDAD (secao 7): parcela de viagens onibus (82,3%) e
# carro (67,7%) por motivo trabalho/estudo.

# Tabela 4/5: venda de combustivel ANP 2021 e emissoes top-down
venda_combustivel_df_2021 <- data.frame(
  combustivel = c("Etanol hidratado","Gasolina C","Diesel"),
  litros = c(86799397, 1045611307, 332299298),
  emissoes_topdown_tco2e = c(1228, 1749983, 773628)
)

# == Apendice II ==============================================================

# Quadro 5: fator de emissao da frota de veiculos leves (DETRAN 2023, ANP 2021,
# GHG Protocol Brasil). Renovaveis (etanol) contabilizam apenas CH4+N2O.
fe_veiculos_leves <- data.frame(
  classe = c("Carros","Carros","Carros","Carros","Carros",
             "Motocicleta","Motocicleta","Motocicleta",
             "Carros","Motocicleta"),
  combustivel = c("Flex/gasolina C","Flex/etanol","Etanol","Gasolina C","Diesel",
                  "Flex/gasolina C","Flex/etanol","Gasolina C",
                  "Média frota","Média frota"),
  distribuicao = c(0.5691, 0.0667, 0.0324, 0.2823, 0.0495,
                   0.3032, 0.0356, 0.6592, NA, NA),
  km_por_l = c(12.41, 8.57, 7.05, 11.26, 10.18, 43.11, 28.97, 37.18,
               11.55, 38.61),
  fe_gco2e_por_l = c(1672.5, 14.1, 14.1, 1672.5, 2328.1,
                     1672.5, 14.1, 1672.5, 1540.5, 1610.2),
  fe_gco2e_por_km = c(134.7, 1.7, 2.0, 148.5, 228.7, 38.8, 0.5, 45.0,
                      133.4, 41.7)
)

# Tabela 1: frota veicular do DF (DETRAN 23/08/2023)
frota_veicular_df <- data.frame(
  classe = c("Automóvel","Motocicleta","Caminhonete","Camioneta","Utilitário",
             "Caminhão","Ônibus (fora do STC)","Ônibus do STC","Outros"),
  quantidade = c(1357827, 257657, 141156, 113171, 43958, 27095, 10511, 2977,
                 45974),
  percentual = c(0.6788, 0.1288, 0.0706, 0.0566, 0.0220, 0.0135, 0.0053,
                 0.0015, 0.0230)
)

# Tabela 7: consumo de diesel no DF em 2021 por classe
consumo_diesel_df_2021 <- data.frame(
  classe = c("Ônibus do STC","Caminhão","Ônibus (fora do STC)",
             "Utilitário (utilitário, caminhonete e camioneta)"),
  quantidade_veiculos = c(NA, 27000, 10500, 81424),
  rendimento_km_l = c(2.1, 3.33, 2.10, 10.18),
  diesel_litros = c(117058280.48, 82708594.55, 50981723.34, 81550699.63)
)

# == Apendice III =============================================================

# Tabela 1: Sistema de Transporte Coletivo (SEMOB; ANP 2021)
parametros_stc <- data.frame(
  viagens_ano = 6772158,
  km_ano = 245822389,
  rendimento_km_l = 2.1,
  diesel_litros_ano = 117058280.48,
  emissoes_tco2e_ano = 272524.05
)

# Curva consumo x velocidade (Silva e Brasil, 2020): C = 3.7072 * V^(-0.629)
# (C em L/km; V em km/h). Velocidade BRT DF = 51,6 km/h; faixa exclusiva
# corrigida = ((18+22)/2) * 51,6/((22+30)/2) = 39,69 km/h.

# Quadro 1 (do Apendice III): rendimento e FE por tipo de onibus/operacao
fe_onibus <- data.frame(
  veiculo = rep(c("Padron (básico)","Padron (básico)","Articulado","Articulado"), 3),
  operacao = rep(c("Trânsito comum","Faixa exclusiva","BRT"), each = 4),
  combustivel = rep(c("Diesel B12","Biodiesel B100"), 6),
  rendimento_km_l = c(1.82, 1.61, 1.33, 1.18, 2.73, 2.42, 2.00, 1.77,
                      3.45, 3.05, 2.53, 2.24),
  fe_combustivel_gco2e_l = c(2328.1, 14.6, 2328.1, 14.6, 2328.1, 14.6, 2328.1,
                             14.6, 2328.1, 14.6, 2328.1, 14.6),
  fe_veiculo_gco2e_km = c(1280.5, 9.10, 1746.1, 12.43, 852.0, 6.0, 1161.9, 8.2,
                          675.2, 4.8, 920.7, 6.5)
)

# == Apendice IV ==============================================================

# Elasticidade VKT x expansao viaria (Chen et al., 2020): ~0,993 (~1).
# A calculadora usa VKV_induzido = 1 (padrao, editavel pelo usuario).
parametros_vkv <- data.frame(
  parametro = "elasticidade_vkt_faixas",
  valor = 0.993,
  fonte = "Chen et al. (2020), Apendice IV"
)

# == Apendice V ===============================================================

# Quadro 1: estoques de carbono (tC/ha) por classe
estoque_carbono_vegetacao <- data.frame(
  grupo = c("Vegetação Nativa","Vegetação Nativa","Vegetação Nativa",
            "Vegetação Plantada"),
  classe = c("Campestre","Savânica","Florestal","Florestal Urbana"),
  fwd_tc_ha = c(0.11, 27.26, 27.26, 27.26),
  cwd_tc_ha = c(3.63, 24.82, 24.82, 24.82),
  agb_tc_ha = c(24.92, 41.32, 71.42, 71.42)
)

# Quadro 2: fatores de combustao (proporcao queimada)
fatores_combustao <- data.frame(
  grupo = c("Vegetação Nativa","Vegetação Nativa","Vegetação Nativa",
            "Vegetação Plantada"),
  classe = c("Campestre","Savânica","Florestal","Florestal Urbana"),
  fwd = c(0.883, 0.873, 0.629, 0.629),
  cwd = c(0.331, 0.459, 0.824, 0.824)
)

# Tabela 1: fatores de emissao por queima (g/kg materia seca)
fe_queimada <- data.frame(
  gas = c("CO2","CO","CH4","N2O","NOx"),
  campestre_savanica = c(1613, 65, 2.3, 0.21, 3.9),
  florestal = c(1580, 104, 6.8, 0.2, 1.6),
  florestal_urbana = c(1580, 104, 6.8, 0.2, 1.6)
)

# Quadro 3: incremento anual (MgC/ha/ano); IPCC adotado nas estimativas
incremento_remocao <- data.frame(
  grupo = c("Vegetação Nativa","Vegetação Nativa","Vegetação Nativa",
            "Vegetação Plantada"),
  classe = c("Campestre","Savânica","Florestal","Florestal Urbana"),
  seeg = c(0.20, 0.20, 0.20, 0.20),
  ipcc = c(0.49, 0.49, 1.17, 2.80)
)

# Constantes do Apendice V: fracao de carbono 0,49; conversao C->CO2 44/12=3,67;
# GWP AR6: CH4=27, N2O=273
constantes_uso_solo <- data.frame(
  constante = c("fracao_carbono","razao_co2_c","gwp_ch4_ar6","gwp_n2o_ar6"),
  valor = c(0.49, 3.6667, 27, 273)
)

# Tabela 5: cobertura vegetal, estoque e remocoes por RA (base 2021)
vegetacao_ra <- data.frame(
  ra_id = c("RA I","RA II","RA III","RA IV","RA IX","RA V","RA VI","RA VII",
            "RA VIII","RA X","RA XI","RA XIII","RA XIV","RA XIX","RA XV",
            "RA XVI","RA XVII","RA XVIII","RA XX","RA XXI","RA XII","RA XXII",
            "RA XXIII","RA XXIV","RA XXIX","RA XXV","RA XXVI","RA XXVII",
            "RA XXVIII","RA XXX","RA XXXI","RA XXXII","RA XXXIII"),
  ra = c("Plano Piloto","Gama","Taguatinga","Brazlândia","Ceilândia",
         "Sobradinho","Planaltina","Paranoá","Núcleo Bandeirante","Guará",
         "Cruzeiro","Santa Maria","São Sebastião","Candangolândia",
         "Recanto das Emas","Lago Sul","Riacho Fundo","Lago Norte",
         "Águas Claras","Riacho Fundo II","Samambaia","Sudoeste e Octogonal",
         "Varjão","Park Way","SIA","SCIA","Sobradinho II","Jardim Botânico",
         "Itapoã","Vicente Pires","Fercal","Sol Nascente / Pôr do Sol",
         "Arniqueira"),
  floresta_urbana_ha = c(1269.14,158.32,85.94,21.42,73.15,94.99,91.97,7.44,
                         21.61,72.01,26.76,17.25,57.45,5.16,11.01,614.66,
                         16.58,288.30,9.13,5.47,27.49,31.80,2.33,664.48,48.57,
                         3.94,61.41,171.84,50.89,146.17,11.30,42.88,95.78),
  campo_ha = c(21.78,0,0,0.64,0,13.81,2.48,0,0,1.28,0,0,0.56,0,0,11.81,0,7.64,
               0,0,0,0,0,2.06,0,0,0.99,6.11,0.02,50.83,1.59,0.00,8.39),
  savana_ha = c(69.39,0.97,1.99,1.93,0,15.62,0,0,0,3.04,0,5.23,14.70,0,0,
                93.86,0,8.57,0.15,0,0,0,0.44,57.44,0.12,0.02,13.53,17.58,0.24,
                122.04,2.89,0.01,16.22),
  floresta_ha = c(521.99,3.26,30.64,34.84,0.01,64.38,68.60,0,4.26,47.87,0,
                  3.40,134.36,0.02,0,473.31,5.67,37.48,0.22,0,0.01,10.85,0.64,
                  585.98,25.61,0.19,49.00,276.77,34.72,163.25,77.58,41.06,
                  86.58),
  gramados_jardins_ha = c(3182.52,360.46,315.36,34.41,224.48,338.65,137.02,
                          37.48,31.83,155.73,55.69,127.90,55.05,4.60,163.18,
                          455.44,27.59,157.77,96.84,145.83,583.46,178.38,3.88,
                          959.07,80.05,21.79,75.45,154.82,32.74,76.64,7.30,
                          11.65,29.99),
  estoque_carbono_tc = c(131332.46,11580.12,8408.37,4113.79,5225.09,12371.77,
                         11529.71,531.36,1847.64,8719.34,1911.20,1690.93,
                         14320.43,369.96,786.33,81875.42,1589.10,23811.71,
                         673.98,390.67,1964.05,3046.06,230.30,91732.61,5302.89,
                         295.79,8469.21,32918.39,6124.68,28408.15,6506.85,
                         5995.41,13903.44),
  remocoes_tco2e_ano = c(15432.98,1641.27,1018.46,375.27,751.05,1306.66,
                         1245.49,76.38,240.29,954.18,274.74,201.21,1198.57,
                         53.06,113.04,8548.22,194.75,3151.17,94.96,56.16,
                         282.27,373.42,27.48,9464.24,609.67,41.31,868.57,
                         3004.28,673.16,2517.60,459.73,617.91,1402.16)
)

# == Apendice VI ==============================================================

# Quadro 1: emissões/remocoes anuais (tCO2e/ha/ano) por transicao de uso
matriz_manejo_solo <- data.frame(
  uso_anterior = c(
    "Cana-de-açúcar com queima",
    "Cultivo convencional","Cultivo convencional","Cultivo convencional",
    "Cultivo convencional","Cultivo convencional",
    "Integração lavoura-pecuária","Integração lavoura-pecuária",
    "Integração lavoura-pecuária","Integração lavoura-pecuária",
    "Pastagem degradada","Pastagem degradada","Pastagem degradada",
    "Pastagem degradada","Pastagem degradada","Pastagem degradada",
    "Pastagem melhorada","Pastagem melhorada","Pastagem melhorada",
    "Pastagem melhorada","Pastagem melhorada","Pastagem melhorada",
    "Pastagem melhorada com insumos","Pastagem melhorada com insumos",
    "Pastagem melhorada com insumos","Pastagem melhorada com insumos",
    "Pastagem melhorada com insumos","Pastagem melhorada com insumos",
    "Pastagem melhorada sem insumos","Pastagem melhorada sem insumos",
    "Pastagem melhorada sem insumos","Pastagem melhorada sem insumos",
    "Pastagem melhorada sem insumos",
    "Pastagem moderadamente degradada","Pastagem moderadamente degradada",
    "Pastagem moderadamente degradada","Pastagem moderadamente degradada",
    "Pastagem severamente degradada","Pastagem severamente degradada",
    "Pastagem severamente degradada","Pastagem severamente degradada",
    "Plantio direto","Plantio direto",
    "Agricultura","Área degradada","Pastagem","Pastagem degradada",
    "Agricultura","Área degradada","Pastagem","Pastagem degradada",
    "Agricultura","Área degradada","Pastagem","Pastagem degradada",
    "Agricultura","Área degradada","Pastagem","Pastagem degradada",
    "Agricultura","Área degradada","Pastagem","Pastagem degradada"),
  uso_atual = c(
    "Cana-de-açúcar sem queima",
    "Integração lavoura-pecuária (floresta)","Pastagem melhorada",
    "Pastagem melhorada com insumos","Plantio direto","Sistema agroflorestal",
    "Cultivo convencional","Pastagem melhorada",
    "Pastagem melhorada com insumos","Plantio direto",
    "Cana-de-açúcar com queima","Cultivo convencional",
    "Integração lavoura-pecuária (floresta)","Pastagem melhorada com insumos",
    "Pastagem melhorada","Plantio direto",
    "Integração lavoura-pecuária (floresta)","Pastagem melhorada",
    "Pastagem melhorada com insumos","Pastagem moderadamente degradada",
    "Pastagem severamente degradada","Sistema agroflorestal",
    "Integração lavoura-pecuária (floresta)","Pastagem melhorada",
    "Pastagem melhorada com insumos","Pastagem melhorada sem insumos",
    "Pastagem moderadamente degradada","Pastagem severamente degradada",
    "Pastagem melhorada","Pastagem melhorada com insumos",
    "Pastagem melhorada sem insumos","Pastagem moderadamente degradada",
    "Pastagem severamente degradada",
    "Pastagem melhorada","Pastagem melhorada com insumos",
    "Pastagem melhorada sem insumos","Pastagem severamente degradada",
    "Pastagem melhorada","Pastagem melhorada sem insumos",
    "Pastagem moderadamente degradada","Pastagem severamente degradada",
    "Cultivo convencional","Integração lavoura-pecuária (floresta)",
    "Eucalipto","Eucalipto","Eucalipto","Eucalipto",
    "Paricá","Paricá","Paricá","Paricá",
    "Pinus","Pinus","Pinus","Pinus",
    "Seringueira","Seringueira","Seringueira","Seringueira",
    "Teca","Teca","Teca","Teca"),
  tco2e_ha_ano = c(
    -2.25,
    -6.23,-3.67,-3.67,-1.76,-8.73,
    1.72,-2.56,-2.56,-1.76,
    0.94,0.92,-6.23,-3.67,-3.67,-0.70,
    -3.67,-4.63,-4.63,4.13,4.50,-1.61,
    -3.67,-4.63,-4.63,-3.67,4.13,4.50,
    -4.63,-4.63,-3.67,1.50,3.54,
    -4.13,-4.13,-3.54,2.03,
    -4.50,-3.54,-2.02,1.83,
    0.92,-1.03,
    -0.97,-1.54,-0.97,-0.8,
    -4.59,-1.47,-4.4,-4.22,
    -0.96,-0.81,-0.96,-0.79,
    -6.39,-1.47,-6.12,-6.03,
    -6.39,-1.47,-6.12,-6.03),
  referencia = c(
    "GALDOS et al., 2011",
    "ASSAD, 2015","ASSAD, 2015","ASSAD, 2015","MAIA et al., 2013",
    "FROUFE et al., 2011 (adapt.)",
    "ASSAD, 2015 (adapt.)","ASSAD, 2015 (adapt.)","ASSAD, 2015 (adapt.)",
    "ASSAD, 2015 (adapt.)",
    "MELLO et al., 2014","MAIA et al., 2009 (adapt.)","ASSAD e MARTINS, 2015",
    "IPCC, 2006; ASSAD, 2015 (adapt.)","ASSAD, 2015","MAIA et al., 2013",
    "ASSAD, 2015","IPCC, 2006","IPCC, 2006",
    "IPCC, 2006; ASSAD, 2015 (adapt.)","IPCC, 2006; ASSAD, 2015 (adapt.)",
    "FROUFE et al., 2011 (adapt.)",
    "FROUFE et al., 2011 (adapt.)","IPCC, 2006","IPCC, 2006","IPCC, 2006",
    "IPCC, 2006","IPCC, 2006",
    "IPCC, 2006; ASSAD, 2015 (adapt.)","IPCC, 2006","IPCC, 2006","IPCC, 2006",
    "IPCC, 2006",
    "IPCC, 2006; ASSAD, 2015 (adapt.)","IPCC, 2006","IPCC, 2006","IPCC, 2006",
    "IPCC, 2006; ASSAD, 2015 (adapt.)","IPCC, 2006","IPCC, 2006","IPCC, 2006",
    "MAIA et al., 2009 (adapt.)","MAIA et al., 2013",
    "LIMA et al., 2008","LIMA et al., 2008","LIMA et al., 2008","LIMA et al., 2008",
    "LIMA et al., 2008","LIMA et al., 2008","LIMA et al., 2008","LIMA et al., 2008",
    "DE GODOI, 2016; LIMA et al., 2008 (adapt.)","LIMA et al., 2008",
    "DE GODOI, 2016; LIMA et al., 2008 (adapt.)","LIMA et al., 2008",
    "ESTEVAM et al., 2023; GODOI, 2016; LIMA et al., 2008 (adapt.)","LIMA et al., 2008",
    "ESTEVAM et al., 2023; GODOI, 2016; LIMA et al., 2008 (adapt.)","LIMA et al., 2008",
    "ESTEVAM et al., 2023; GODOI, 2016; LIMA et al., 2008 (adapt.)","LIMA et al., 2008",
    "ESTEVAM et al., 2023; GODOI, 2016; LIMA et al., 2008 (adapt.)","LIMA et al., 2008")
)

# == Apendice VII =============================================================

# Tabela 2: fatores medios anuais de emissao do SIN (tCO2/MWh) - MCTI (2024)
fe_energia_sin <- data.frame(
  ano = 2014:2023,
  tco2_por_mwh = c(0.1355, 0.1244, 0.0817, 0.0927, 0.0740, 0.0750, 0.0617,
                   0.1264, 0.0426, 0.0385)
)

# Tabela 1: consumo energetico por RA (NEOENERGIA; 12o mes excluido; medianas)
consumo_energia_ra <- data.frame(
  ra = c("Plano Piloto","Gama","Taguatinga","Brazlândia","Ceilândia",
         "Sobradinho","Planaltina","Paranoá","Núcleo Bandeirante","Guará",
         "Cruzeiro","Santa Maria","São Sebastião","Candangolândia",
         "Recanto das Emas","Lago Sul","Riacho Fundo","Lago Norte",
         "Águas Claras","Riacho Fundo II","Samambaia","Sudoeste e Octogonal",
         "Varjão","Park Way","SIA","SCIA","Sobradinho II","Jardim Botânico",
         "Itapoã","Vicente Pires","Fercal","Sol Nascente / Pôr do Sol",
         "Arniqueira"),
  consumo_medio_mensal_kwh_domicilio = c(188.41,153.60,168.44,161.37,156.55,
    189.37,146.54,143.49,166.51,175.76,189.99,118.33,138.60,178.31,148.01,
    561.40,150.62,261.97,189.63,147.65,155.40,187.16,133.89,436.07,152.48,
    122.70,188.61,291.61,176.61,203.71,140.86,132.74,186.07),
  energia_2021_kwh = c(219805152.75,74396631.28,160487464.24,13403076.75,
    177914310.79,52828992.95,35598416.05,21741332.08,10820376.25,94659504.53,
    25415381.66,54335912.28,33012300.82,9421522.12,47390400.95,74396631.28,
    22857181.57,42790567.87,141560548.13,14264794.42,109446822.86,45960677.49,
    4894575.87,40053537.69,472608.61,9393096.35,41773246.63,48163365.95,
    13734931.78,61609760.02,3536333.23,39306.51,22791095.74),
  emissoes_tco2_2021 = c(27783.37,9403.73,20285.62,1694.15,22488.37,6677.58,
    4499.64,2748.10,1367.70,11964.96,3212.50,6868.06,4172.75,1190.88,5990.15,
    9403.73,2889.15,5408.73,17893.25,1803.07,13834.08,5809.43,618.67,5062.77,
    59.74,1187.29,5280.14,6087.85,1736.10,7787.47,446.99,4.97,2880.79),
  emissoes_kgco2_hab = c(123.57,68.47,96.37,30.32,64.19,90.93,24.13,39.34,
    56.77,84.21,104.10,52.44,35.07,72.89,44.85,308.87,64.98,144.08,148.98,
    24.70,55.87,104.93,69.10,219.35,1.59,31.64,66.98,114.77,26.56,99.13,
    47.61,0.05,61.23)
)
# Nota: Lago Sul apresenta energia 2021 identica a Gama no PDF (possivel erro
# de impressao); mantido conforme publicado.

# == Apendice VIII ============================================================

# Tabela 1: fatores de emissao especificos (kg CO2e/t; GIEGRICH, 2021)
fe_residuos <- data.frame(
  material = c("Resíduo orgânico (compostagem)","Papel e papelão","Vidro",
               "Metais ferrosos","Alumínio","Plástico"),
  kgco2e_por_t = c(71, -292, -121, -1648, -9183, -1500)
)
# Aterro sanitario DF: 1,27 tCO2e/t (simulacao ferramenta ProteGEEr/GIZ)

# Tabela 2: composicao gravimetrica (% de residuos umidos; 2023, 3 lotes)
composicao_gravimetrica <- data.frame(
  componente = c("Resíduos de alimentos","Resíduos de jardins e parques",
                 "Plástico","Papel","Vidro","Alumínio","Metal ferroso",
                 "Tecido","Borracha e couro","Fraldas (descartáveis)",
                 "Madeira","Resíduos minerais","Outros"),
  coleta_convencional_pct = c(45.2,5,14.5,8.4,3.4,0.4,1.2,2.6,0.7,4,0.8,0.5,
                              13.8),
  coleta_seletiva_pct = c(13.3,1.5,25.7,30.8,8.2,0.9,1.8,3.4,1.3,4,1.2,1.2,6.7)
)

# Tabela 3: residuos solidos por RA (SLU 2021; ferramenta GRS GEE)
residuos_ra <- data.frame(
  ra = c("Plano Piloto","Gama","Taguatinga","Brazlândia","Ceilândia",
         "Sobradinho","Planaltina","Paranoá","Núcleo Bandeirante","Guará",
         "Cruzeiro","Santa Maria","São Sebastião","Candangolândia",
         "Recanto das Emas","Lago Sul","Riacho Fundo","Samambaia",
         "Sudoeste e Octogonal","Varjão","Park Way","SIA","SCIA",
         "Sobradinho II","Jardim Botânico","Itapoã","Vicente Pires","Fercal",
         "Sol Nascente / Pôr do Sol","Arniqueira"),
  residuo_domiciliar_t_ano = c(64964.84,34026.16,51871.20,12415.42,70867.89,
    16978.12,41891.06,12036.40,7272.20,33205.61,5835.45,26656.76,24137.40,
    3786.29,25177.95,21585.08,17084.72,49043.61,14375.09,1837.09,12866.58,
    5243.55,11108.00,19589.44,9621.71,15883.06,25467.31,3948.34,22450.91,
    13442.96),
  residuo_seletivo_t_ano = c(12189.12,582.77,3145.20,358.79,2763.63,185.96,
    42.86,34.08,110.48,2727.36,264.76,617.25,9.13,92.45,622.10,44.67,78.71,
    333.89,2492.71,NA,12.15,4.77,NA,719.80,1.10,NA,410.75,NA,0.00,11.34),
  perc_reciclado = c(0.19,0.02,0.06,0.03,0.04,0.01,0.00,0.00,0.02,0.08,0.05,
    0.02,0.00,0.02,0.02,0.00,0.00,0.01,0.17,NA,0.00,0.00,NA,0.04,0.00,NA,
    0.02,NA,0.00,0.00),
  geracao_kg_hab_ano = c(288.93,247.77,246.42,222.18,202.28,231.19,224.62,
    172.30,301.84,233.71,189.09,203.53,202.88,231.73,188.51,708.96,384.24,
    198.05,259.64,205.19,557.45,139.73,296.00,248.48,181.39,242.96,324.17,
    420.57,247.87,285.75),
  emissoes_totais_tco2e_ano = c(98790.00,39412.00,73882.00,18252.00,96268.40,
    21915.62,58437.41,16804.46,7275.76,39568.62,8722.10,31467.53,32847.71,
    4234.47,28914.59,25572.60,17362.76,67578.79,22801.90,2598.00,14474.30,
    6767.72,12192.32,28393.26,11807.89,20882.21,29564.35,5451.00,31263.60,
    14800.00),
  emissoes_evitadas_tco2e_ano = c(12130.00,661.00,3525.00,390.00,3166.27,
    207.52,46.61,37.06,120.15,3581.55,285.61,671.29,9.93,100.54,713.33,
    48.58,85.60,363.12,822.80,0.00,13.21,5.19,15.74,914.69,1.20,0.00,425.63,
    16.00,0.00,18.00),
  emissoes_liquidas_tco2e_ano = c(86660.00,38752.00,70356.00,17862.00,
    93102.13,21708.10,58390.80,16767.40,7155.61,35987.07,6410.00,30796.24,
    32837.78,4133.93,28201.26,25524.02,17277.16,67215.67,21979.10,2598.00,
    14461.09,6762.53,12176.58,27478.57,11806.69,16440.00,29138.72,5435.00,
    31263.60,14782.00),
  emissoes_liquidas_kgco2_hab_ano = c(385.42,282.18,334.24,319.65,265.74,
    295.60,313.09,240.02,297.00,253.28,207.71,235.14,276.01,253.01,211.14,
    838.34,388.57,271.44,396.98,290.18,626.54,180.20,324.48,348.55,222.58,
    251.48,370.91,578.93,345.17,314.21)
)

# Salvar -----------------------------------------------------------------
datasets <- c("ra_parametros","distancias_deslocamento","parametros_viagens",
              "viagens_pmu_2017","venda_combustivel_df_2021",
              "fe_veiculos_leves","frota_veicular_df","consumo_diesel_df_2021",
              "parametros_stc","fe_onibus","parametros_vkv",
              "estoque_carbono_vegetacao","fatores_combustao","fe_queimada",
              "incremento_remocao","constantes_uso_solo","vegetacao_ra",
              "matriz_manejo_solo","fe_energia_sin","consumo_energia_ra",
              "fe_residuos","composicao_gravimetrica","residuos_ra")
for (nm in datasets) {
  assign(nm, get(nm))  # no-op; apenas para clareza
  save(list = nm, file = file.path("data", paste0(nm, ".rda")),
       compress = "bzip2", version = 3)
}
message("Dados gerados em data/: ", paste(datasets, collapse = ", "))
