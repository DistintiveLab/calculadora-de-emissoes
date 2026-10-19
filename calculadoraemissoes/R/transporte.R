#' Identifica tipo de veículo e combustível a partir de texto livre
#'
#' Aceita as strings dos menus da calculadora (ex.: "CONVENCIONAL a diesel",
#' "PADRON B100") e variações, retornando as chaves de [fe_onibus].
#'
#' @param x texto com tipo de ônibus e combustível.
#' @return vetor de caracteres de comprimento 2: tipo de veículo e combustível
#'   (chaves sem acento de `fe_onibus`).
#' @keywords internal
parse_veiculo_onibus <- function(x) {
  s <- padrao_busca(x)
  if (!any(grepl("articul|padron|convencional|basic", s))) {
    stop("Tipo de veiculo nao reconhecido: ", x,
         ". Use CONVENCIONAL/PADRON/ARTICULADO com diesel ou B100.",
         call. = FALSE)
  }
  veiculo <- ifelse(grepl("articul", s), "Articulado", "Padron (basico)")
  combustivel <- ifelse(grepl("b ?100|biodiesel", s), "Biodiesel B100",
                        "Diesel B12")
  c(veiculo = veiculo, combustivel = combustivel)
}

#' Consulta fator de emissão de ônibus (gCO2e/km)
#'
#' Busca em [fe_onibus] por veículo, operação e combustível (comparação
#' insensível a acento e caixa).
#'
#' @param veiculo "Padron (basico)" ou "Articulado".
#' @param operacao "Transito comum", "Faixa exclusiva" ou "BRT".
#' @param combustivel "Diesel B12" ou "Biodiesel B100".
#' @return numeric, gCO2e/km.
#' @keywords internal
fe_onibus_buscar <- function(veiculo, operacao, combustivel) {
  m <- padrao_busca(fe_onibus$veiculo) %in% padrao_busca(veiculo) &
    padrao_busca(fe_onibus$operacao) %in% padrao_busca(operacao) &
    padrao_busca(fe_onibus$combustivel) %in% padrao_busca(combustivel)
  if (!any(m)) {
    stop("Combinacao nao encontrada em fe_onibus: ", veiculo, " / ",
         operacao, " / ", combustivel, call. = FALSE)
  }
  fe_onibus$fe_veiculo_gco2e_km[m]
}

#' Emissões evitadas com implantação de ciclovia e calçada
#'
#' Estima as emissões veiculares de referência associadas aos domicílios
#' atendidos, assumindo deslocamento integral por transporte ativo no cenário.
#'
#' @details Modelo (Apendice I, exemplo da Tabela 6): emissões = domicílios x
#'   moradores por domicílio (Tabela 3) x emissões per capita da RA
#'   (`emissoes_kgco2_hab_ano`, Tabela 7) / 1000. O PDF usa 2,96
#'   moradores/domicílio na Ceilândia (valor não arredondado da PDAD); este
#'   pacote usa 3,0 da Tabela 3 (diferença ~1,3%).
#'
#' @param ra nome da RA de origem (aceita variações; ver [padronizar_ra]).
#' @param qtde_domicilios quantidade de domicílios atendidos pela infraestrutura.
#' @return lista com `ra`, `domicilios`, `moradores_por_domicilio`,
#'   `pessoas_atendidas`, `emissao_referencia_tco2_ano`,
#'   `emissao_cenario_tco2_ano` e `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_ciclovia("Ceilândia", 1000)
calc_ciclovia <- function(ra, qtde_domicilios) {
  ra_ok <- padronizar_ra(ra)
  p <- ra_parametros[ra_parametros$ra == ra_ok, ]
  pessoas <- qtde_domicilios * p$moradores_por_domicilio
  emissao <- pessoas * p$emissoes_kgco2_hab_ano / 1000
  list(
    ra = ra_ok,
    domicilios = qtde_domicilios,
    moradores_por_domicilio = p$moradores_por_domicilio,
    pessoas_atendidas = pessoas,
    emissao_referencia_tco2_ano = emissao,
    emissao_cenario_tco2_ano = 0,
    emissoes_evitadas_tco2_ano = emissao
  )
}

#' Emissões evitadas com faixa exclusiva de ônibus
#'
#' Compara ônibus circulando em trânsito comum versus em faixa exclusiva.
#'
#' @details Modelo: km/ano = extensao x viagens semanais x 52. Emissões =
#'   fator de emissão do ônibus ([fe_onibus]; operação "Trânsito comum" no
#'   cenário de referência e "Faixa exclusiva" no proposto) x km/ano / 1e6.
#'   A velocidade corrigida da faixa exclusiva (39,69 km/h, derivada da curva
#'   C = 3,7072 x V^(-0,629) com velocidade BRT de 51,6 km/h) já está embutida
#'   nos fatores do Quadro 1 do Apendice III. CONVENCIONAL é tratado como
#'   Padron (básico).
#'
#' @param extensao_km extensão da faixa exclusiva em km.
#' @param viagens_semanais número de viagens semanais na faixa.
#' @param tipo_veiculo_atual tipo/combustível no cenário atual (ex.:
#'   "CONVENCIONAL diesel", "PADRON B100", "ARTICULADO diesel").
#' @param tipo_veiculo_proposto tipo/combustível no cenário com faixa exclusiva.
#' @param semanas_ano fator de expansão semanal (padrão 52).
#' @return lista com `km_ano`, `fe_atual_gco2e_km`, `fe_proposto_gco2e_km`,
#'   `emissao_referencia_tco2_ano`, `emissao_cenario_tco2_ano`,
#'   `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_faixa_exclusiva(10, 500, "PADRON diesel", "PADRON diesel")
calc_faixa_exclusiva <- function(extensao_km, viagens_semanais,
                                 tipo_veiculo_atual, tipo_veiculo_proposto,
                                 semanas_ano = 52) {
  atual <- parse_veiculo_onibus(tipo_veiculo_atual)
  proposto <- parse_veiculo_onibus(tipo_veiculo_proposto)
  fe_atual <- fe_onibus_buscar(atual["veiculo"], "Transito comum",
                               atual["combustivel"])
  fe_prop <- fe_onibus_buscar(proposto["veiculo"], "Faixa exclusiva",
                              proposto["combustivel"])
  km_ano <- extensao_km * viagens_semanais * semanas_ano
  ref <- fe_atual * km_ano / 1e6
  cen <- fe_prop * km_ano / 1e6
  list(
    km_ano = km_ano,
    fe_atual_gco2e_km = unname(fe_atual),
    fe_proposto_gco2e_km = unname(fe_prop),
    emissao_referencia_tco2_ano = ref,
    emissao_cenario_tco2_ano = cen,
    emissoes_evitadas_tco2_ano = ref - cen
  )
}

#' Emissões evitadas com deslocamento para BRT
#'
#' Compara o fator de emissão do veículo atual com o fator médio dos ônibus
#' BRT, ponderado pela proporção entre dois tipos de veículo.
#'
#' @details Modelo: km_evitados = distancia_antes x reducao_pct/100;
#'   emissões evitadas = km_evitados x (FE_atual - FE_BRT_ponderado) / 1e6.
#'   Veículo atual aceita automóvel (133,4 gCO2e/km, média da frota do Apendice
#'   II), motocicleta (41,7 gCO2e/km) ou ônibus em trânsito comum (Quadro 1 do
#'   Apendice III). Valores negativos indicam aumento de emissões.
#'
#' @param distancia_antes_km_ano distância anual percorrida antes do BRT (km/ano).
#' @param reducao_km_pct redução percentual de km com o BRT (0-100).
#' @param tipo_veiculo_atual veículo atual: "Automóvel", "Motocicleta" ou
#'   ônibus (ex.: "PADRON diesel", "ARTICULADO B100").
#' @param tipo_veiculo_brt1 primeiro tipo de ônibus BRT.
#' @param tipo_veiculo_brt2 segundo tipo de ônibus BRT (opcional).
#' @param prop_tipo_brt1 percentual do tipo 1 (0-100; padrão 100).
#' @return lista com `km_evitados_ano`, `fe_atual_gco2e_km`,
#'   `fe_brt_ponderado_gco2e_km`, `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_brt(10000, 30, "Automóvel", "ARTICULADO B100")
calc_brt <- function(distancia_antes_km_ano, reducao_km_pct, tipo_veiculo_atual,
                     tipo_veiculo_brt1, tipo_veiculo_brt2 = NULL,
                     prop_tipo_brt1 = 100) {
  s_atual <- padrao_busca(tipo_veiculo_atual)
  frota <- fe_veiculos_leves[padrao_busca(fe_veiculos_leves$combustivel) ==
                               "media frota", ]
  if (grepl("automov|carro", s_atual)) {
    fe_atual <- frota$fe_gco2e_por_km[padrao_busca(frota$classe) == "carros"]
  } else if (grepl("moto", s_atual)) {
    fe_atual <- frota$fe_gco2e_por_km[padrao_busca(frota$classe) ==
                                        "motocicleta"]
  } else {
    tipo <- parse_veiculo_onibus(tipo_veiculo_atual)
    fe_atual <- fe_onibus_buscar(tipo["veiculo"], "Transito comum",
                                 tipo["combustivel"])
  }
  brt1 <- parse_veiculo_onibus(tipo_veiculo_brt1)
  fe_brt1 <- fe_onibus_buscar(brt1["veiculo"], "BRT", brt1["combustivel"])
  fe_brt2 <- NULL
  if (!is.null(tipo_veiculo_brt2) && !is.na(tipo_veiculo_brt2) &&
      padrao_busca(tipo_veiculo_brt2) != "") {
    brt2 <- parse_veiculo_onibus(tipo_veiculo_brt2)
    fe_brt2 <- fe_onibus_buscar(brt2["veiculo"], "BRT", brt2["combustivel"])
  }
  p1 <- prop_tipo_brt1 / 100
  if (p1 < 0 || p1 > 1) {
    stop("prop_tipo_brt1 deve estar entre 0 e 100.", call. = FALSE)
  }
  fe_brt <- if (is.null(fe_brt2)) {
    unname(fe_brt1)
  } else {
    unname(p1 * fe_brt1 + (1 - p1) * fe_brt2)
  }
  km_evitados <- distancia_antes_km_ano * reducao_km_pct / 100
  list(
    km_evitados_ano = km_evitados,
    fe_atual_gco2e_km = unname(fe_atual),
    fe_brt_ponderado_gco2e_km = fe_brt,
    emissoes_evitadas_tco2_ano = km_evitados * (unname(fe_atual) - fe_brt) / 1e6
  )
}

#' Emissões induzidas por ampliação de obras viárias
#'
#' Estima emissões do tráfego induzido pela ampliação de faixas.
#'
#' @details Modelo (Apendice IV): crescimento de VKT = (faixas_ampliacao /
#'   faixas_atual - 1) x vkv_induzido, com elasticidade ~1 (Chen et al., 2020).
#'   Emissões = soma por classe de qtd x FE (gCO2e/km) x km x 365 x
#'   crescimento / 1e6. Classes de porte: pequeno = motocicleta (41,7);
#'   médio = automóvel (133,4); longo = caminhão/ônibus, média dos fatores de
#'   trânsito comum (1280,5 e 1746,1) = 1513,3 gCO2e/km (Apendices II/III).
#'
#' @param faixas_atual número atual de faixas.
#' @param faixas_ampliacao número de faixas após a ampliação.
#' @param km_ampliacao extensão ampliada em km.
#' @param qtd_pequeno_porte quantidade de veículos de pequeno porte (motocicletas).
#' @param qtd_medio_porte quantidade de veículos de médio porte (automóveis).
#' @param qtd_longo_porte quantidade de veículos de longo porte (caminhões/ônibus).
#' @param vkv_induzido fator de tráfego induzido (padrão 1, editável na calculadora).
#' @param dias_ano dias de operação por ano (padrão 365).
#' @return lista com `crescimento_vkt`, `vkt_induzido_classe`,
#'   `fe_classe_gco2e_km`, `emissao_pequeno_tco2_ano`,
#'   `emissao_medio_tco2_ano`, `emissao_longo_tco2_ano` e
#'   `emissao_induzida_tco2_ano`.
#' @export
#' @examples
#' calc_obras_viarias(2, 4, 5, qtd_medio_porte = 1000)
calc_obras_viarias <- function(faixas_atual, faixas_ampliacao, km_ampliacao,
                               qtd_pequeno_porte = 0, qtd_medio_porte = 0,
                               qtd_longo_porte = 0, vkv_induzido = 1,
                               dias_ano = 365) {
  if (faixas_atual <= 0) {
    stop("faixas_atual deve ser positivo.", call. = FALSE)
  }
  onibus_tc <- fe_onibus[padrao_busca(fe_onibus$operacao) == "transito comum" &
                           padrao_busca(fe_onibus$combustivel) == "diesel b12", ]
  fe_longo <- mean(onibus_tc$fe_veiculo_gco2e_km)
  crescimento <- (faixas_ampliacao / faixas_atual - 1) * vkv_induzido
  fe_classe <- c(pequeno = 41.7, medio = 133.4, longo = fe_longo)
  qtd <- c(pequeno = qtd_pequeno_porte, medio = qtd_medio_porte,
           longo = qtd_longo_porte)
  vkt_induzido <- crescimento * km_ampliacao * dias_ano
  emissao_classe <- qtd * fe_classe * vkt_induzido / 1e6
  list(
    crescimento_vkt = crescimento,
    vkt_induzido_classe = vkt_induzido,
    fe_classe_gco2e_km = fe_classe,
    emissao_pequeno_tco2_ano = unname(emissao_classe["pequeno"]),
    emissao_medio_tco2_ano = unname(emissao_classe["medio"]),
    emissao_longo_tco2_ano = unname(emissao_classe["longo"]),
    emissao_induzida_tco2_ano = sum(emissao_classe)
  )
}

#' Emissões evitadas com expansão do metrô
#'
#' Estima emissões veiculares evitadas para domicílios atendidos pela expansão.
#'
#' @details Mesma equação do módulo de ciclovia (domicílios x moradores x
#'   emissões per capita da RA / 1000), multiplicada por `prop_mudanca_modal`.
#'   A calculadora original restringe o módulo às 8 RAs atendidas pela Linha
#'   Verde/Laranja: Águas Claras, Arniqueira, Ceilândia, Guará, Plano Piloto,
#'   Samambaia, Sol Nascente/Pôr do Sol e Taguatinga. A extensão informada é
#'   registrada no resultado, mas não altera a estimativa (o código do servidor
#'   da calculadora não é público; equação a confirmar via LAI).
#'
#' @param ra nome da RA de origem (uma das 8 RAs atendidas).
#' @param extensao_metro extensão da linha em km (informativo).
#' @param qtde_domicilios quantidade de domicílios atendidos.
#' @param prop_mudanca_modal proporção de mudança modal (0-1; padrão 1).
#' @return lista com `ra`, `extensao_metro_km`, `domicilios`,
#'   `pessoas_atendidas`, `emissao_referencia_tco2_ano`,
#'   `emissao_cenario_tco2_ano`, `emissoes_evitadas_tco2_ano`.
#' @export
#' @examples
#' calc_metro("Taguatinga", 5, 1000)
calc_metro <- function(ra, extensao_metro, qtde_domicilios,
                       prop_mudanca_modal = 1) {
  ra_ok <- padronizar_ra(ra)
  ras_metro <- c("aguas claras", "arniqueira", "ceilandia", "guara",
                 "plano piloto", "samambaia", "sol nascente por do sol",
                 "taguatinga")
  if (!(padrao_busca(ra_ok) %in% ras_metro)) {
    stop("Modulo disponivel apenas para as RAs atendidas pelo metro: ",
         paste(ras_metro, collapse = ", "), call. = FALSE)
  }
  p <- ra_parametros[ra_parametros$ra == ra_ok, ]
  pessoas <- qtde_domicilios * p$moradores_por_domicilio
  ref <- pessoas * p$emissoes_kgco2_hab_ano / 1000
  cen <- ref * (1 - prop_mudanca_modal)
  list(
    ra = ra_ok,
    extensao_metro_km = extensao_metro,
    domicilios = qtde_domicilios,
    pessoas_atendidas = pessoas,
    emissao_referencia_tco2_ano = ref,
    emissao_cenario_tco2_ano = cen,
    emissoes_evitadas_tco2_ano = ref - cen
  )
}
