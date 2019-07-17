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
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
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
    !is.na(api_key), noNA(api_key), not_empty(api_key), is.string(api_key),
    nchar(api_key) > 0,
    noNA(verbose), not_empty(verbose), assert_that(is.logical(verbose)))

  # connecting to auth endpoint -----------------------------------------------
  # x <- GET(url = 'https://apiv2.ahrefs.com/',
  #          add_headers(token = api_key))

  response <- GET(url = paste0(
    "https://apiv2.ahrefs.com/",
    "?token=",  api_key,
    "&from=",   "anchors",
    "&target=", "ahrefs.com",
    "&mode=",   "domain",
    # if (!is.null(metrics)) {paste0("&select=",   paste(metrics, collapse = ","))},
    "&limit=",  2,
    "&output=json"#,
    # if (!is.null(where))   {paste0("&where=",    where)},
    # if (!is.null(having))  {paste0("&having=",   having)},
    # if (!is.null(order_by)){paste0("&order_by=", order_by)}
  ))

  stop_for_status(response)
  content <- content(response, type = "text", encoding = "UTF-8")
  result  <- fromJSON(content, simplifyVector = FALSE)

  # api_key sanity check ------------------------------------------------------
  http_status_200 <- response$status_code == 200
  no_hidden_error <- !("error" %in% names(jsonlite::fromJSON(httr::content(response, as = "text"))))
  # is_df <- is.data.frame(result)

  # saving enviromental variable ----------------------------------------------
  if (http_status_200 & no_hidden_error){
    Sys.setenv("AHREFS_AUTH_TOKEN" = api_key)
    if (verbose) message("API authorized.")
  } else stop(paste0("Authorization error: HTTP status code ", response$status_code,". Check your api key."))
}
