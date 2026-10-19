test_that("calc_manejo_baixo_carbono consulta a matriz do Apendice VI", {
  r1 <- calc_manejo_baixo_carbono("Cana-de-açúcar com queima",
                                  "Cana-de-açúcar sem queima", 10)
  expect_equal(r1$fator_tco2e_ha_ano, -2.25)
  expect_equal(r1$emissao_liquida_tco2e_ano, -22.5)
  r2 <- calc_manejo_baixo_carbono("Pastagem melhorada",
                                  "Pastagem moderadamente degradada", 1)
  expect_equal(r2$fator_tco2e_ha_ano, 4.13)
  r3 <- calc_manejo_baixo_carbono("Agricultura", "Eucalipto", 1)
  expect_equal(r3$fator_tco2e_ha_ano, -0.97)
  r4 <- calc_manejo_baixo_carbono("Cultivo convencional",
                                  "Sistema agroflorestal", 1)
  expect_equal(r4$fator_tco2e_ha_ano, -8.73)
  expect_error(calc_manejo_baixo_carbono("Cerrado", "Eucalipto", 1),
               "Transicao nao encontrada")
})

test_that("calc_manejo_baixo_carbono aceita grafias do menu", {
  r <- calc_manejo_baixo_carbono(
    "Integração lavoura-pecuária(-floresta)",
    "Cultivo convencional", 1)
  expect_equal(r$uso_anterior, "Integração lavoura-pecuária")
  expect_equal(r$fator_tco2e_ha_ano, 1.72)
  f <- calc_manejo_baixo_carbono("Cultivo convencional",
    "Integração lavoura-pecuária (-floresta)", 1)
  expect_equal(f$fator_tco2e_ha_ano, -6.23)
})

test_that("map_classe_vegetacao mapeia as 12 opções do menu", {
  m <- calculadoraemissoes:::map_classe_vegetacao
  expect_equal(m("Campestre (gramíneas nativas)")$agb_tc_ha, 24.92)
  expect_equal(m("Savânica (cerrado típico)")$incremento_mgc_ha_ano, 0.49)
  expect_equal(m("Florestal Nativa (arbóreas, Cerradão, Matas Galerias)")$agb_tc_ha,
               71.42)
  expect_equal(m("Florestal Urbana")$incremento_mgc_ha_ano, 2.80)
  expect_equal(m("Sem cobertura vegetal")$agb_tc_ha, 0)
  expect_warning(v <- m("Pastagem"), "sem dados de estoque")
  expect_true(is.na(v$agb_tc_ha))
})

test_that("calc_parcelamento_solo combina solo, veicular, PV e compostagem", {
  res <- calc_parcelamento_solo("Ceilândia", area_ha = 100,
    tipo_vegetacao = "Savânica (cerrado típico)", veg_nativa_ha = 20,
    perc_fotovoltaico = 10, perc_compostagem = 50,
    tipo_info = "Domicílios", qtde_info = 1000)
  expect_equal(res$emissao_uso_solo_tco2, 80 * 41.32 * 3.67)
  expect_equal(res$remocao_vegetacao_tco2_ano, 20 * 0.49 * 0.49 * 3.67)
  expect_equal(res$emissao_veicular_tco2_ano,
               1000 * 3.0 * 200.76 / 1000, tolerance = 0.001)
  expect_equal(res$compensacao_fotovoltaica_tco2_ano,
               1000 * 156.55 * 12 * 0.10 * 0.1264 / 1000)
  comp <- 70867.89 * (1000 / 110111) * 0.452 * 0.5 * (1.27 - 0.071)
  expect_equal(res$compensacao_compostagem_tco2_ano, comp)
  pessoas <- calc_parcelamento_solo("Gama", 10, "Sem cobertura vegetal",
    tipo_info = "Pessoas", qtde_info = 2800)
  expect_equal(pessoas$domicilios, 1000, tolerance = 0.001)
  expect_equal(pessoas$emissao_uso_solo_tco2, 0)
  expect_warning(sem_dados <- calc_parcelamento_solo("Águas Claras", 10,
    "Sem cobertura vegetal", perc_compostagem = 10,
    tipo_info = "Domicílios", qtde_info = 100), "residuos")
  expect_true(is.na(sem_dados$compensacao_compostagem_tco2_ano))
})

test_that("calc_combate_grilagem deriva lotes e remoção", {
  res <- calc_combate_grilagem("Ceilândia", "Florestal Urbana", 10, 250)
  expect_equal(res$numero_lotes, 400)
  expect_equal(res$emissao_veicular_tco2_ano,
               400 * 3.0 * 200.76 / 1000, tolerance = 0.001)
  expect_equal(res$remocao_vegetacao_tco2_ano, 10 * 2.80 * 0.49 * 3.67)
  expect_error(calc_combate_grilagem("Ceilândia", "Florestal Urbana", 10, 0),
               "tam_lotes_m2")
})

test_that("calc_recuperacao_degradadas compara estoques e incrementos", {
  expect_warning(
    res <- calc_recuperacao_degradadas("Pastagem", "Savânica (cerrado típico)", 50),
    "sem dados de estoque")
  expect_true(is.na(res$variacao_estoque_tco2))
  r2 <- calc_recuperacao_degradadas("Sem cobertura vegetal",
                                    "Florestal Urbana", 10)
  expect_equal(r2$variacao_estoque_tco2, 71.42 * 3.67 * 10)
  expect_equal(r2$variacao_remocao_tco2_ano, 2.80 * 0.49 * 3.67 * 10)
})
