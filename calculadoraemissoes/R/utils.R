#' Padroniza nomes de Regiões Administrativas (RA) do DF
#'
#' Converte variações de escrita (maiúsculas/minúsculas, acentos, "RA IX",
#' barras e espaços extras) no nome canônico da RA usado nos dados do pacote.
#' A busca é insensível a acento e caixa.
#'
#' @param x vetor de caracteres com nomes de RA (ex.: "ceilandia", "RA IX",
#'   "Sol Nascente/Pôr do Sol").
#' @return vetor de caracteres com os nomes canônicos das RAs
#'   (coluna `ra` de [ra_parametros]).
#' @export
#' @examples
#' padronizar_ra(c("ceilandia", "RA IX", "Plano Piloto"))
padronizar_ra <- function(x) {
  n <- nrow(ra_parametros)
  chaves <- padrao_busca(c(ra_parametros$ra, ra_parametros$ra_id))
  alvo <- padrao_busca(x)
  pos <- match(alvo, chaves)
  idx <- ifelse(pos > n, pos - n, pos)
  falha <- is.na(alvo) | alvo == ""
  if (any(is.na(idx) & !falha)) {
    opcoes <- paste0(ra_parametros$ra_id, " = ", ra_parametros$ra, collapse = "; ")
    stop(
      "RA nao encontrada: ",
      paste(x[is.na(idx) & !falha], collapse = ", "),
      ". Opcoes validas: ", opcoes,
      call. = FALSE
    )
  }
  ra_parametros$ra[idx]
}

#' Converte números no padrão brasileiro para numérico
#'
#' Interpreta textos com vírgula decimal e ponto como separador de milhar
#' (padrão usado nas notas metodológicas do IPEDF e nos formulários da
#' calculadora). Valores numéricos são retornados sem alteração; textos
#' vazios ou não numéricos viram `NA`.
#'
#' @param x vetor de caracteres ou numérico (ex.: "1.234,56", "0,5", 42).
#' @return vetor numérico.
#' @export
#' @examples
#' numero_br(c("1.234,56", "0,5", "1.045.611.307", "", 42))
numero_br <- function(x) {
  if (is.numeric(x)) {
    return(x)
  }
  out <- gsub("\\s", "", as.character(x))
  tem_virgula <- grepl(",", out, fixed = TRUE)
  out[tem_virgula] <- gsub("\\.", "", out[tem_virgula], fixed = FALSE)
  out[tem_virgula] <- sub(",", ".", out[tem_virgula], fixed = TRUE)
  so_milhar <- !tem_virgula & grepl("^-?[0-9]{1,3}(\\.[0-9]{3})+$", out)
  out[so_milhar] <- gsub("\\.", "", out[so_milhar])
  out[out == ""] <- NA_character_
  suppressWarnings(as.numeric(out))
}

sem_acento <- function(x) {
  acentos <- c("\u00e1","\u00e0","\u00e2","\u00e3","\u00e4",
               "\u00e9","\u00e8","\u00ea","\u00eb",
               "\u00ed","\u00ec","\u00ee","\u00ef",
               "\u00f3","\u00f2","\u00f4","\u00f5","\u00f6",
               "\u00fa","\u00f9","\u00fb","\u00fc",
               "\u00e7")
  sem <- c("a","a","a","a","a",
           "e","e","e","e",
           "i","i","i","i",
           "o","o","o","o","o",
           "u","u","u","u",
           "c")
  x <- tolower(as.character(x))
  for (i in seq_along(acentos)) {
    x <- gsub(acentos[i], sem[i], x, fixed = TRUE)
  }
  x
}

padrao_busca <- function(x) {
  x <- sem_acento(x)
  x <- gsub("[^a-z0-9]+", " ", x)
  trimws(gsub("\\s+", " ", x))
}
