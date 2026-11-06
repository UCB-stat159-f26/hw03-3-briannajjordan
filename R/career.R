#' Get the career matches of a tennis player
#'
#' Downloads a player's career match history from tennisabstract.com and
#' returns one row per match with the player's age, the opponent's age and
#' the age difference between them.
#'
#' @param player name of the player, e.g. `"serena williams"`,
#'   `"Serena Williams"` or `"SerenaWilliams"`
#' @param dob optional date of birth of the player (`"YYYY-MM-DD"`). By
#'   default it is looked up on the player's tennisabstract page.
#' @return a data frame with columns `player`, `date`, `tournament`,
#'   `opponent`, `result` (factor with levels `"W"` and `"L"`),
#'   `opponent_age`, `player_age` and `age_diff` (player's age minus
#'   opponent's age, in years)
#' @export
#' @examples
#' \dontrun{
#' serena <- get_career_matches("serena williams")
#' rafa <- get_career_matches("Rafael Nadal")
#' }
get_career_matches <- function(player, dob = NULL) {
  slug <- format_player_slug(player)
  matches <- parse_career_js(fetch_career_js(slug))
  if (is.null(dob)) {
    dob <- fetch_player_dob(slug, female = is_female_career(matches))
  }
  build_career_df(matches, as.Date(dob), player_name = display_name(slug))
}
