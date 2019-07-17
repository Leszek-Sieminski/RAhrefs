context("Authorization")
library(RAhrefs)
library(testthat)

# defensive ----------------------------------------------------------------------
test_that("api_key param doesn't accept wrong values", {
  expect_error(rah_auth(api_key = "", verbose = TRUE))
  expect_error(rah_auth(api_key = NA, verbose = TRUE))
  expect_error(rah_auth(api_key = NULL, verbose = TRUE))
  expect_error(rah_auth(api_key = "stupid things", verbose = TRUE))
  expect_error(rah_auth(api_key = TRUE, verbose = TRUE))
  expect_error(rah_auth(api_key = FALSE, verbose = TRUE))
  expect_error(rah_auth(api_key = "", verbose = FALSE))
  expect_error(rah_auth(api_key = NA, verbose = FALSE))
  expect_error(rah_auth(api_key = NULL, verbose = FALSE))
  expect_error(rah_auth(api_key = "stupid things", verbose = FALSE))
  expect_error(rah_auth(api_key = TRUE, verbose = FALSE))
  expect_error(rah_auth(api_key = FALSE, verbose = FALSE))
})

test_that("proper api_key returns messages properly", {
  expect_message(rah_auth(api_key = Sys.getenv("AHREFS_AUTH_TOKEN"), verbose = TRUE), regexp = "API authorized.")
  expect_silent(rah_auth(api_key = Sys.getenv("AHREFS_AUTH_TOKEN"), verbose = FALSE))
})

# # api_key = NA
# #
# x <- httr::GET(url = 'https://apiv2.ahrefs.com/',
#                httr::add_headers(token = Sys.getenv("AHREFS_AUTH_TOKEN")))  #"bullshit"))
# x$status_code
# y <- jsonlite::fromJSON(httr::content(x, as = "text"))
# "error" %in% names(jsonlite::fromJSON(httr::content(x, as = "text")))
#
# response <- httr::GET(url = paste0(
#   "https://apiv2.ahrefs.com/",
#   "?token=",  Sys.getenv("AHREFS_AUTH_TOKEN"),
#   "&from=",   "anchors",
#   "&target=", "ahrefs.com",
#   "&mode=",   "domain",
#   # if (!is.null(metrics)) {paste0("&select=",   paste(metrics, collapse = ","))},
#   "&limit=",  2,
#   "&output=json"#,
#   # if (!is.null(where))   {paste0("&where=",    where)},
#   # if (!is.null(having))  {paste0("&having=",   having)},
#   # if (!is.null(order_by)){paste0("&order_by=", order_by)}
# ))
#
# stop_for_status(response)
# content <- httr::content(response, type = "text", encoding = "UTF-8")
# result  <- jsonlite::fromJSON(content, simplifyVector = FALSE)
#
# http_status_200 <- response$status_code == 200
# no_hidden_error <- !("error" %in% names(jsonlite::fromJSON(httr::content(response, as = "text"))))
# is_df <- is.data.frame(result)
