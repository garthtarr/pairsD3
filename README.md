# D3 scatterplot matrices

Version 0.0.5

This is a port of Mike Bostock's [D3 scatter plot matrix](http://bl.ocks.org/mbostock/4063663) code to the [htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework.  There have been some minor adjustments, including the addition of tooltips.

You could also consider the [pairedVis()](https://healthvis.wordpress.com/2013/04/05/pairedvis/) function in the [healthvis](https://healthvis.wordpress.com/) package.

## Installation

You can install `pairsD3` from Github using the `devtools` package as follows:

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

A standalone example will be available soon.
