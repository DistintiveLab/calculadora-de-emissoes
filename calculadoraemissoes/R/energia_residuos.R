#' Emissões evitadas com eficiência energética
#'
#' Aplica a economia esperada ao consumo elétrico anual e converte pelo fator
#' de emissão do SIN.
#'
#' @details Emissões evitadas = consumo x economia%/100 x FE (tCO2/MWh)/1000.
#'   Padrão: SIN 2021 = 0,1264 tCO2/MWh (Apendice VII, Tabela 2, MCTI 2024).
#'
#' @param consumo_kwh_ano consumo energético de referência em kWh/ano.
#' @param economia_pct economia esperada da ação em percentual (0-100).
#' @param ano_fe ano do fator do SIN (2014-2023); se `NULL`, usa 2021.
#' @return lista com `economia_kwh_ano`, `fe_tco2_mwh`, `ano_fe` e
#'   `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_eficiencia_energetica(1000, 10)
calc_eficiencia_energetica <- function(consumo_kwh_ano, economia_pct,
                                       ano_fe = NULL) {
  if (is.null(ano_fe)) {
    fe <- 0.1264
    ano_fe <- 2021
  } else {
    f <- fe_energia_sin[fe_energia_sin$ano == ano_fe, ]
    if (nrow(f) == 0) {
      stop("ano_fe deve estar entre 2014 e 2023.", call. = FALSE)
    }
    fe <- f$tco2_por_mwh
  }
  economia <- consumo_kwh_ano * economia_pct / 100
  list(
    economia_kwh_ano = economia,
    fe_tco2_mwh = fe,
    ano_fe = ano_fe,
    emissoes_evitadas_tco2_ano = economia * fe / 1000
  )
}

#' Emissões evitadas com compostagem
#'
#' Compara o destino de resíduos orgânicos entre aterro e compostagem.
#'
#' @details Emissões evitadas = resíduo x meta%/100 x (FE aterro - FE
#'   compostagem), com FE aterro DF = 1,27 tCO2e/t (simulação ProteGEEr/GIZ) e
#'   FE compostagem = 0,071 tCO2e/t (71 kg CO2e/t, GIEGRICH 2021) - ambos do
#'   Apendice VIII.
#'
#' @param residuo_t_ano resíduo orgânico disposto em base (t/ano).
#' @param meta_pct meta de aumento da compostagem em percentual (0-100).
#' @param fe_aterro_tco2_t fator do aterro (tCO2e/t).
#' @param fe_compostagem_tco2_t fator da compostagem (tCO2e/t).
#' @return lista com `residuo_compostado_t_ano`, `fe_aterro_tco2_t`,
#'   `fe_compostagem_tco2_t`, `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_compostagem(100, 50)
calc_compostagem <- function(residuo_t_ano, meta_pct,
                             fe_aterro_tco2_t = 1.27,
                             fe_compostagem_tco2_t = 0.071) {
  compostado <- residuo_t_ano * meta_pct / 100
  list(
    residuo_compostado_t_ano = compostado,
    fe_aterro_tco2_t = fe_aterro_tco2_t,
    fe_compostagem_tco2_t = fe_compostagem_tco2_t,
    emissoes_evitadas_tco2_ano = compostado *
      (fe_aterro_tco2_t - fe_compostagem_tco2_t)
  )
}

#' Emissões evitadas com reciclagem
#'
#' Compara o destino de resíduos recicláveis entre aterro e reciclagem,
#' usando os fatores líquidos específicos por material.
#'
#' @details Emissões evitadas = resíduo x meta%/100 x (FE aterro - FE
#'   material/1000). Os fatores líquidos (GIEGRICH 2021, Apendice VIII,
#'   Tabela 1) são negativos (benefício), então alumínio, por exemplo, evita
#'   1,27 + 9,183 = 10,453 tCO2e por tonelada reciclada.
#'
#' @param residuo_t_ano resíduo disposto em base (t/ano).
#' @param material material reciclável: Alumínio, Metais ferrosos,
#'   Papel e papelão, Plástico ou Vidro.
#' @param meta_pct meta de aumento da reciclagem em percentual (0-100).
#' @param fe_aterro_tco2_t fator do aterro (tCO2e/t).
#' @return lista com `material`, `residuo_reciclado_t_ano`,
#'   `fe_material_tco2_t` (negativo), `fe_aterro_tco2_t`,
#'   `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_reciclagem(10, "Alumínio", 100)
calc_reciclagem <- function(residuo_t_ano, material, meta_pct,
                            fe_aterro_tco2_t = 1.27) {
  alvo <- padrao_busca(material)
  chaves <- padrao_busca(fe_residuos$material)
  chaves[chaves == "residuo organico compostagem"] <- "compostagem"
  idx <- match(alvo, chaves)
  if (is.na(idx)) {
    stop("Material nao reconhecido: ", material, ". Opcoes validas: ",
         paste(fe_residuos$material, collapse = "; "), call. = FALSE)
  }
  fe_material <- fe_residuos$kgco2e_por_t[idx] / 1000
  reciclado <- residuo_t_ano * meta_pct / 100
  list(
    material = fe_residuos$material[idx],
    residuo_reciclado_t_ano = reciclado,
    fe_material_tco2_t = fe_material,
    fe_aterro_tco2_t = fe_aterro_tco2_t,
    emissoes_evitadas_tco2_ano = reciclado * (fe_aterro_tco2_t - fe_material)
  )
}
