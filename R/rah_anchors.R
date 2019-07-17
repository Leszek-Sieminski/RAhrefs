#' Export the anchor text and the number of backlinks, referring pages and referring domains that has it.
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
#' \tabular{lllll}{
#'   Column \tab Type \tab Where \tab Having \tab Description\cr
#'   anchor       \tab string \tab + \tab + \tab Anchor text used in at least one backlink from the referring domain.                                   \cr
#'   backlinks    \tab int    \tab + \tab + \tab Number of external backlinks found that are using the anchor text.                                     \cr
#'   refpages     \tab int    \tab + \tab + \tab Number of pages found containing backlinks that are using the anchor text.                             \cr
#'   refdomain    \tab string \tab + \tab - \tab Referring domain that contains at least one backlink using the anchor text.                            \cr
#'   refdomains   \tab int    \tab - \tab + \tab Number of referring domains that are using the anchor text when linking to the target.                 \cr
#'   first_seen   \tab date   \tab + \tab + \tab Least recent date when the Ahrefs crawler was able to visit the backlink that is using the anchor text.\cr
#'   last_visited \tab date   \tab + \tab + \tab Most recent date when the Ahrefs crawler was able to visit the backlink that is using the anchor text.
#' }
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
#'               \code{RAhrefs::rah_anchors(target = "ahrefs.com", token = "0123456789",
#'               mode = "domain", metrics = NULL, limit = 1000, where = fin_cond, order_by = "first_seen:asc")}
#'         }
#'
#' @source \url{https://ahrefs.com/api/documentation}
#'
#' @return data frame
#' @export
#'
#' @family Ahrefs reports
#'
#' @examples
#' \dontrun{
#' # creating single conditions for 'where' parameter
#' # let's see anchors of all backlinks detected in 2018
#' cond_1 <- RAhrefs::rah_condition(
#'    column_name = "first_seen",
#'    operator    = "GREATER_OR_EQUAL",
#'    value       = "2018-01-01",
#'    is_date     = TRUE)
#'
#' cond_2 <- RAhrefs::rah_condition(
#'    column_name = "first_seen",
#'    operator    = "LESS_OR_EQUAL",
#'    value       = "2018-12-31",
#'    is_date     = TRUE)
#'
#' # joining conditions into one condition set
#' cond_where <- RAhrefs::rah_condition_set(cond_1, cond_2)
#'
#' # downloading
#' b <- RAhrefs::rah_anchors(
#'   target   = "ahrefs.com",
#'   limit    = 2,
#'   where    = cond_where,
#'   order_by = "refpages:desc")
#' }
rah_anchors <- function(
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
    target   = target,
    report   = "anchors",
    token    = token,
    mode     = mode,
    metrics  = metrics,
    limit    = limit,
    order_by = order_by,
    where    = where,
    having   = having)

  data_df <- do.call(rbind.data.frame, as.list(data_list$anchors))
  index <- sapply(data_df, is.factor)
  data_df[index] <- lapply(data_df[index], as.character)

  if ("first_seen" %in% colnames(data_df)) {data_df$first_seen <- as.POSIXct(data_df$first_seen, format = "%Y-%m-%dT%H:%M:%OS")}
  if ("last_visited" %in% colnames(data_df)) {data_df$last_visited <- as.POSIXct(data_df$last_visited, format = "%Y-%m-%dT%H:%M:%OS")}
  return(data_df)
}
# b <- rah_anchors(target = "ahrefs.com", limit = 10)
# b <- rah_anchors(
#   target = "ahrefs.com",
#   limit = 2,
#   where   = rah_condition_set(
#     rah_condition(column_name = "backlinks",
#                   operator = "GREATER_THAN",
#                   value = "10"),
#     rah_condition(column_name = "refpages",
#                   operator = "GREATER_THAN",
#                   value = "20")),
#   order_by = "refpages:asc")
# str(b)
