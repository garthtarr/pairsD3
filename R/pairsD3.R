#' D3 scatterplot matrices
#'
#' An interactive matrix of scatterplots is produced.
#'
#' @param x the coordinates of points given as numeric columns of a
#'   matrix or data frame. Logical and factor columns are converted
#'   to numeric in the same way that \code{data.matrix} does.
#' @param group a optional vector specifying the group each observation
#'   belongs to.  Used for tooltips and colouring the observations.
#' @param subset an optional vector specifying a subset of observations
#'   to be used for plotting. Useful when you have a large number of
#'   observations, you can specify a random subset.
#' @param labels the names of the variables (column names of \code{x}
#'   used by default).
#' @param cex the magnification of the plotting symbol (default=3)
#' @param col an optional (hex) colour for each of the levels in the group
#'   vector.
#' @param big a logical parameter.  Prevents inadvertent plotting of huge
#'   data sets.  Default limit is 10 variables, to plot more than 10 set
#'   \code{big=TRUE}.
#' @param theme a character parameter specifying whether the theme should
#'   be colour \code{colour} (default) or black and white \code{bw}.
#' @param width the width (and height) of the plot when viewed externally.
#' @param opacity numeric between 0 and 1. The opacity of the plotting
#'   symbols (default 0.9).
#' @param tooltip an optional vector with the tool tip to be displayed when
#'   hovering over an observation. You can include basic html.
#' @param leftmar space on the left margin
#' @param topmar space on the bottom margin
#'
#' @import htmlwidgets
#'
#' @examples
#' data(iris)
#' \dontrun{
#' pairsD3(iris[,1:4],group=iris[,5],
#'          labels=gsub(pattern = "\\.",replacement = " ", names(iris)))
#' }
#'
#' @export
pairsD3 <- function(x, group=NULL, subset=NULL, labels = NULL, cex = 3,
                    width = NULL, col=NULL, big=FALSE, theme="colour", opacity = 0.9,
                    tooltip = NULL,leftmar = 35,topmar=2) {
  height=width
  # ensure the data is a numeric matrix but also an array
  data = data.frame(data.matrix(x))
  n = dim(data)[1]
  p = dim(data)[2]
  if(!big & dim(data)[2]>=10){
    warning("If you are sure you want that many variables plotted, set big=TRUE")
    return(NULL)
  }
  if(is.null(labels)){
    labels=names(data)
  }
  if(is.null(group)){
    group = rep("",n)
  }
  n.group = length(levels(factor(group)))
  groupval = as.numeric(factor(group))-1
  if(is.null(tooltip)){
    if(is.null(rownames(x))){
      tooltip = c(1:n)
    } else {
      tooltip = rownames(x)
    }
    if(n.group>1){
      tooltip=paste(tooltip,"<br/>",group)
    }
  }
  alldata = cbind(data,groupval,group,tooltip)
  if(is.null(col)){
    if(is.element(theme,c("colour","color"))){
      # Set1 from brewer.pal() in the RColorBrewer package
      col=c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00",
            "#FFFF33", "#A65628", "#F781BF", "#999999")[1:n.group]
      while(any(is.na(col))){
        col[is.na(col)] = col[1:sum(is.na(col))] # repeat colours
      }
    } else if(theme=="bw"){
      col=gray.colors(n.group,start=0,end=0.75)
    }
  }
  if(length(col)>n.group){
    warning("The length of col should be the same as the number of levels in
             the groups vector.")
    col = unique(col)
  }
  # create a list that contains the settings
  settings <- list(
    width = width,
    height = height,
    col = col,
    cex = cex,
    opacity = opacity
  )
  # pass the data and settings using 'xin'
  xin <- list(
    data = data,
    group = group,
    alldata = alldata,
    n = n,
    p = p,
    labels = labels,
    settings = settings,
    leftmar = leftmar,
    topmar = topmar
  )
  # create widget
  htmlwidgets::createWidget(
    name = 'pairsD3',
    x = xin,
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
    package = 'pairsD3'
  )
}

#' Widget output function for use in Shiny
#'
#' @param outputId Shiny output ID
#' @param width width default '100\%'
#' @param height height default '400px'
#'
#' @export
pairsD3Output <- function(outputId, width = '100%', height = '100%'){
  shinyWidgetOutput(outputId, 'pairsD3', width, height, package = 'pairsD3')
}

#' Widget render function for use in Shiny
#'
#' @param expr pairsD3 expression
#' @param env environment
#' @param quoted logical, default = FALSE
#'
#' @export
renderPairsD3 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, pairsD3Output, env, quoted = TRUE)
}
