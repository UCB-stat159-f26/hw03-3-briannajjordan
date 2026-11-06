# HW 3 R Package for Tennis Career Plots

Brianna Jordan, STAT 159, Fall 2026

For this HW I turned my HW 2 code into an R package, `tennisages`, that works for any player on Tennis Abstract, not just Serena. It has two functions: one gets a player's career data, and one makes a plot like the NYT graphic from "Serena Williams Dominated Her Generation, Then the Next One, Too" (2022), without annotations.

## Installation

``` r
devtools::install_github("UCB-stat159-f26/hw03-3-briannajjordan")
```

## How to use it

``` r
library(tennisages)

serena <- get_career_matches("serena williams")
plot_career_ages(serena)

rafa <- get_career_matches("Rafael Nadal")
plot_career_ages(rafa)

# returns an error message because "Gaston Sanchez" is not in the data frame
unknown_player <- get_career_matches("GastonSanchez")
```

`get_career_matches()` takes a player's name, written as "serena williams", "Serena Williams" or "SerenaWilliams", and returns a data frame with one row per match. If the player isn't on Tennis Abstract, it gives an error telling you to check the spelling.

`plot_career_ages()` takes that data frame and makes a scatter plot with the player's age on the x-axis, the difference between the player's age and the opponent's age on the y-axis, and wins and losses in different colors.

Both have help pages (`?get_career_matches` and `?plot_career_ages`).

## Data

The data comes from each player's career file on Tennis Abstract, e.g. <https://www.tennisabstract.com/jsmatches/SerenaWilliamsCareer.js>. The player's own birthday comes from their Tennis Abstract player page.

The data frame has one row per match, with the player's name, the date, tournament, opponent, result (W/L), the opponent's age, the player's age, and the age difference (player's age minus opponent's age).

Women's and men's files are different. Women's files have each opponent's birthday, so I calculate the opponent's age from it. Men's files already have the opponent's age. Matches without an opponent age are dropped.

Some files aren't fully up to date as Rafael Nadal's ends in October 2016, so his plot stops around age 30.

## Structure

```         
├── DESCRIPTION        package info and dependencies
├── NAMESPACE          made by devtools::document()
├── LICENSE            MIT license
├── devtools-flow.R    cheat sheet of the devtools workflow
├── R/
│   ├── parse.R        reads and cleans the career files
│   ├── fetch.R        formats names and downloads from Tennis Abstract
│   └── career.R       the two main functions
├── man/               help files made by devtools::document()
└── tests/
    └── testthat/
        ├── fixtures/  mock female and male files from the assignment
        ├── test-parse.R
        ├── test-fetch.R
        └── test-career.R
```

## Tests

The tests don't contact Tennis Abstract, instead, they check the functions that clean the career files, using the mock female and male files from the assignment. Run them with `devtools::test()`.

## Reflections

Going into this, I thought turning my HW 2 code into a package would mostly mean moving it into functions. The harder part was making it work for players other than Serena. My parser passed on the mock data from the assignment, but when I ran it on the real Serena file I got a table with only one column, because the real match rows don’t all have the same number of fields. That showed me how clean test data can hide problems that only show up with real data. I also didn’t expect the men’s and women’s files to store the opponent’s age differently, so the code had to figure out which kind of file it was reading. When I plotted Rafael Nadal, his points stopped at age 30, and after digging into Tennis Abstract I found that his file just ends in 2016. I’m glad I checked the plot instead of assuming it was right. I also learned how much devtools and usethis handle for you, like writing the documentation and NAMESPACE and checking the whole package. The 20-line limit felt annoying at first, but splitting things into small functions made the code a lot easier to test, especially since I could test all of the cleaning code without ever hitting the website!
