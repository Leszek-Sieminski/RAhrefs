# auth ------------------------------------------------------------------------
#' Authorize your Ahrefs API connection with a API Key (Token)
#'
#' @param api_key character string. Valid API key obtained at: https://ahrefs.com/api/profile
#' @param verbose logical, defaults to TRUE. Set to FALSE to stop printing status in the console
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#'   rah_auth("ABCDEFGHIJKLMNOPQRST")
#' }
rah_auth <- function(
  api_key,
  verbose = TRUE
){
  assertthat::noNA(api_key)
  assertthat::not_empty(api_key)
  assertthat::is.string(api_key)

  assertthat::noNA(verbose)
  assertthat::not_empty(verbose)
  assertthat::assert_that(is.logical(verbose))

  x <- httr::GET(url = 'https://apiv2.ahrefs.com/',
                 httr::add_headers(token = api_key))

  if (x$status_code == 200){
    Sys.setenv("AHREFS_AUTH_TOKEN" = api_key)
    if (verbose) {
      message("API authorized.")
    }
  } else {
    message(paste0("Authorization error: HTTP status code ",
                   x$status_code,
                   ". Check your api key."))
  }
}
