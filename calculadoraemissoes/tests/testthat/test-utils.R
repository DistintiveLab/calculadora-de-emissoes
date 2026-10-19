test_that("padronizar_ra aceita variações de escrita", {
  expect_equal(padronizar_ra("ceilandia"), "Ceilândia")
  expect_equal(padronizar_ra("RA IX"), "Ceilândia")
  expect_equal(padronizar_ra("  SOL NASCENTE/POR DO SOL "), "Sol Nascente / Pôr do Sol")
  expect_equal(padronizar_ra("plano piloto"), "Plano Piloto")
  expect_equal(padronizar_ra("ÁGUAS CLARAS"), "Águas Claras")
})

test_that("padronizar_ra é vetorizado e rejeita entradas inválidas", {
  expect_equal(padronizar_ra(c("gama", "RA IV")), c("Gama", "Brazlândia"))
  expect_error(padronizar_ra("Brasília"), "Opcoes validas")
})

test_that("numero_br converte padrão brasileiro", {
  expect_equal(numero_br("1.234,56"), 1234.56)
  expect_equal(numero_br("0,5"), 0.5)
  expect_equal(numero_br("1.045.611.307"), 1045611307)
  expect_equal(numero_br(c("12,34", 42)), c(12.34, 42))
  expect_true(is.na(numero_br("")))
})
