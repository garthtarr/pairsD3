#' Shiny interface to the pairsD3 function
#'
#' Opens a shiny GUI to facilitate interaction with the pairsD3 function
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
#'
#' @import shiny
#'
#' @examples
#' data(iris)
#' \dontrun{
#' shinypairs(iris)
#' }
#'
#' @export
shinypairs = function(x, group=NULL, subset=NULL, labels = NULL){
  calls = match.call()
  shinyApp(
    ui=fluidPage(
      titlePanel(""),
      fluidRow(
        column(3,
               wellPanel(
                 uiOutput("varselect"),
                 uiOutput("facselect1"),
                 uiOutput("facselect2"),
                 radioButtons("theme", "Colour theme",
                              choices = c("Colour"= "colour",
                                          "Monochrome"="bw")),
                 #sliderInput("fontsize","Font size",12,min=6,max=24),
                 sliderInput("cex","Size of plotting symbol",3,min=1,max=10),
                 sliderInput("opacity","Opacity of plotting symbol",0.9,min=0,max=1),
                 sliderInput("width","Width and height",600,min=200,max=1200),
                 radioButtons("table_data_logical", label="Table of data?",
                              choices = c("No" = 0,
                                          "Yes" = 1)),
                 conditionalPanel("input.table_data_logical==1",
                                  selectInput(inputId="table_data_vars",label="Include all variables in table?",
                                              choices=c("No" = 0,
                                                        "Yes" = 1))
                 )
               ),
               wellPanel(
                 downloadButton("export",label="Download html file"),
                 br(),br(),
                 strong("Recreate using this code:"),
                 verbatimTextOutput("code")
               ),
               wellPanel(
                 icon("warning"),
                 tags$small("The pairsD3 package is under active development."),
                 tags$small("Report issues here: "),
                 HTML(paste("<a href=http://github.com/garthtarr/pairsD3/issues>")),
                 icon("github"),
                 HTML(paste("</a>"))
               )
        ),
        column(9,
               uiOutput("pairsplot"),
               br(),br(),
               dataTableOutput(outputId="outputTable")
        )
      )
    ),
    shinyServer(function(input, output) {

      output$varselect <- renderUI({
        cols = colnames(x)
        selectInput("choose_vars", "Select variables to plot",
                    choices=cols, selected=cols[1:3], multiple=T)
      })


      output$facselect1 <- renderUI({
        radioButtons("factor_var_logical", label="Is there a factor variable?",
                     choices = c("Yes" = 1,
                                 "No" = 0),
                     selected = selectedfac())
      })
      output$facselect2 <- renderUI({
        if(!is.null(calls[["group"]])){
          cols = c(deparse(calls[["group"]]),colnames(x))
        } else{
          cols = colnames(x)
        }
        conditionalPanel(
          condition = "input.factor_var_logical == 1",
          selectInput(inputId="factor_var",label="Factor variable:",
                      choices=cols,multiple=FALSE,selected = selectedfacvar())
        )
      })

      selectedfac = reactive({
        if(!is.null(calls[["group"]])) {
          return(1)
        } else return(0)
      })

      selectedfacvar = reactive({
        if(!is.null(calls[["group"]])) {
          return(NULL)
        } else { # tries to identify the most likely factor variable
          n.fac = function(x){length(levels(as.factor(x)))}
          nfacs = apply(x,2,n.fac)
          nfacs = nfacs[nfacs>1] # exclude any vars that are all
          return(names(which.min(nfacs))[1])
        }
      })

      groupvar = reactive({
        if(!is.null(input$factor_var_logical)){
          if(input$factor_var_logical==1){
            if(input$factor_var==deparse(calls[["group"]])){
              return(group)
            } else{
              return(x[,input$factor_var])
            }
          }
        }
      })

      output$pairsplot <- renderUI({
        pairsD3Output("pD3",width = input$width,height=input$width)
      })

      output$export = downloadHandler(
        filename = "pairsD3.html",
        content = function(file){
          savePairs(pairsD3(x,group=groupvar(), subset=subset, labels = labels,
                            theme = input$theme,
                            width=input$width,
                            opacity = input$opacity,
                            cex = input$cex),
                    file=file)
        }
      )

      output$pD3 <- renderPairsD3({
        pairsD3(x[,choices()],group=groupvar(), subset=subset, labels = labels,
                theme = input$theme,big=TRUE,
                opacity = input$opacity,
                cex = input$cex)
      })

      output$code = renderText({
        if(length(choices())==dim(x)[2]){
          paircall = paste("pairsD3(",deparse(calls[["x"]]),sep="")
        } else {
          paircall = paste("pairsD3(",deparse(calls[["x"]]),"[,c(",paste(match(choices(),names(x)),collapse=","),")]",sep="")
        }
        if(!is.null(calls[["group"]])){

        }
        if(!is.null(input$factor_var_logical)){
          if(input$factor_var_logical==1){
            if(input$factor_var==deparse(calls[["group"]])){
              paircall = paste(paircall,", group = ",deparse(calls[["group"]]),sep="")
            } else{
              paircall = paste(paircall,", group = ",deparse(calls[["x"]]),"[,",match(input$factor_var,names(x)),"]",sep="")
            }
          }
        }
        if(!is.null(calls[["subset"]])){
          paircall = paste(paircall,", subset = ",deparse(calls[["subset"]]),sep="")
        }
        if(!is.null(calls[["labels"]])){
          paircall = paste(paircall,", labels = ",deparse(calls[["labels"]]),sep="")
        }
        if(input$theme=="bw"){
          paircall = paste(paircall,", theme = 'bw'",sep="")
        }
        if(length(choices())>9){
          paircall = paste(paircall,", big = TRUE",sep="")
        }
        paircall = paste(paircall,", opacity = ", input$opacity,sep="")
        paircall = paste(paircall,", cex = ", input$cex,sep="")
        return(paste(paircall, ", width = ",input$width,")",sep=""))
      })

      choices<-reactive({
        input$choose_vars
      })

      output$outputTable = renderDataTable({
        data = x
        if(input$table_data_logical==1){
          displayDF <- as.matrix(data) # baseData$df #data sent to d3.js
          n=dim(displayDF)[1]
          dfFilter <- input$selectedobs[1:n] # passed from the web interface
          if (is.null(dfFilter)){
            # no selection has been made
            dfFilter = rep(TRUE,n)
          }
          displayDF <- as.data.frame(cbind(names=row.names(displayDF),
                                           displayDF))
          dfFilter[dfFilter==''] = TRUE
          dfFilter[dfFilter=='greyed'] = FALSE
          if(input$table_data_vars==0){
            return(as.matrix(displayDF[dfFilter == TRUE,choices(),drop=FALSE]))
          } else if(input$table_data_vars==1){
            return(as.matrix(displayDF[dfFilter == TRUE,,drop=FALSE]))
          }
        } else {
          return(NULL)
        }
      },
      options = list(dom = 't<lp>',pageLength = 20,
                     autoWidth = TRUE,
                     lengthMenu = list(c(20, 50, -1), c('20', '50', 'All')),
                     searching = FALSE)
      )

    })
  )}
