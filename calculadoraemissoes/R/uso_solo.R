#' Mapeia opção de vegetação para classe de estoque/incremento
#'
#' Converte as 12 opções do menu "tipo de vegetação" da calculadora nas
#' classes do Apendice V (Quadros 1 e 3). Classes sem dados de estoque
#' (pastagens, agricultura, jardins) retornam `NA` com aviso.
#'
#' @param x texto com a opção de vegetação.
#' @return lista com `classe`, `agb_tc_ha` e `incremento_mgc_ha_ano`.
#' @keywords internal
map_classe_vegetacao <- function(x) {
  s <- padrao_busca(x)
  classe <- if (grepl("sem cobertura", s)) {
    "sem cobertura vegetal"
  } else if (grepl("urbana", s) && grepl("floresta|florestal", s)) {
    "florestal urbana"
  } else if (grepl("campestre|graminea", s)) {
    "campestre"
  } else if (grepl("savanica|cerrado", s)) {
    "savanica"
  } else if (grepl("florestal nativa|cerradao|mata", s)) {
    "florestal"
  } else {
    NA_character_
  }
  if (is.na(classe)) {
    warning("Opcao de vegetacao sem dados de estoque no Apendice V: ", x,
            ". Componentes de solo retornam NA.", call. = FALSE)
    return(list(classe = NA_character_, agb_tc_ha = NA_real_,
                incremento_mgc_ha_ano = NA_real_))
  }
  if (classe == "sem cobertura vegetal") {
    return(list(classe = classe, agb_tc_ha = 0,
                incremento_mgc_ha_ano = 0))
  }
  agb <- estoque_carbono_vegetacao$agb_tc_ha[
    padrao_busca(estoque_carbono_vegetacao$classe) == classe]
  inc <- incremento_remocao$ipcc[
    padrao_busca(incremento_remocao$classe) == classe]
  list(classe = classe, agb_tc_ha = unname(agb),
       incremento_mgc_ha_ano = unname(inc))
}

#' Emissões e remoções de novo parcelamento do solo
#'
#' Estima emissões de mudança de uso do solo e emissões anuais associadas a
#' novos domicílios, com compensações por fotovoltaica e compostagem.
#'
#' @details Modelos (Apendices V, VII e VIII): emissão única de uso do solo =
#'   área convertida (área total menos vegetação nativa e floresta plantada
#'   preservadas, com mínimo 0) x AGB da classe x 3,67; remoção anual =
#'   área preservada x incremento IPCC x 0,49 x 3,67 (equação do PDF
#'   DCG = A x G x CF); emissão veicular anual = pessoas x emissões per capita
#'   da RA / 1000; compensação fotovoltaica = domicílios equivalentes x
#'   consumo médio mensal por domicílio da RA x 12 x perc x 0,1264/1000;
#'   compensação por compostagem = resíduo domiciliar da RA x
#'   (domicílios equivalentes / domicílios da RA) x parcela de orgânicos x
#'   perc x (1,27 - 0,071). O estoque publicado por RA (Tabela 5) reproduz
#'   apenas AGB x área, sustentando o uso do AGB isolado na emissão única.
#'
#' @param ra nome da RA.
#' @param area_ha área total do parcelamento em hectares.
#' @param tipo_vegetacao opção de vegetação da área (12 opções da calculadora).
#' @param veg_nativa_ha hectares de vegetação nativa preservada.
#' @param floresta_plantada_ha hectares de floresta plantada preservada.
#' @param perc_fotovoltaico percentual de domicílios com fotovoltaica (0-100).
#' @param perc_compostagem percentual de adesão à compostagem (0-100).
#' @param tipo_info tipo da quantidade informada: "Domicílios" ou "Pessoas"
#'   (aceito com ou sem acento).
#' @param qtde_info quantidade de domicílios ou pessoas do empreendimento.
#' @param fe_energia_tco2_mwh fator de emissão da eletricidade (padrão SIN 2021).
#' @param parcela_organicos fração de resíduos orgânicos compostáveis
#'   (padrão 0,452, alimentos na coleta convencional).
#' @return lista com `ra`, `domicilios`, `pessoas`, `classe_vegetacao`,
#'   `emissao_uso_solo_tco2` (única), `remocao_vegetacao_tco2_ano`,
#'   `emissao_veicular_tco2_ano`, `compensacao_fotovoltaica_tco2_ano`,
#'   `compensacao_compostagem_tco2_ano`,
#'   `emissao_liquida_tco2_ano`.
#' @export
#' @examples
#' calc_parcelamento_solo("Ceilândia", area_ha = 100,
#'   tipo_vegetacao = "Savânica (cerrado típico)", veg_nativa_ha = 20,
#'   perc_fotovoltaico = 10, tipo_info = "Domicílios", qtde_info = 1000)
calc_parcelamento_solo <- function(ra, area_ha, tipo_vegetacao,
                                   veg_nativa_ha = 0, floresta_plantada_ha = 0,
                                   perc_fotovoltaico = 0, perc_compostagem = 0,
                                   tipo_info = c("Domicilios", "Pessoas"),
                                   qtde_info,
                                   fe_energia_tco2_mwh = 0.1264,
                                   parcela_organicos = 0.452) {
  ra_ok <- padronizar_ra(ra)
  tipo_info <- match.arg(padrao_busca(tipo_info)[1],
                         choices = c("domicilios", "pessoas"))
  p <- ra_parametros[ra_parametros$ra == ra_ok, ]
  e <- consumo_energia_ra[padrao_busca(consumo_energia_ra$ra) ==
                            padrao_busca(ra_ok), ]
  if (tipo_info == "domicilios") {
    n_domicilios <- qtde_info
    n_pessoas <- qtde_info * p$moradores_por_domicilio
  } else {
    n_pessoas <- qtde_info
    n_domicilios <- qtde_info / p$moradores_por_domicilio
  }
  classe <- map_classe_vegetacao(tipo_vegetacao)
  area_convertida <- max(area_ha - veg_nativa_ha - floresta_plantada_ha, 0)
  emissao_uso_solo <- area_convertida * classe$agb_tc_ha * 3.67
  inc_plantada <- incremento_remocao$ipcc[
    padrao_busca(incremento_remocao$grupo) == "vegetacao plantada"]
  remocao_veg <- veg_nativa_ha * classe$incremento_mgc_ha_ano * 0.49 * 3.67 +
    floresta_plantada_ha * inc_plantada * 0.49 * 3.67
  emissao_veicular <- n_pessoas * p$emissoes_kgco2_hab_ano / 1000
  comp_pv <- n_domicilios * e$consumo_medio_mensal_kwh_domicilio * 12 *
    perc_fotovoltaico / 100 * fe_energia_tco2_mwh / 1000
  r <- residuos_ra[padrao_busca(residuos_ra$ra) == padrao_busca(ra_ok), ]
  if (nrow(r) == 0) {
    warning("RA sem dados de residuos no Apendice VIII (Tabela 3): ", ra_ok,
            ". Compensacao por compostagem retorna NA.", call. = FALSE)
    comp_comp <- NA_real_
  } else {
    comp_comp <- r$residuo_domiciliar_t_ano[1] *
      (n_domicilios / p$domicilios_pdad_2021) * parcela_organicos *
      perc_compostagem / 100 * (1.27 - 0.071)
  }
  list(
    ra = ra_ok,
    domicilios = n_domicilios,
    pessoas = n_pessoas,
    classe_vegetacao = classe$classe,
    area_convertida_ha = area_convertida,
    emissao_uso_solo_tco2 = emissao_uso_solo,
    remocao_vegetacao_tco2_ano = remocao_veg,
    emissao_veicular_tco2_ano = emissao_veicular,
    compensacao_fotovoltaica_tco2_ano = comp_pv,
    compensacao_compostagem_tco2_ano = comp_comp,
    emissao_liquida_tco2_ano = emissao_veicular - remocao_veg - comp_pv -
      ifelse(is.na(comp_comp), 0, comp_comp)
  )
}

#' Emissões e remoções no combate à grilagem (desobstrução)
#'
#' Estima emissões veiculares dos novos lotes regularizados e a remoção pela
#' vegetação consolidada após a desobstrução.
#'
#' @details Modelo: nº de lotes = área (m2) / tamanho do lote; emissão veicular
#'   anual = lotes x moradores por domicílio x emissões per capita da RA /
#'   1000; remoção anual = área x incremento IPCC da classe x 0,49 x 3,67
#'   (Apendice V). O código do servidor da calculadora não é público;
#'   equação a confirmar via LAI.
#'
#' @param ra nome da RA.
#' @param tipo_vegetacao situação de vegetação pós-desobstrução (mesmas
#'   opções do módulo de parcelamento).
#' @param area_ha área desobstruída em hectares.
#' @param tam_lotes_m2 tamanho médio dos lotes em m2.
#' @return lista com `ra`, `numero_lotes`, `pessoas`,
#'   `emissao_veicular_tco2_ano`, `classe_vegetacao`,
#'   `remocao_vegetacao_tco2_ano`.
#' @export
#' @examples
#' calc_combate_grilagem("Ceilândia", "Florestal Urbana", 10, 250)
calc_combate_grilagem <- function(ra, tipo_vegetacao, area_ha, tam_lotes_m2) {
  ra_ok <- padronizar_ra(ra)
  p <- ra_parametros[ra_parametros$ra == ra_ok, ]
  if (tam_lotes_m2 <= 0) {
    stop("tam_lotes_m2 deve ser positivo.", call. = FALSE)
  }
  n_lotes <- area_ha * 10000 / tam_lotes_m2
  pessoas <- n_lotes * p$moradores_por_domicilio
  emissao <- pessoas * p$emissoes_kgco2_hab_ano / 1000
  classe <- map_classe_vegetacao(tipo_vegetacao)
  remocao <- area_ha * classe$incremento_mgc_ha_ano * 0.49 * 3.67
  list(
    ra = ra_ok,
    numero_lotes = n_lotes,
    pessoas = pessoas,
    emissao_veicular_tco2_ano = emissao,
    classe_vegetacao = classe$classe,
    remocao_vegetacao_tco2_ano = remocao
  )
}

#' Recuperação de áreas degradadas
#'
#' Compara estoque de carbono e remoção anual entre a vegetação degradada e a
#' vegetação recuperada.
#'
#' @details Modelo (Apendice V): variação única de estoque = (AGB final - AGB
#'   inicial) x 3,67 x área; variação anual de remoção = (incremento final -
#'   incremento inicial) x 0,49 x 3,67 x área. Em ambos, positivo = ganho de
#'   carbono (remoção) e negativo = perda de estoque (emissão). Classes sem
#'   dados de estoque (pastagens, agricultura, jardins) retornam `NA` com aviso.
#'
#' @param tipo_vegetacao_inicial classe de vegetação degradada.
#' @param tipo_vegetacao_final classe de vegetação após a recuperação.
#' @param area_ha área recuperada em hectares.
#' @return lista com `classe_inicial`, `classe_final`,
#'   `variacao_estoque_tco2` (única) e `variacao_remocao_tco2_ano`
#'   (positivos = remoção).
#' @export
#' @examples
#' calc_recuperacao_degradadas("Pastagem", "Savânica (cerrado típico)", 50)
calc_recuperacao_degradadas <- function(tipo_vegetacao_inicial,
                                        tipo_vegetacao_final, area_ha) {
  ini <- map_classe_vegetacao(tipo_vegetacao_inicial)
  fim <- map_classe_vegetacao(tipo_vegetacao_final)
  list(
    classe_inicial = ini$classe,
    classe_final = fim$classe,
    variacao_estoque_tco2 = (fim$agb_tc_ha - ini$agb_tc_ha) * 3.67 * area_ha,
    variacao_remocao_tco2_ano = (fim$incremento_mgc_ha_ano -
      ini$incremento_mgc_ha_ano) * 0.49 * 3.67 * area_ha
  )
}

#' Manejo de baixo carbono em solos
#'
#' Consulta o fator anual da transição de uso do solo na matriz do Apendice VI
#' e multiplica pela área.
#'
#' @details Fator (tCO2e/ha/ano; negativo = remoção) obtido por busca
#'   insensível a acento/caixa em [matriz_manejo_solo], aceitando as strings
#'   dos menus da calculadora (13 práticas iniciais, 16 atuais). A grafia
#'   "Integração lavoura-pecuária(-floresta)" é reconhecida nas práticas
#'   atuais como a variante com floresta.
#'
#' @param tipo_pratica_inicial uso do solo antes da prática (13 opções).
#' @param tipo_pratica_atual uso do solo após a prática (16 opções).
#' @param area_ha área em hectares.
#' @return lista com `uso_anterior`, `uso_atual`, `fator_tco2e_ha_ano`,
#'   `emissao_liquida_tco2e_ano` (negativo = remoção) e `referencia`.
#' @export
#' @examples
#' calc_manejo_baixo_carbono("Cultivo convencional",
#'   "Sistema agroflorestal", 100)
calc_manejo_baixo_carbono <- function(tipo_pratica_inicial,
                                      tipo_pratica_atual, area_ha) {
  chave <- function(x, lado = c("anterior", "atual")) {
    lado <- match.arg(lado)
    s <- padrao_busca(x)
    if (grepl("integracao lavoura", s)) {
      s <- if (lado == "atual" && grepl("floresta", s)) {
        "integracao lavoura pecuaria floresta"
      } else {
        "integracao lavoura pecuaria"
      }
    }
    s
  }
  m <- matriz_manejo_solo
  m$.ini <- vapply(m$uso_anterior, function(z) chave(z, "anterior"),
                   character(1))
  m$.atu <- vapply(m$uso_atual, function(z) chave(z, "atual"),
                   character(1))
  k_ini <- chave(tipo_pratica_inicial, "anterior")
  k_atu <- chave(tipo_pratica_atual, "atual")
  linha <- m[m$.ini == k_ini & m$.atu == k_atu, ]
  if (nrow(linha) == 0) {
    stop(
      "Transicao nao encontrada na matriz do Apendice VI: '",
      tipo_pratica_inicial, "' -> '", tipo_pratica_atual,
      "'. Praticas iniciais validas: ",
      paste(sort(unique(m$uso_anterior)), collapse = "; "),
      ". Praticas atuais validas: ",
      paste(sort(unique(m$uso_atual)), collapse = "; "), call. = FALSE
    )
  }
  list(
    uso_anterior = linha$uso_anterior[1],
    uso_atual = linha$uso_atual[1],
    fator_tco2e_ha_ano = linha$tco2e_ha_ano[1],
    emissao_liquida_tco2e_ano = linha$tco2e_ha_ano[1] * area_ha,
    referencia = linha$referencia[1]
  )
}
