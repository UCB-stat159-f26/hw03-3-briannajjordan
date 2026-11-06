female_js <- readLines(test_path("fixtures", "female_career.js"))

test_that("get_career_matches rejects invalid input before downloading", {
  expect_error(get_career_matches(42), "single name")})

test_that("plot_career_ages returns a ggplot with the right labels", {
  df <- build_career_df(parse_career_js(female_js), as.Date("1981-09-26"),
                        player_name = "Serena Williams")
  p <- plot_career_ages(df)
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Player's age")
  expect_match(p$labels$title, "Serena Williams")})

test_that("plot_career_ages rejects data frames with missing columns", {
  expect_error(plot_career_ages(data.frame(x = 1)), "get_career_matches")})
