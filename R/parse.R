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

#' Is the file from a women's (WTA) career?
#'
#' Women's files store the opponent's date of birth (YYYYMMDD) where men's
#' files store the opponent's age (a decimal number).
#' @param matches character matrix from `parse_career_js()`
#' @return logical of length 1
#' @keywords internal
is_female_career <- function(matches) {
  values <- matches[, COL_OPP_AGE]
  values <- values[!is.na(values) & values != ""]
  length(values) > 0 && all(grepl("^\\d{8}$", values))
}

#' Convert YYYYMMDD strings to Dates
#'
#' @param x character vector, e.g. "19810926"
#' @return Date vector
#' @keywords internal
as_ymd <- function(x) {
  as.Date(x, format = "%Y%m%d")
}

#' Age in years of someone born on `birth` at date `on`
#'
#' @param birth,on Date vectors
#' @return numeric vector of ages in years
#' @keywords internal
age_in_years <- function(birth, on) {
  as.numeric(difftime(on, birth, units = "days")) / 365.25
}

#' Opponent's age at each match
#'
#' @param matches character matrix from `parse_career_js()`
#' @return numeric vector (NA when unknown)
#' @keywords internal
opponent_ages <- function(matches) {
  raw <- matches[, COL_OPP_AGE]
  raw[raw == ""] <- NA
  if (is_female_career(matches)) {
    return(age_in_years(as_ymd(raw), as_ymd(matches[, COL_DATE])))
  }
  suppressWarnings(as.numeric(raw))
}

#' Basic match information (no player ages yet)
#'
#' @param matches character matrix from `parse_career_js()`
#' @return data frame with date, tournament, opponent, result, opponent_age
#' @keywords internal
match_table <- function(matches) {
  data.frame(
    date = as_ymd(matches[, COL_DATE]),
    tournament = matches[, COL_TOURNAMENT],
    opponent = matches[, COL_OPPONENT],
    result = factor(matches[, COL_RESULT], levels = c("W", "L")),
    opponent_age = opponent_ages(matches)
  )
}

#' Build the clean data frame used for plotting
#'
#' @param matches character matrix from `parse_career_js()`
#' @param player_dob Date with the player's date of birth
#' @param player_name name of the player (used for plot titles)
#' @return data frame with one row per match where both ages are known
#' @keywords internal
build_career_df <- function(matches, player_dob, player_name = NA) {
  df <- cbind(player = player_name, match_table(matches))
  df$player_age <- age_in_years(player_dob, df$date)
  df$age_diff <- df$player_age - df$opponent_age
  df <- df[stats::complete.cases(df[, c("result", "age_diff")]), ]
  df <- df[order(df$date), ]
  rownames(df) <- NULL
  df
}
