context("Authorization")
library(RAhrefs)
library(testthat)

# defensive ----------------------------------------------------------------------
test_that("api_key param doesn't accept wrong values", {
  expect_error(rah_auth(api_key = "", verbose = TRUE))
  expect_error(rah_auth(api_key = NA, verbose = TRUE))
  expect_error(rah_auth(api_key = NULL, verbose = TRUE))
  expect_error(rah_auth(api_key = "stupid things", verbose = TRUE), regexp = "Authorization error: HTTP status code")
  expect_error(rah_auth(api_key = TRUE, verbose = TRUE))
  expect_error(rah_auth(api_key = FALSE, verbose = TRUE))
  expect_error(rah_auth(api_key = "", verbose = FALSE))
  expect_error(rah_auth(api_key = NA, verbose = FALSE))
  expect_error(rah_auth(api_key = NULL, verbose = FALSE))
  expect_error(rah_auth(api_key = "stupid things", verbose = FALSE), regexp = "Authorization error: HTTP status code")
  expect_error(rah_auth(api_key = TRUE, verbose = FALSE))
  expect_error(rah_auth(api_key = FALSE, verbose = FALSE))
})

# cancelled -------------------------------------------------------------------
# can't provide the commercial API key in such a place, must resign from testing this
# test_that("proper api_key returns messages properly", {
#   expect_message(rah_auth(api_key = Sys.getenv("AHREFS_AUTH_TOKEN"), verbose = TRUE), regexp = "API authorized.")
#   expect_silent(rah_auth(api_key = Sys.getenv("AHREFS_AUTH_TOKEN"), verbose = FALSE))
# })
