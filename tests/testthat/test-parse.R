female_js <- readLines(test_path("fixtures", "female_career.js"))
male_js <- readLines(test_path("fixtures", "male_career.js"))

test_that("parse_career_js returns one row per match", {
  female <- parse_career_js(female_js)
  male <- parse_career_js(male_js)
  expect_true(is.matrix(female))
  expect_equal(nrow(female), 3)
  expect_equal(ncol(female), 27)
  expect_equal(nrow(male), 3)
  expect_equal(female[1, 12], "Anne Miller")
  expect_equal(male[3, 5], "W")})

test_that("parse_career_js fails on content without match data", {
  expect_error(parse_career_js("var something = 1;"), "morematchmx")})

test_that("rows_to_matrix pads rows of different lengths", {
  rows <- list(c("a", "b", "c"), c("d", "e"))
  out <- rows_to_matrix(rows)
  expect_equal(dim(out), c(2, 3))
  expect_equal(out[2, 3], "")})

test_that("is_female_career tells women's and men's files apart", {
  expect_true(is_female_career(parse_career_js(female_js)))
  expect_false(is_female_career(parse_career_js(male_js)))})

test_that("age_in_years computes ages in years", {
  birth <- as.Date("2000-01-01")
  expect_equal(age_in_years(birth, as.Date("2000-01-01")), 0)
  expect_equal(age_in_years(birth, as.Date("2010-01-01")), 10, tolerance = 0.01)})

test_that("opponent ages are derived from DOB in women's files", {
  ages <- opponent_ages(parse_career_js(female_js))
  expect_equal(ages[1], 18.78, tolerance = 0.001)})

test_that("opponent ages are read directly in men's files", {
  ages <- opponent_ages(parse_career_js(male_js))
  expect_equal(ages, c(22.264202601, 24.2902121834, 18.7597535934))})

test_that("missing opponent ages become NA", {
  matches <- parse_career_js(male_js)
  matches[2, 17] <- ""
  expect_true(is.na(opponent_ages(matches)[2]))})

test_that("build_career_df returns a clean data frame", {
  df <- build_career_df(parse_career_js(female_js), as.Date("1981-09-26"),
                        player_name = "Serena Williams")
  cols <- c("player", "date", "tournament", "opponent", "result",
            "opponent_age", "player_age", "age_diff")
  expect_named(df, cols)
  expect_equal(nrow(df), 3)
  expect_equal(levels(df$result), c("W", "L"))
  expect_equal(df$player_age[1], 14.09, tolerance = 0.001)
  expect_equal(df$age_diff, df$player_age - df$opponent_age)})

test_that("build_career_df drops matches with unknown opponent age", {
  matches <- parse_career_js(male_js)
  matches[1, 17] <- ""
  df <- build_career_df(matches, as.Date("1986-06-03"))
  expect_equal(nrow(df), 2)})

test_that("build_career_df sorts matches by date", {
  matches <- parse_career_js(female_js)[3:1, ]
  df <- build_career_df(matches, as.Date("1981-09-26"))
  expect_false(is.unsorted(df$date))})
