#' Export the external domains that the target has links to.
#'
#' @param target character string. Aim of a request: a domain, a directory or a URL
#' @param token character string. Authentication token. Should be available through enviromental variables
#'     after authentication with function \code{rah_auth()}
#' @param mode character string. Mode of operation: exact, domain, subdomains or prefix. See more in Details section
#' @param metrics character vector of columns to select. See more in Details section
#' @param limit integer. Number of results to return
#' @param order_by character vector of columns to sort on. See more in Details section
#' @param where character string - a condition created by \code{rah_condition_set()} function that generates proper
#'     \code{"where"} condition to satisfy. See more in Details section
#' @param having character string - a condition created by \code{rah_condition_set()} function that generates proper
#'     \code{"having"} condition to satisfy. See more in Details section
#'
#' @source \url{https://ahrefs.com/api/documentation}
#'
#' @details
#'     \strong{1. available metrics} - you can select which columns (metrics) you want to download and which one
#'     would be useful in filtering, \strong{BUT not all of them can always be used} in \code{"where"} &
#'     \code{"having"} conditions:
#'
#'     \tabular{lllll}{
#'     Column \tab Type \tab Where \tab Having \tab Description\cr
#'     domain_from          \tab string \tab + \tab + \tab Target of the request.                                                           \cr
#'     domain_to            \tab string \tab + \tab + \tab Root of external domain that has links from the target.                          \cr
#'     links                \tab int    \tab - \tab + \tab Number of external links from the target that link to the external domain.       \cr
#'     all                  \tab int    \tab - \tab + \tab Number of external links from the target that link to the external domain.       \cr
#'     text                 \tab int    \tab - \tab + \tab Number of text external links from the target.                                   \cr
#'     image                \tab int    \tab - \tab + \tab Number of image external links from the target.                                  \cr
#'     nofollow             \tab int    \tab - \tab + \tab Number of NoFollow external links from the target.                               \cr
#'     dofollow             \tab int    \tab - \tab + \tab Number of DoFollow external links from the target.                               \cr
#'     redirect             \tab int    \tab - \tab + \tab Number of redirection external links from the target.                            \cr
#'     canonical            \tab int    \tab - \tab + \tab Number of canonical external links from the target.                              \cr
#'     gov                  \tab int    \tab - \tab + \tab Number of external links from the target to governmental domain.                 \cr
#'     edu                  \tab int    \tab - \tab + \tab Number of external links from the target to educational domain.                  \cr
#'     rss                  \tab int    \tab - \tab + \tab Number of RSS external links from the target.                                    \cr
#'     alternate            \tab int    \tab - \tab + \tab Number of alternate external links from the target.                              \cr
#'     first_seen           \tab date   \tab + \tab + \tab Least recent date when the Ahrefs crawler was able to see the link on the target.\cr
#'     last_visited         \tab date   \tab + \tab + \tab Most recent date when the Ahrefs crawler was able to see the link on the target. \cr
#'     domain_to_rating     \tab int    \tab - \tab + \tab Domain Rating of the external domain.                                            \cr
#'     domain_to_ahrefs_top \tab int    \tab - \tab + \tab Ahrefs rank of the external domain.
#'     }
#'
#'     \strong{2. \code{"mode"}} parameter can take 4 different values that will affect how the results will be grouped.
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
#'    \strong{3. \code{"order_by"}} parameter is a character string that forces sorting of the results. Structure:
#'     \itemize{
#'       \item \strong{Structure:} "\code{column_name}:asc|desc"
#'       \item \strong{Single column example:} "first_seen:asc" ~ this sorts results by \code{first_seen}
#'       column in ascending order
#'       \item \strong{Multi column example:} "last_seen:desc,first_seen:asc" ~ this sorts results
#'           by 1) \code{last_seen} column in descending order, and next by 2) \code{first_seen} column in
#'           ascending order
#'     }
#'
#'     \strong{4. \code{"where"} & \code{"having"}} are \strong{EXPERIMENTAL} parameters of condition sets
#'         (character strings) that control filtering the results. To create arguments:
#'         \enumerate{
#'           \item use \code{rah_condition()} function to create a single condition, for example:
#'               \code{cond_1 <- rah_condition(column_name = "links", operator = "GREATER_THAN", value = "10")}
#'           \item use \code{rah_condition_set()} function to group single conditions into final condition
#'               string, for example: \code{fin_cond <- rah_condition_set(cond_1, cond_2)}
#'           \item provide final condition to proper report function as a parameter, for example:
#'               \code{RAhrefs::rah_linked_domains_by_type(target = "ahrefs.com", token = "0123456789",
#'               mode = "domain", metrics = NULL, limit = 1000, where = fin_cond, order_by = "first_seen:asc")}
#'         }
#'
#' @return data frame
#' @export
#'
#' @family Ahrefs reports
#'
#' @examples
#' \dontrun{
#' # creating single conditions for 'having' parameter
#' cond_1 <- RAhrefs::rah_condition(
#'    column_name = "all",
#'    operator    = "GREATER_OR_EQUAL",
#'    value       = "10")
#'
#' cond_2 <- RAhrefs::rah_condition(
#'    column_name = "unique_pages",
#'    operator    = "GREATER_OR_EQUAL",
#'    value       = "6")
#'
#' # joining conditions into one condition set
#' cond_having <- RAhrefs::rah_condition_set(cond_1, cond_2)
#'
#' # downloading
#' b <- RAhrefs::rah_linked_domains_by_type(
#'   target   = "ahrefs.com",
#'   limit    = 2,
#'   having    = cond_having,
#'   order_by = "ahrefs_rank:desc")
#' }
rah_linked_domains_by_type <- function(
  target,
  token    = Sys.getenv("AHREFS_AUTH_TOKEN"),
  mode     = "domain",
  metrics  = NULL,
  limit    = 1000,
  order_by = NULL,
  where    = NULL,
  having   = NULL)
{
  data_list <- rah_downloader(
    target  = target,
    report  = "linked_domains_by_type",
    token   = token,
    mode    = mode,
    metrics = metrics,
    limit   = limit,
    order_by = order_by,
    where    = where,
    having   = having)

  data_df <- do.call(rbind.data.frame, data_list$domains)

  index <- sapply(data_df, is.factor)
  data_df[index] <- lapply(data_df[index], as.character)
  if ("first_seen" %in% colnames(data_df))   {data_df$first_seen <- as.POSIXct(data_df$first_seen, format = "%Y-%m-%dT%H:%M:%OS")}
  if ("last_visited" %in% colnames(data_df)) {data_df$last_visited <- as.POSIXct(data_df$last_visited, format = "%Y-%m-%dT%H:%M:%OS")}
  if ("prev_visited" %in% colnames(data_df)) {data_df$prev_visited <- as.POSIXct(data_df$prev_visited, format = "%Y-%m-%dT%H:%M:%OS")}
  if ("url_from_first_seen" %in% colnames(data_df)) {data_df$url_from_first_seen <- as.POSIXct(data_df$url_from_first_seen, format = "%Y-%m-%dT%H:%M:%OS")}
  if ("broken_at" %in% colnames(data_df)) {data_df$broken_at <- as.POSIXct(data_df$broken_at, format = "%Y-%m-%dT%H:%M:%OS")}

  return(data_df)
}

# b <- rah_linked_domains_by_type(target = "ahrefs.com", limit = 10)
# str(b)
