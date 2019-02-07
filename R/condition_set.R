#' Grouping multiple conditions for an Ahrefs API query
#'
#' @param \dots multiple condition arguments created by \code{rah_condition} function
#'
#' @return character string of parameters for API
#' @export
#'
#' @family Ahrefs conditions
#'
#' @examples
#'     \dontrun{
#'     first_condition <- RAhrefs::rah_condition(
#'       column_name = "first_seen",
#'       operator    = "GREATER_THAN",
#'       value       = "2018-01-01",
#'       is_date     = TRUE)
#'
#'     second_condition <- RAhrefs::rah_condition(
#'       column_name = "links",
#'       operator    = "GREATER_THAN",
#'       value       = "10")
#'
#'     final_condition <- RAhrefs::rah_condition_set(
#'       first_condition,
#'       second_condition)
#'  }
rah_condition_set <- function(...){
  paste(..., sep = ",", collapse = ",")
}
