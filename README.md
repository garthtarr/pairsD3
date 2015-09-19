# D3 Scatterplot Matrices

[![Travis-CI Build Status](https://travis-ci.org/garthtarr/pairsD3.svg?branch=master)](https://travis-ci.org/garthtarr/pairsD3) [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/pairsD3)](http://cran.r-project.org/package=pairsD3) [![](http://cranlogs.r-pkg.org/badges/pairsD3)](http://cran.rstudio.com/web/packages/pairsD3/index.html)

This is a port of Mike Bostock's [D3 scatter plot matrix](http://bl.ocks.org/mbostock/4063663) code to the [htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework.  There have been some minor adjustments, including the addition of tooltips.

You could also consider the [pairedVis()](https://healthvis.wordpress.com/2013/04/05/pairedvis/) function in the [healthvis](https://healthvis.wordpress.com/) package.

Take it for a test run [here](http://garthtarr.com/apps/pairsD3/) (you can upload your own data).

## Installation

The `pairsD3` package is available on CRAN:

```s
install.packages("pairsD3")
```

Alternatively, you can install the development version of `pairsD3` from Github using the `devtools` package as follows:

```s
devtools::install_github("garthtarr/pairsD3")
```

## Usage

A canonical example with the iris data:

```s
data(iris)
require(pairsD3)
pairsD3(iris[,1:4],group=iris[,5])
```

#### Save

Use `savePairs` to save a pairs plot as a stand alone HTML file:

```s
library(magrittr)
pairsD3(iris[,1:4],group=iris[,5]) %>% savePairs(file = 'iris.html')
```

#### Shiny

You can view an interactive scatterplot matrix using the `shinypairs` function:

```s
shinypairs(iris)
```

#### Rmarkdown

You can include interactive scatterplot matrices in rmarkdown documents in the usual way:

    ```{r}
    require(pairsD3)
    pairsD3(iris)
    ```

#### Slidify

HTML widgets are not (yet) supported in slidify.  A workaround is to do save the widget as a webpage then include that webpage in slidify using an iframe:


    ```{r, results='asis',echo=FALSE}
    require(pairsD3)
    pd3 = pairsD3(iris)
    savePairs(pd3, 'pD3.html')
    cat('<iframe src="pD3.html"> </iframe>')
    ```


