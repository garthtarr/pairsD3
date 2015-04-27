HTMLWidgets.widget({
  name: 'pairsD3',
  type: 'output',
  initialize: function(el, width, height) {
    return {};
  },

  renderValue: function(el, xin, instance) {
    // save params for reference from resize method
    instance.xin = xin;
    // draw the graphic
    this.drawGraphic(el, xin, el.offsetWidth, el.offsetHeight);


  },

  drawGraphic: function(el, xin, width, height){
    // remove existing children
    while (el.firstChild)
      el.removeChild(el.firstChild);

    wide = HTMLWidgets.dataframeToD3(xin.data);
    factor = xin.groupval;
    alldata = HTMLWidgets.dataframeToD3(xin.alldata);
    legdata = HTMLWidgets.dataframeToD3(xin.legdata);

    domainByTrait = {}; //
    traits = d3.keys(wide[0]); // column names
    p = traits.length; // number of variables

    traits.forEach(function(trait) {
      domainByTrait[trait] = d3.extent(wide,
                              function(d) { return d[trait]; });
    });

    // get the width and height
    //var width = el.offsetWidth;
    //var height = el.offsetHeight0
    // var width = 960;
    // var size = 150;
    var xinlab = xin.labels;
    var padding = 10;
    var size = (d3.min([width,height])-2*padding)/p-4;
    var color = [];
    if(xin.settings.col.constructor===Array){
      color = xin.settings.col;
    } else {
      color = [xin.settings.col];
    }

    var x = d3.scale.linear()
            .range([padding / 2, size - padding / 2]);

    var y = d3.scale.linear()
            .range([size - padding / 2, padding / 2]);

    var xAxis = d3.svg.axis()
                .scale(x)
                .orient("bottom")
                .ticks(3);

    var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left")
                .ticks(3);

    // add the tooltip area to the webpage
    var tooltip = d3.select(el).append("div")
          .attr("class", "tooltip")
          .style("opacity", 0);

    svg = d3.select(el).append("svg")
          .attr("width", size * p + padding*2)
          .attr("height", size * p + padding*2)
          .append("g")
          .attr("transform", "translate(" + xin.leftmar + "," + xin.topmar + ")");

    xAxis.tickSize(size * p);
    yAxis.tickSize(-size * p);

    var brush = d3.svg.brush()
                .x(x)
                .y(y)
                .on("brushstart", brushstart)
                .on("brush", brushmove)
                .on("brushend", brushend);

    var brushCell;

    // Clear the previously-active brush, if any
    function brushstart(p) {
      if (brushCell !== this) {
        d3.select(brushCell).call(brush.clear());
        x.domain(domainByTrait[p.x]);
        y.domain(domainByTrait[p.y]);
        brushCell = this;
      }
    }

    // Highlight the selected circles
    function brushmove(p) {
      var e = brush.extent();
      svg.selectAll("circle").classed("greyed",
        function(d) { return e[0][0] > d[p.x] || d[p.x] > e[1][0] || e[0][1] > d[p.y] || d[p.y] > e[1][1];
        });
    }

    function brushend() {
      // If the brush is empty, select all circles.
      if (brush.empty()){
        svg.selectAll(".greyed").classed("greyed", false);
      }
      // Identify selected observations and pass them to Shiny as
      // input$selectedobs
      if(typeof Shiny !== 'undefined'){
        var circleS = svg.selectAll('circle')[0]
                        .map(function(d) {return d.className['baseVal']});
        Shiny.onInputChange("selectedobs", circleS);
      }
    }

    // X-axis
    svg.selectAll(".x.axis")
        .data(traits)
        .enter().append("g")
        .attr("class", "x axis")
        .attr("transform",
              function(d, i) { return "translate(" + i * size + ",0)"; })
        .each(function(d) { x.domain(domainByTrait[d]);
                            d3.select(this).call(xAxis); });

    // Y-axis
    svg.selectAll(".y.axis")
        .data(traits)
        .enter().append("g")
        .attr("class", "y axis")
        .attr("transform",
              function(d, i) { return "translate(0," + i * size + ")"; })
        .each(function(d) { y.domain(domainByTrait[d]);
                            d3.select(this).call(yAxis); });
    // Cell and plot
    cell = svg.selectAll(".cell")
              .data(cross(traits, traits))
              .enter().append("g")
              .attr("class", "cell")
              .attr("transform",
                    function(d) {
                      return "translate(" + d.i * size + "," + d.j * size + ")";
                    })
              .each(plot);
    // Titles for the diagonal.
    cell.filter(function(d) { return d.i === d.j; }).append('text')
      .attr("x", size/2)
      .attr("y", size/2)
      .text(function(d) { return xinlab[d.i]; })
      .style("text-anchor", "middle");

    // tooltip fn
    if(typeof Shiny !== 'undefined'){
        leftoffset = document.getElementById("pairsplot").offsetParent.offsetLeft
        topoffset = document.getElementById("pairsplot").offsetParent.offsetTop
    } else {
        leftoffset = 0
        topoffset = 0
    }

    // plot function
    function plot(p) {
      var cell = d3.select(this);
      x.domain(domainByTrait[p.x]);
      y.domain(domainByTrait[p.y]);
      // Plot frame
      cell.append("rect")
        .attr("class", "frame")
        .attr("x", padding / 2)
        .attr("y", padding / 2)
        .attr("width", size - padding)
        .attr("height", size - padding);
      // apply the brush needs to be done before tooltip
      cell.call(brush)
      // plot the data
      if (p.x !== p.y){ // prevents a main diagonal being plotted
        cell.selectAll("circle")
          .data(alldata)
          .enter().append("circle")
          .attr("cx", function(d) { return x(d[p.x]); })
          .attr("cy", function(d) { return y(d[p.y]); })
          .attr("r", xin.settings.cex)
          .style("display", function(d) { return d[p.x]==null || d[p.y]==null ? "none" : null; })
          .style("fill", function(d) { return color[d.groupval]; })
          .style("opacity", xin.settings.opacity)
          .on("mouseover", function(d) {
            tooltip.transition()
              .duration(200)
              .style("opacity", .9);
            tooltip.html(d.tooltip)// + "<br/> (" + xValue(d) + ", " + yValue(d) + ")")
              //.placement("right")
              .style("left", (event.pageX - leftoffset + 1) + "px")
              .style("top", (event.pageY - topoffset - 20) + "px");
          })
          .on("mouseout", function(d) {
            tooltip.transition()
              .duration(500)
              .style("opacity", 0);
          });
      }
    }


    // cross function
    function cross(a, b) {
      var c = [], n = a.length, m = b.length, i, j;
      for (i = -1; ++i < n;) {
        for (j = -1; ++j < m;) {
          c.push({x: a[i], i: i, y: b[j], j: j})
        }
      };
      return c;
    }

  },

  resize: function(el, width, height, instance) {
    if(instance.xin){
      this.drawGraphic(el, instance.xin, width, height);
    }
  }
});


