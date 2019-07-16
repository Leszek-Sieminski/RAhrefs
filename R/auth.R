#' Authorize your Ahrefs API connection with a API Key (Token)
#'
#' @param api_key character string. Valid API key obtained at: https://ahrefs.com/api/profile
#' @param verbose logical, defaults to TRUE. Set to FALSE to stop printing status in the console
#'
#' @return invisibly returns API token into environment variable AHREFS_AUTH_TOKEN and prints the status
#' @export
#'
#' @import assertthat
#' @importFrom httr GET
#' @importFrom httr add_headers
#'
#' @examples
#' \dontrun{
#'   rah_auth("ABCDEFGHIJKLMNOPQRST")
#' }
rah_auth <- function(
  api_key,
  verbose = TRUE
){
  # safety net ----------------------------------------------------------------
  assert_that(
    noNA(api_key), not_empty(api_key), is.string(api_key), noNA(verbose),
    not_empty(verbose), assert_that(is.logical(verbose)))

  # connecting to auth endpoint -----------------------------------------------
  x <- GET(url = 'https://apiv2.ahrefs.com/',
           add_headers(token = api_key))

  # saving enviromental variable ----------------------------------------------
  if (x$status_code == 200){
    Sys.setenv("AHREFS_AUTH_TOKEN" = api_key)
    if (verbose) message("API authorized.")
  } else message(paste0("Authorization error: HTTP status code ", x$status_code,". Check your api key."))
}
