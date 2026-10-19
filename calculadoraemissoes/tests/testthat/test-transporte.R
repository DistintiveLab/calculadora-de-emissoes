test_that("calc_ciclovia reproduz o exemplo da Tabela 6 (±2%)", {
  res <- calc_ciclovia("Ceilândia", 1000)
  expect_equal(res$emissoes_evitadas_tco2_ano, 594.3, tolerance = 0.02)
  expect_equal(res$pessoas_atendidas, 3000)
})

test_that("calc_faixa_exclusiva usa fatores de trânsito comum e faixa exclusiva", {
  res <- calc_faixa_exclusiva(1, 10, "PADRON diesel", "PADRON diesel")
  expect_equal(res$km_ano, 520)
  expect_equal(res$fe_atual_gco2e_km, 1280.5)
  expect_equal(res$fe_proposto_gco2e_km, 852.0)
  expect_equal(res$emissoes_evitadas_tco2_ano, 520 * (1280.5 - 852.0) / 1e6)
  conv <- calc_faixa_exclusiva(1, 10, "CONVENCIONAL diesel", "ARTICULADO B100")
  expect_equal(conv$fe_atual_gco2e_km, 1280.5)
  expect_equal(conv$fe_proposto_gco2e_km, 8.2)
})

test_that("calc_brt pondera os tipos de ônibus BRT", {
  res <- calc_brt(1000, 100, "Automóvel", "PADRON diesel")
  expect_equal(res$fe_atual_gco2e_km, 133.4)
  expect_equal(res$fe_brt_ponderado_gco2e_km, 675.2)
  expect_equal(res$emissoes_evitadas_tco2_ano, 1000 * (133.4 - 675.2) / 1e6)
  misto <- calc_brt(1000, 50, "Motocicleta", "PADRON diesel",
                    "ARTICULADO diesel", 25)
  expect_equal(misto$fe_brt_ponderado_gco2e_km,
               0.25 * 675.2 + 0.75 * 920.7)
  onibus <- calc_brt(1000, 100, "ARTICULADO diesel", "ARTICULADO diesel")
  expect_equal(onibus$fe_atual_gco2e_km, 1746.1)
  expect_equal(onibus$emissoes_evitadas_tco2_ano, 1000 * (1746.1 - 920.7) / 1e6)
})

test_that("calc_obras_viarias aplica elasticidade e fatores por classe", {
  res <- calc_obras_viarias(2, 4, 1, qtd_medio_porte = 1)
  expect_equal(res$crescimento_vkt, 1)
  expect_equal(res$emissao_medio_tco2_ano, 365 * 133.4 / 1e6)
  total <- calc_obras_viarias(2, 4, 1, 1, 1, 1)
  expect_equal(total$emissao_induzida_tco2_ano,
               365 * (41.7 + 133.4 + 1513.3) / 1e6, tolerance = 0.001)
  expect_error(calc_obras_viarias(0, 4, 1), "faixas_atual")
})

test_that("calc_metro restringe às 8 RAs atendidas", {
  res <- calc_metro("Taguatinga", 5, 1000)
  expect_equal(res$extensao_metro_km, 5)
  expect_equal(res$emissoes_evitadas_tco2_ano,
               res$emissao_referencia_tco2_ano)
  parcial <- calc_metro("Guará", 5, 1000, prop_mudanca_modal = 0.5)
  expect_equal(parcial$emissoes_evitadas_tco2_ano,
               0.5 * parcial$emissao_referencia_tco2_ano)
  expect_error(calc_metro("Gama", 5, 1000), "RAs atendidas")
})

test_that("parâmetros STC fecham com diesel x fator de emissão", {
  litros <- parametros_stc$km_ano / parametros_stc$rendimento_km_l
  expect_equal(litros, parametros_stc$diesel_litros_ano, tolerance = 0.001)
  emissoes <- litros * 2328.1 / 1e6
  expect_equal(emissoes, 272524.05, tolerance = 0.001)
})
