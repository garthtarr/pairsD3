#' D3 scatterplot matrices
#'
#' An interactive matrix of scatterplots is produced.
#'
#' @import htmlwidgets
#'
#' @export
pairsD3 <- function(x, group=NULL, width = NULL, height = NULL, cols=NULL, big=FALSE) {
  # ensure the data is a numeric matrix but also an array
  data = data.frame(data.matrix(x))
  if(dim(data)[2]>=10 | dim(data)[1]>500){
    warning("If you are sure you want that many variables plottes, set big=TRUE")
    return(NULL)
  }
  if(is.null(group)){
    group = rep(1,dim(data)[1])
  }
  groupval = as.numeric(factor(group))
  alldata = cbind(data,groupval,group)
  if(length(cols)<length(levels(factor(group)))){
    require(RColorBrewer)
    n.groups = max(3,length(levels(factor(group))))
    cols = brewer.pal(n.groups,name = "Set1")
  }
  legdata = data.frame(levels = levels(factor(group)),cols=cols)
  # create a list that contains the settings
  settings <- list(
    width = width,
    height = height,
    cols = cols
  )
  # pass the data and settings using 'xin'
  xin <- list(
    data = data,
    group = group,
    alldata = alldata,
    legdata = legdata,
    settings = settings
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'pairsD3',
    xin,
    width = width,
    height = height,
    package = 'pairsD3'
  )
}

#' Widget output function for use in Shiny
#'
#' @export
pairsD3Output <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'pairsD3', width, height, package = 'pairsD3')
}

#' Widget render function for use in Shiny
#'
#' @export
renderPairsD3 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, pairsD3Output, env, quoted = TRUE)
}
