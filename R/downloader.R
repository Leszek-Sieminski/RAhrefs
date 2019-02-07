#' Universal downloading helper function for Ahrefs API
#'
#' @description This is a helper function and it \strong{should not be used in most cases}. Use
#'     \code{rah_<report_name>()} functions instead as they are specific wrappers that provide
#'     full documentation needed for each report.
#'
#' @param target character string. Aim of a request: a domain, a directory or a URL
#' @param report character string. Name of the table (report) to select data from
#' @param token character string. Authentication token. Should be available through enviromental variables
#'     after authentication with function \code{rah_auth()}
#' @param mode character string. Mode of operation: exact, domain, subdomains or prefix. See more
#'     in Details section
#' @param metrics character vector of columns to select
#' @param limit integer. Number of results to return
#' @param order_by character vector of columns to sort on. See more in Details section
#' @param where character string - a condition created by rah_condition_set function that generates proper
#'     "Where" condition to satisfy. See more in Details section
#' @param having character string - a condition created by rah_condition_set function that generates proper
#'     "Having" condition to satisfy. See more in Details section
#'
#' @source \url{https://ahrefs.com/api/documentation}
#'
#' @details
#'     \strong{1. "mode"} parameter can take 4 different values that will affect how the results will be grouped.
#'
#' Example of URL directory with folder:
#'     \itemize{
#'       \item \strong{Example URL:} ahrefs.com/api/
#'       \item \strong{exact:} ahrefs.com/api/
#'       \item \strong{domain:} ahrefs.com/*
#'       \item \strong{subdomains:} *ahrefs.com/*
#'       \item \strong{prefix:} ahrefs.com/api/*
#'     }
#' Example of URL directory with subdomain:
#'     \itemize{
#'       \item \strong{Example URL:} apiv2.ahrefs.com
#'       \item \strong{exact:} apiv2.ahrefs.com/
#'       \item \strong{domain:} apiv2.ahrefs.com/*
#'       \item \strong{subdomains:} *apiv2.ahrefs.com/*
#'       \item \strong{prefix:} apiv2.ahrefs.com/*
#'     }
#'
#'    \strong{2. "order_by"} parameter is a character string that forces sorting of the results. Structure:
#'     \itemize{
#'       \item \strong{Structure:} "\code{column_name}:asc|desc"
#'       \item \strong{Single column example:} "first_seen:asc" ~ this sorts results by \code{first_seen}
#'       column in ascending order
#'       \item \strong{Multi column example:} "last_seen:desc,first_seen:asc" ~ this sorts results
#'           by 1) \code{last_seen} column in descending order, and next by 2) \code{first_seen} column in
#'           ascending order
#'     }
#'
#'     \strong{3. "where" & "having"} are \strong{EXPERIMENTAL} parameters of condition sets (character strings)
#'         that control filtering the results. To create arguments:
#'         \enumerate{
#'           \item use \code{rah_condition()} function to create a single condition, for example:
#'               \code{cond_1 <- rah_condition(column_name = "links", operator = "GREATER_THAN", value = "10")}
#'           \item use \code{rah_condition_set()} function to group single conditions into final condition
#'               string, for example: \code{fin_cond <- rah_condition_set(cond_1, cond_2)}
#'           \item provide final condition to proper report function as a parameter, for example:
#'               \code{RAhrefs::rah_downloader(target = "ahrefs.com", report = "anchors", token = "0123456789",
#'               mode = "domain", metrics = NULL, limit = 1000, where = fin_cond, order_by = "first_seen:asc")}
#'         }
#'
#' @return list or nested list object
#'
#' @export
#'
#' @examples
#' # do not use this function - instead use its wrappers (rah_<report_name>()) that have full documentation
#' \dontrun{RAhrefs::rah_downloader(
#'    target  = "ahrefs.com",
#'    report  = "anchors",
#'    token   = "0123456789",
#'    mode    = "domain",
#'    metrics = NULL,
#'    limit   = 1000,
#'    where   = rah_condition_set(
#'      rah_condition(column_name = "links",
#'                    operator = "GREATER_THAN",
#'                    value = "10"),
#'      rah_condition(column_name = "links",
#'                    operator = "LESS_THAN",
#'                    value = "20")),
#'    order_by = "first_seen:asc")}
rah_downloader <- function(target,
                           report,
                           token    = Sys.getenv("AHREFS_AUTH_TOKEN"),
                           mode     = "domain",
                           metrics  = NULL,
                           limit    = 1000,
                           order_by = NULL,
                           where    = NULL,
                           having   = NULL
){
  # report list ---------------------------------------------------------------
  report_vector <- c("ahrefs_rank", "anchors", "anchors_refdomains",
                     "backlinks", "backlinks_new_lost",
                     "backlinks_new_lost_counters", "backlinks_one_per_domain",
                     "broken_backlinks", "broken_links", "domain_rating",
                     "linked_anchors", "linked_domains",
                     "linked_domains_by_type", "metrics", "metrics_extended",
                     "pages", "pages_extended", "pages_info", "refdomains",
                     "refdomains_by_type", "refdomains_new_lost",
                     "refdomains_new_lost_counters", "refips",
                     "subscription_info")

  # modes list ----------------------------------------------------------------
  mode_vector <- c("exact", "domain", "subdomains", "prefix")

  # safety net: target --------------------------------------------------------
  assertthat::assert_that(!is.null(target))
  assertthat::assert_that(!is.na(target))
  assertthat::is.string(target)
  assertthat::assert_that(
    grepl("\\.", target),
    msg = "No dot ('.') is detected in parameter 'target'. Is it a proper URL address?")

  # safety net: report --------------------------------------------------------
  assertthat::assert_that(!is.null(report))
  assertthat::assert_that(!is.na(report))
  assertthat::is.string(report)
  assertthat::assert_that(report %in% report_vector)

  # safety net: token ---------------------------------------------------------
  assertthat::assert_that(!is.null(token))
  assertthat::assert_that(!is.na(token))
  assertthat::is.string(token)
  assertthat::assert_that(
    nchar(token) > 30,
    msg = "'token' parameter is too short. Is your API token correct?")

  # safety net: mode ----------------------------------------------------------
  assertthat::assert_that(!is.null(mode))
  assertthat::assert_that(!is.na(mode))
  assertthat::is.string(mode)
  assertthat::assert_that(mode %in% mode_vector)

  # safety net: metrics -------------------------------------------------------
  # assertthat::assert_that(!is.na(metrics))
  if(!is.null(metrics)) {
    assertthat::assert_that(
      is.vector(metrics, mode = "character"),
      msg = "'metrics' parameter must be a character vector")
  } #else {metrics <- '*'}

  # safety net: limit ---------------------------------------------------------
  assertthat::is.number(limit)
  assertthat::assert_that(limit >= 1)
  assertthat::assert_that(
    limit %% 1 == 0,
    msg = "Parameter 'limit' must be a natural number (no fractions allowed).")


  # safety net: order_by ------------------------------------------------------
  # assertthat::assert_that(!is.na(order_by))
  # assertthat::is.string(order_by)

  if(!is.null(order_by)) {
    if(grepl("\\:", order_by)) {
      order_by <- gsub(pattern     = "\\:",
                       replacement = "%3A",
                       order_by)
    }
  }

    # safety net: where ---------------------------------------------------------
  # assertthat::assert_that(!is.na(where))
  # assertthat::is.string(where)

  # safety net: having --------------------------------------------------------
  # assertthat::assert_that(!is.na(having))
  # assertthat::is.string(having)

  # downloading ---------------------------------------------------------------
  response <- httr::GET(paste0(
    "https://apiv2.ahrefs.com/",
    "?token=",  token,
    "&from=",   report,
    "&target=", target,
    "&mode=",   mode,
    if (!is.null(metrics)) {paste0("&select=",   metrics)},
    "&limit=",  limit,
    "&output=json",
    if (!is.null(where))   {paste0("&where=",    where)},
    if (!is.null(having))  {paste0("&having=",   having)},
    if (!is.null(order_by)){paste0("&order_by=", order_by)}
  ))

  httr::stop_for_status(response)
  content <- httr::content(response, type = "text", encoding = "UTF-8")
  result  <- jsonlite::fromJSON(content, simplifyVector = FALSE)
  return(result)
}
