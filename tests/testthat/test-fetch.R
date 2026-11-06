test_that("format_player_slug accepts the three name formats", {
  expect_equal(format_player_slug("serena williams"), "SerenaWilliams")
  expect_equal(format_player_slug("Serena Williams"), "SerenaWilliams")
  expect_equal(format_player_slug("SerenaWilliams"), "SerenaWilliams")
  expect_equal(format_player_slug("  rafael   nadal "), "RafaelNadal")
  expect_equal(format_player_slug("jo-wilfried tsonga"), "JoWilfriedTsonga")})

test_that("format_player_slug rejects invalid input", {
  expect_error(format_player_slug(""), "single name")
  expect_error(format_player_slug(NA_character_), "single name")
  expect_error(format_player_slug(123), "single name")
  expect_error(format_player_slug(c("a", "b")), "single name")})

test_that("display_name splits a slug into words", {
  expect_equal(display_name("SerenaWilliams"), "Serena Williams")})

test_that("extract_dob finds the date of birth in a player page", {
  page <- readLines(test_path("fixtures", "player_page.html"))
  expect_equal(extract_dob(page), as.Date("1981-09-26"))})

test_that("extract_dob returns NA when there is no date of birth", {
  expect_true(is.na(extract_dob("<html>no data here</html>")))
  expect_true(is.na(extract_dob(NULL)))})
