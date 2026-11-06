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

#' Plot a player's age against the age gap with their opponents
#'
#' Scatter plot in the style of the New York Times graphic on Serena
#' Williams: each point is a match, the x-axis is the player's age, the
#' y-axis is the player's age minus the opponent's age, and points are
#' colored by whether the player won or lost.
#'
#' @param career_df data frame returned by [get_career_matches()]
#' @return a ggplot object
#' @importFrom ggplot2 .data
#' @export
#' @examples
#' \dontrun{
#' serena <- get_career_matches("serena williams")
#' plot_career_ages(serena)
#' }
plot_career_ages <- function(career_df) {
  check_career_df(career_df)
  ggplot2::ggplot(career_df, ggplot2::aes(x = .data$player_age,
                                          y = .data$age_diff, color = .data$result)) +
    ggplot2::geom_hline(yintercept = 0, color = "gray50") +
    ggplot2::geom_point(alpha = 0.6, size = 1.5) +
    ggplot2::scale_color_manual(values = c(W = "#2b8a3e", L = "#c92a2a"),
                                labels = c(W = "Won", L = "Lost"), name = NULL, drop = FALSE) +
    ggplot2::labs(
      title = plot_title(career_df),
      x = "Player's age",
      y = "Age difference with opponent (years)"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "top")
}

#' Check that the input has the columns needed for plotting
#'
#' @param career_df data frame to check
#' @return invisibly TRUE, or an error
#' @keywords internal
check_career_df <- function(career_df) {
  needed <- c("player_age", "age_diff", "result")
  if (!is.data.frame(career_df) || !all(needed %in% names(career_df))) {
    stop("`career_df` must be the output of get_career_matches().",
         call. = FALSE)
  }
  invisible(TRUE)
}

#' Title for the plot
#'
#' @param career_df data frame returned by get_career_matches()
#' @return character
#' @keywords internal
plot_title <- function(career_df) {
  name <- career_df$player[1]
  if (is.null(name) || is.na(name)) return("Age gap with opponents")
  paste0(name, ": age gap with opponents")
}
