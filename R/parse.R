COL_DATE <- 1
COL_TOURNAMENT <- 2
COL_RESULT <- 5
COL_OPPONENT <- 12
COL_OPP_AGE <- 17

#' Stack match records of different lengths into a matrix
#'
#' Rows in real Career JS files can have different numbers of fields, so
#' shorter rows are padded with empty strings.
#' @param rows list of character vectors (or a matrix) from `fromJSON()`
#' @return character matrix, one row per match
#' @keywords internal
rows_to_matrix <- function(rows) {
  if (is.matrix(rows)) return(rows)
  width <- max(lengths(rows))
  pad <- function(row) c(as.character(row), rep("", width - length(row)))
  do.call(rbind, lapply(rows, pad))
}

#' Extract the match records from a Career JS file
#'
#' @param js_text character vector with the lines of a Career JS file
#' @return character matrix, one row per match
#' @keywords internal
parse_career_js <- function(js_text) {
  js <- paste(js_text, collapse = "\n")
  pattern <- "(?s).*morematchmx\\s*=\\s*(\\[.*\\])\\s*;?.*"
  if (!grepl(pattern, js, perl = TRUE)) {
    stop("Could not find match data (morematchmx) in the JS content.")
  }
  matches <- jsonlite::fromJSON(sub(pattern, "\\1", js, perl = TRUE))
  rows_to_matrix(matches)
}
