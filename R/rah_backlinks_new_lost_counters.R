#' Export new and lost backlink totals.
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
#'     date           \tab date    \tab + \tab + \tab Date the backlink was tagged as New or Lost                                                               \cr
#'     type           \tab string  \tab + \tab - \tab Indicates whether the backlink is New or Lost.                                                            \cr
#'     ahrefs_rank    \tab int     \tab + \tab - \tab URL Rating of the referring page.                                                                         \cr
#'     domain_rating  \tab int     \tab + \tab - \tab Domain Rating of the referring domain.                                                                    \cr
#'     url_from       \tab string  \tab + \tab - \tab URL of the page where the backlink is found                                                               \cr
#'     url_to         \tab string  \tab + \tab + \tab URL of the page the backlink is pointing to.                                                              \cr
#'     links_internal \tab int     \tab + \tab - \tab Number of internal links found in the referring page.                                                     \cr
#'     links_external \tab int     \tab + \tab - \tab Number of external links found in the referring page.                                                     \cr
#'     encoding       \tab string  \tab + \tab - \tab Character encoding of the referring page, for example "utf8" or "iso-8859-1" (Latin-1).                   \cr
#'     http_code      \tab int     \tab + \tab - \tab HTTP code that was last returned for the referring page.                                                  \cr
#'     title          \tab string  \tab + \tab - \tab Title of the referring page.                                                                              \cr
#'     origin         \tab string  \tab + \tab - \tab Either "fresh", "drop", or "recrawl".                                                                     \cr
#'     first_seen     \tab date    \tab + \tab - \tab Least recent date when the Ahrefs crawler was able to visit the backlink.                                 \cr
#'     last_visited   \tab date    \tab + \tab - \tab Most recent date when the Ahrefs crawler was able to visit the backlink.                                  \cr
#'     prev_visited   \tab date    \tab + \tab - \tab Second to most recent date when the Ahrefs crawler was able to visit the backlink.                        \cr
#'     original       \tab boolean \tab + \tab - \tab Indicates whether the backlink was present on the referring page when the Ahrefs crawler first visited it.\cr
#'     link_type      \tab string  \tab + \tab - \tab Either "href", "redirect", "frame", "form", "canonical", "rss", or "alternate".                           \cr
#'     redirect       \tab int     \tab + \tab - \tab For redirected links, the Redirect Code (3XX), zero otherwise.                                            \cr
#'     nofollow       \tab boolean \tab + \tab - \tab Indicates whether the backlink is NoFollow.                                                               \cr
#'     alt            \tab string  \tab + \tab - \tab Alternative text of the image backlink, if exists.                                                        \cr
#'     anchor         \tab string  \tab + \tab - \tab Anchor text of the backlink.                                                                              \cr
#'     text_pre       \tab string  \tab + \tab - \tab Snippet before the anchor text.                                                                           \cr
#'     text_post      \tab string  \tab + \tab - \tab Snippet after the anchor text.                                                                            \cr
#'     new            \tab int     \tab - \tab + \tab Total number of new backlinks found to this url.                                                          \cr
#'     lost           \tab int     \tab - \tab + \tab Total number of backlinks removed to this url.                                                            \cr
#'     new_total      \tab int     \tab - \tab + \tab Total number of new backlinks found to this url when ignoring where filter.                               \cr
#'     lost_total     \tab int     \tab - \tab + \tab Total number of backlinks removed to this url when ignoring where filter.
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
#'               \code{RAhrefs::rah_backlinks_new_lost_counters(target = "ahrefs.com", token = "0123456789",
#'               mode = "domain", metrics = NULL, limit = 1000, where = fin_cond, order_by = "first_seen:asc")}
#'         }
#'
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
#'    column_name = "links_internal",
#'    operator    = "GREATER_OR_EQUAL",
#'    value       = "5")
#'
#' cond_2 <- RAhrefs::rah_condition(
#'    column_name = "links_external",
#'    operator    = "LESS_OR_EQUAL",
#'    value       = "5")
#'
#' # joining conditions into one condition set
#' cond_where <- RAhrefs::rah_condition_set(cond_1, cond_2)
#'
#' # downloading
#' b <- RAhrefs::rah_backlinks_new_lost_counters(
#'   target   = "ahrefs.com",
#'   limit    = 2,
#'   where    = cond_where,
#'   order_by = "links_external:desc")
#' }
rah_backlinks_new_lost_counters <- function(
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
    report   = "backlinks_new_lost_counters",
    token    = token,
    mode     = mode,
    metrics  = metrics,
    limit    = limit,
    order_by = order_by,
    where    = where,
    having   = having)

  data_df <- do.call(rbind.data.frame, data_list$counts)

  index <- sapply(data_df, is.factor)
  data_df[index] <- lapply(data_df[index], as.character)
  data_df$date <- as.Date(data_df$date)
  return(data_df)
}

# b <- rah_backlinks_new_lost_counters(target = "ahrefs.com", limit = 10)
# str(b)
