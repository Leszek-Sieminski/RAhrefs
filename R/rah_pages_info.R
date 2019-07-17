#' Export additional info about the target, such as IP address, canonical URL, social meta tags and social metrics.
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
#'     url                   \tab string \tab + \tab + \tab URL of the crawled page.                                                         \cr
#'     ip                    \tab string \tab + \tab + \tab IP address of the server that returned the page.                                 \cr
#'     size                  \tab int    \tab + \tab + \tab Size of the crawled page, in bytes.                                              \cr
#'     links_internal        \tab int    \tab + \tab + \tab Number of internal links found in the crawled page.                              \cr
#'     links_external        \tab int    \tab + \tab + \tab Number of external links found in the crawled page.                              \cr
#'     encoding              \tab string \tab + \tab + \tab Character encoding of the page, for example "utf8" or "iso-8859-1" (Latin-1).    \cr
#'     title                 \tab string \tab + \tab + \tab Title of the crawled page.                                                       \cr
#'     redirect_url          \tab string \tab + \tab + \tab URL where the page redirects to.                                                 \cr
#'     canonical_url         \tab string \tab + \tab + \tab Canonical URL of the page.                                                       \cr
#'     content_encoding      \tab string \tab + \tab + \tab Type of encoding used to compress the page data, for example "gzip" or "deflate".\cr
#'     description           \tab string \tab + \tab + \tab Description of the crawled page.                                                 \cr
#'     meta_social           \tab string \tab + \tab + \tab Contents of meta tags for social sharing sites.                                  \cr
#'     twitter               \tab int    \tab + \tab + \tab Number of Twitter shares of the page.                                            \cr
#'     pinterest             \tab int    \tab + \tab + \tab Number of Pinterest shares of the page.                                          \cr
#'     facebook_likes        \tab int    \tab + \tab + \tab Number of Facebook likes of the page.                                            \cr
#'     facebook_shares       \tab int    \tab + \tab + \tab Number of Facebook shares of the page.                                           \cr
#'     facebook_comments     \tab int    \tab + \tab + \tab Number of Facebook comments of the page.                                         \cr
#'     facebook_clicks       \tab int    \tab + \tab + \tab Number of Facebook clicks of the page.                                           \cr
#'     facebook_comments_box \tab int    \tab + \tab + \tab Number of Facebook box comments of the page.                                     \cr
#'     facebook              \tab int    \tab + \tab + \tab Total number of Facebook shares/likes of the page.                               \cr
#'     total_shares          \tab int    \tab + \tab + \tab Total number of shares of the page across all social networks.                   \cr
#'     median_shares         \tab int    \tab + \tab + \tab Median number of shares of the page across all social networks.
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
#'               \code{RAhrefs::rah_pages_info(target = "ahrefs.com", token = "0123456789",
#'               mode = "domain", metrics = NULL, limit = 1000, where = fin_cond, order_by = "first_seen:asc")}
#'         }
#'
#' @return nested list - the structure can be too complicated to convert into simple data frame
#' @export
#'
#' @family Ahrefs reports
#'
#' @examples
#' \dontrun{
#' # creating single conditions for 'where' parameter
#' cond_1 <- RAhrefs::rah_condition(
#'    column_name = "facebook_likes",
#'    operator    = "GREATER_OR_EQUAL",
#'    value       = "1000")
#'
#' cond_2 <- RAhrefs::rah_condition(
#'    column_name = "facebook_shares",
#'    operator    = "GREATER_THAN",
#'    value       = "200")
#'
#' # joining conditions into one condition set
#' cond_where <- RAhrefs::rah_condition_set(cond_1, cond_2)
#'
#' # downloading
#' b <- RAhrefs::rah_pages_info(
#'   target   = "ahrefs.com",
#'   limit    = 2,
#'   where    = cond_where,
#'   order_by = "ahrefs_rank:desc")
#' }
rah_pages_info <- function(
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
    report   = "pages_info",
    token    = token,
    mode     = mode,
    metrics  = metrics,
    limit    = limit,
    order_by = order_by,
    where    = where,
    having   = having)
}

# b <- rah_pages_info(target = "ahrefs.com", limit = 10)
# str(b)
