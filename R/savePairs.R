#' Save a pairs plot to an HTML file
#'
#' Save a pairsD3 graph to an HTML file for sharing with others. The HTML can
#' include it's dependencies in an adjacent directory or can bundle all
#' dependencies into the HTML file (via base64 encoding).
#'
#' @param pairs plot to save (e.g. result of calling the function
#'   \code{pairsD3}).
#'
#' @inheritParams htmlwidgets::saveWidget
#'
#' @export
savePairs <- function(pairs, file, selfcontained = TRUE) {
  htmlwidgets::saveWidget(pairs, file, selfcontained)
}
