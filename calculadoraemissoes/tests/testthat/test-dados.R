test_that("dados por RA têm as dimensões esperadas", {
  expect_equal(nrow(ra_parametros), 33)
  expect_equal(nrow(vegetacao_ra), 33)
  expect_equal(nrow(consumo_energia_ra), 33)
  expect_equal(nrow(residuos_ra), 30)
  expect_equal(nrow(matriz_manejo_solo), 63)
  expect_equal(nrow(fe_onibus), 12)
  expect_equal(length(unique(matriz_manejo_solo$uso_anterior)), 13)
  expect_equal(length(unique(matriz_manejo_solo$uso_atual)), 16)
})

test_that("valores-chave conferem com o PDF", {
  carro <- fe_veiculos_leves$fe_gco2e_por_km[
    fe_veiculos_leves$classe == "Carros" &
      fe_veiculos_leves$combustivel == "Média frota"]
  expect_equal(carro, 133.4)
  moto <- fe_veiculos_leves$fe_gco2e_por_km[
    fe_veiculos_leves$classe == "Motocicleta" &
      fe_veiculos_leves$combustivel == "Média frota"]
  expect_equal(moto, 41.7)
  expect_equal(fe_energia_sin$tco2_por_mwh[fe_energia_sin$ano == 2021], 0.1264)
  expect_equal(parametros_stc$emissoes_tco2e_ano, 272524.05)
  expect_true("Alumínio" %in% fe_residuos$material)
  expect_equal(fe_residuos$kgco2e_por_t[fe_residuos$material == "Alumínio"], -9183)
  expect_equal(sum(composicao_gravimetrica$coleta_convencional_pct), 100,
               tolerance = 0.01)
})

test_that("fe_onibus alinha veículo/operação/combustível com o Quadro 1", {
  lin <- function(v, o, c) {
    fe_onibus$fe_veiculo_gco2e_km[fe_onibus$veiculo == v &
      fe_onibus$operacao == o & fe_onibus$combustivel == c]
  }
  expect_equal(lin("Padron (básico)", "Trânsito comum", "Diesel B12"), 1280.5)
  expect_equal(lin("Articulado", "Trânsito comum", "Biodiesel B100"), 12.43)
  expect_equal(lin("Padron (básico)", "Faixa exclusiva", "Diesel B12"), 852.0)
  expect_equal(lin("Articulado", "BRT", "Diesel B12"), 920.7)
  expect_equal(lin("Padron (básico)", "BRT", "Biodiesel B100"), 4.8)
  b100_mais <- 1.61 < 1.82 * 1.13
  expect_true(b100_mais)
})

test_that("estoque publicado por RA reproduz AGB x área", {
  agb <- function(classe) {
    estoque_carbono_vegetacao$agb_tc_ha[estoque_carbono_vegetacao$classe == classe]
  }
  calc_estoque <- with(vegetacao_ra,
    floresta_urbana_ha * agb("Florestal Urbana") +
      campo_ha * agb("Campestre") +
      savana_ha * agb("Savânica") +
      floresta_ha * agb("Florestal"))
  expect_equal(calc_estoque[vegetacao_ra$ra == "Plano Piloto"], 131332.46,
               tolerance = 0.001)
  expect_equal(calc_estoque[vegetacao_ra$ra == "Ceilândia"], 5225.09,
               tolerance = 0.001)
})

test_that("Fercal tem NA nos parâmetros ausentes", {
  f <- ra_parametros[ra_parametros$ra == "Fercal", ]
  expect_true(is.na(f$moradores_por_domicilio))
  expect_true(is.na(f$pessoas_por_automovel))
})
