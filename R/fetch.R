BASE_URL <- "https://www.tennisabstract.com/"

#' Check that the player name is a single non-empty string
#'
#' @param player input given by the user
#' @return invisibly TRUE, or an error
#' @keywords internal
check_player_name <- function(player) {
  ok <- is.character(player) && length(player) == 1 &&
    !is.na(player) && nzchar(trimws(player))
  if (!ok) {
    stop("`player` must be a single name, e.g. \"Serena Williams\".",
         call. = FALSE)
  }
  invisible(TRUE)
}

#' Convert a player's name to the tennisabstract format
#'
#' "serena williams", "Serena Williams" and "SerenaWilliams" all become
#' "SerenaWilliams".
#' @param player name of the player
#' @return character, name in tennisabstract format
#' @keywords internal
format_player_slug <- function(player) {
  check_player_name(player)
  words <- strsplit(trimws(player), "[[:space:]-]+")[[1]]
  words <- paste0(toupper(substring(words, 1, 1)), substring(words, 2))
  gsub("[^A-Za-z]", "", paste(words, collapse = ""))
}

#' Turn "SerenaWilliams" back into "Serena Williams"
#'
#' @param slug name in tennisabstract format
#' @return character
#' @keywords internal
display_name <- function(slug) {
  gsub("([a-z])([A-Z])", "\\1 \\2", slug)
}

#' Read the lines of a web page, returning NULL if it cannot be read
#'
#' @param url address of the page
#' @return character vector, or NULL
#' @keywords internal
read_url_lines <- function(url) {
  tryCatch(
    suppressWarnings(readLines(url, warn = FALSE, encoding = "UTF-8")),
    error = function(e) NULL
  )
}

#' Download the Career JS file of a player
#'
#' @param slug name in tennisabstract format, e.g. "SerenaWilliams"
#' @return character vector with the lines of the JS file
#' @keywords internal
fetch_career_js <- function(slug) {
  js <- read_url_lines(paste0(BASE_URL, "jsmatches/", slug, "Career.js"))
  if (is.null(js)) {
    stop(sprintf(paste0("No career data found for player '%s' on ",
                        "tennisabstract.com. Check the spelling (e.g. \"Serena Williams\") ",
                        "and your internet connection."), display_name(slug)), call. = FALSE)
  }
  js
}

#' Find the player's date of birth in a tennisabstract player page
#'
#' Player pages define a JavaScript variable like `var dob = 19810926;`
#' @param html_lines character vector with the lines of the page
#' @return Date, or NA if not found
#' @keywords internal
extract_dob <- function(html_lines) {
  pattern <- "var\\s+dob\\s*=\\s*['\"]?(\\d{8})"
  hit <- regmatches(html_lines, regexpr(pattern, html_lines, perl = TRUE))
  if (length(hit) == 0) return(as.Date(NA))
  as_ymd(sub(pattern, "\\1", hit[1], perl = TRUE))
}

#' Download the player's date of birth
#'
#' @param slug name in tennisabstract format
#' @param female whether the player is on the women's tour
#' @return Date
#' @keywords internal
fetch_player_dob <- function(slug, female) {
  page <- if (female) "cgi-bin/wplayer.cgi?p=" else "cgi-bin/player.cgi?p="
  dob <- extract_dob(read_url_lines(paste0(BASE_URL, page, slug)))
  if (is.na(dob)) {
    stop(sprintf(paste0("Could not find the date of birth of '%s'. ",
                        "Supply it with the `dob` argument, e.g. dob = \"1981-09-26\"."),
                 display_name(slug)), call. = FALSE)
  }
  dob
}
