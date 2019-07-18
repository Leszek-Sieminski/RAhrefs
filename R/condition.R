#' Single condition creation for an Ahrefs API query
#'
#' @description This function create an optional single condition for report querying.
#'     It can only be used in \code{where} and \code{having} parameters and should only be used
#'     inside \code{rah_condition_set} function.
#'
#' @param column_name character string. Proper name of the column of the raport to query from
#' @param operator character string. See more in details
#' @param value character string or numeric/integer. Contains the value for a condition
#' @param is_date logical, defaults to FALSE. If provided value is a date character string,
#'     should be set to TRUE. Works only for dates in \code{'YYYY-MM-DD'} format.
#'
#' @details This function should be ALWAYS used inside \code{rah_condition_set} function.
#'     Options include:
#'     \itemize{
#'
#'       \item \strong{"SUBDOMAIN"} (string) the condition is satisfied if a domain in the \code{<column>}
#'           is a subdomain of the provided \code{<domain>}, for example:
#'           \code{rah_condition("url_to", "SUBDOMAIN", "dev")}
#'
#'       \item \strong{"SUBSTRING"} (string) the condition is satisfied if the provided \code{<value>}
#'           is a substring of the \code{<column>}, for example:
#'           \code{rah_condition("url_to", "SUBSTRING", "ample")}
#'
#'       \item \strong{"WORD"} (string) the condition is satisfied if the provided \code{<value>} appears
#'           as a separate word of the \code{<column>}, for example:
#'           \code{rah_condition("title", "WORD", "the")}
#'
#'       \item \strong{"EQUALS", "UNEQUALS", "LESS_THAN", "LESS_OR_EQUAL", "GREATER_THAN", "GREATER_OR_EQUAL"}
#'           (numeric/date) the condition is satisfied if a \code{<column>} is different to \code{<value>},
#'            for example: \code{rah_condition("domain_rank", "GREATER_OR_EQUAL", 5)} \strong{OR} for dates
#'           \code{rah_condition("first_seen", "LESS_THAN", "2019-01-01", is_date = TRUE)}
#'     }
#'
#' @import assertthat
#' @return character string with formatted condition
#' @export
#'
#' @family Ahrefs conditions
#'
#' @examples
#'     \dontrun{rah_condition(column_name = "first_seen",
#'                            operator = "GREATER_THAN",
#'                            value = "2018-01-01",
#'                            is_date = TRUE)
#'  }
#'     \dontrun{rah_condition(column_name = "links",
#'                            operator = "GREATER_THAN",
#'                            value = "10")
#' }
rah_condition <- function(column_name, operator, value, is_date = FALSE){
  # safety net ----------------------------------------------------------------
  assert_that(
    is.logical(is_date), not_empty(is_date), !is.na(is_date), !is.null(is_date),
    not_empty(column_name), !is.null(column_name), !is.na(column_name),
    is.string(column_name), not_empty(value), !is.null(value), !is.na(value),
    not_empty(operator), !is.null(operator), !is.na(operator),
    operator %in% c("EQUALS", "UNEQUALS", "LESS_THAN", "LESS_OR_EQUAL",
                    "GREATER_THAN", "GREATER_OR_EQUAL", "SUBDOMAIN", "SUBSTRING",
                    "WORD"), length(operator) == 1
  )

  if(!is_date){
    x <- switch(
      operator,
      "EQUALS"           = paste0(column_name, "%3D",    value), # "="
      "UNEQUALS"         = paste0(column_name, "%3C%3E", value), # "<>"
      "LESS_THAN"        = paste0(column_name, "%3C",    value), # "<"
      "LESS_OR_EQUAL"    = paste0(column_name, "%3C%3D", value), # "<="
      "GREATER_THAN"     = paste0(column_name, "%3E",    value), # ">"
      "GREATER_OR_EQUAL" = paste0(column_name, "%3E%3D", value), # ">="
      "SUBDOMAIN"        = paste0("subdomain%28", column_name, ",%22", value, "%22%29"), # subdomain(<column>,'<domain>')
      "SUBSTRING"        = paste0("substring%28", column_name, ",%22", value, "%22%29"), # substring(<column>,'<value>')
      "WORD"             = paste0("word%28",      column_name, ",%22", value, "%22%29")  # word(<column>,'<data>')
    )
  } else {
    x <- switch(
      operator,
      "EQUALS"           = paste0(column_name, "%3D",    "%22", value, "%22"), # "="
      "UNEQUALS"         = paste0(column_name, "%3C%3E", "%22", value, "%22"), # "<>"
      "LESS_THAN"        = paste0(column_name, "%3C",    "%22", value, "%22"), # "<"
      "LESS_OR_EQUAL"    = paste0(column_name, "%3C%3D", "%22", value, "%22"), # "<="
      "GREATER_THAN"     = paste0(column_name, "%3E",    "%22", value, "%22"), # ">"
      "GREATER_OR_EQUAL" = paste0(column_name, "%3E%3D", "%22", value, "%22"), # ">="
      "SUBDOMAIN"        = paste0("subdomain%28", column_name, ",%22", value, "%22%29"), # subdomain(<column>,'<domain>')
      "SUBSTRING"        = paste0("substring%28", column_name, ",%22", value, "%22%29"), # substring(<column>,'<value>')
      "WORD"             = paste0("word%28",      column_name, ",%22", value, "%22%29")  # word(<column>,'<data>')
    )
  }
  return(x)
}
# rah_condition(column_name = "first_seen",
#               operator = "GREATER_THAN",
#               value = "2018-01-01",
#               is_date = TRUE)
#
# rah_condition(column_name = "links",
#               operator = "GREATER_THAN",
#               value = "10")
