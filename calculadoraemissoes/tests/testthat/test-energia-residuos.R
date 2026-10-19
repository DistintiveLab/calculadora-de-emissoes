test_that("calc_eficiencia_energetica usa FE do SIN", {
  res <- calc_eficiencia_energetica(1000, 10)
  expect_equal(res$emissoes_evitadas_tco2_ano, 0.01264)
  res_2023 <- calc_eficiencia_energetica(1000, 10, ano_fe = 2023)
  expect_equal(res_2023$fe_tco2_mwh, 0.0385)
  expect_error(calc_eficiencia_energetica(1000, 10, ano_fe = 2010), "2014")
})

test_that("calc_compostagem aplica aterro menos compostagem", {
  res <- calc_compostagem(100, 50)
  expect_equal(res$residuo_compostado_t_ano, 50)
  expect_equal(res$emissoes_evitadas_tco2_ano, 50 * (1.27 - 0.071))
  total <- calc_compostagem(100, 100)
  expect_equal(total$emissoes_evitadas_tco2_ano, 119.9, tolerance = 0.001)
})

test_that("calc_reciclagem soma benefício líquido do material", {
  al <- calc_reciclagem(10, "Alumínio", 100)
  expect_equal(al$fe_material_tco2_t, -9.183)
  expect_equal(al$emissoes_evitadas_tco2_ano, 104.53, tolerance = 0.001)
  papel <- calc_reciclagem(10, "Papel e Papelão", 50)
  expect_equal(papel$emissoes_evitadas_tco2_ano,
               5 * (1.27 + 0.292))
  expect_error(calc_reciclagem(10, "Orgânico", 100), "Material")
})
