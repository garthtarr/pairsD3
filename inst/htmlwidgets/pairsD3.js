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
    console.log(xin);
    alldata = HTMLWidgets.dataframeToD3(xin.alldata);
    legdata = HTMLWidgets.dataframeToD3(xin.legdata);

    domainByTrait = {}; // ?
    traits = d3.keys(wide[0]); // column names
    p = traits.length; // number of variables

    traits.forEach(function(trait) {
      domainByTrait[trait] = d3.extent(wide,
                  function(d) { return +d[trait]; }
                  );
    });


    // get the width and height
    var width = el.offsetWidth;
    var height = el.offsetHeight;
    // var width = 960;
    var size = 150;
    var padding = 15;
    color = xin.settings.cols
    //var color = d3.scale.linear()
    //            .domain([1,3])
    //            .range(["red","blue","yellow"]);
    //d3.scale.category10();
    // var color = eval(settings.colourScale);

    var x = d3.scale.linear()
            .range([padding / 2, size - padding / 2]);

    var y = d3.scale.linear()
            .range([size - padding / 2, padding / 2]);

    var xAxis = d3.svg.axis()
                .scale(x)
                .orient("bottom")
                .ticks(4);

    var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left")
                .ticks(4);

    // add the tooltip area to the webpage
    var tooltip = d3.select(el).append("div")
          //.attr("width", size * p + padding*4)
          //.attr("height", size * p + padding*4)
          .attr("class", "tooltip")
          .style("opacity", 0);

    svg = d3.select(el).append("svg")
          .attr("width", size * p + padding*4)
          .attr("height", size * p + padding*4)
          .append("g")
          .attr("transform", "translate(" + padding*2 + "," + padding / 2 + ")");



    xAxis.tickSize(size * p);
    yAxis.tickSize(-size * p);


    var brush = d3.svg.brush()
                .x(x)
                .y(y)
                .on("brushstart", brushstart)
                .on("brush", brushmove)
                .on("brushend", brushend);


var brushCell;

// Clear the previously-active brush, if any.
function brushstart(p) {
if (brushCell !== this) {
d3.select(brushCell).call(brush.clear());
x.domain(domainByTrait[p.x]);
y.domain(domainByTrait[p.y]);
brushCell = this;
}
}

    // Highlight the selected circles.
    function brushmove(p) {
      var e = brush.extent();
      svg.selectAll("circle").classed("greyed",
        function(d) { return e[0][0] > d[p.x] || d[p.x] > e[1][0] || e[0][1] > d[p.y] || d[p.y] > e[1][1];
        });
    }

// If the brush is empty, select all circles.
// function brushend() {
//  if (brush.empty()) svg.selectAll(".greyed").classed("greyed", false);
// }

    // If the brush is empty, select all circles.
    function brushend() {
      if (brush.empty()){
        svg.selectAll(".greyed").classed("greyed", false);
      }
      var circleStates = d3.select('svg')
                          .select('g')
                          .selectAll('circle')[0]
                          .map(function(d) {return d.className['baseVal']});
      //Shiny.onInputChange("mydata", circleStates);
    }


    // X-axis.
    svg.selectAll(".x.axis")
        .data(traits)
        .enter().append("g")
        .attr("class", "x axis")
        .attr("transform",
              function(d, i) { return "translate(" + i * size + ",0)"; })
        .each(function(d) { x.domain(domainByTrait[d]);
                            d3.select(this).call(xAxis); });

    // Y-axis.
    svg.selectAll(".y.axis")
        .data(traits)
        .enter().append("g")
        .attr("class", "y axis")
        .attr("transform",
              function(d, i) { return "translate(0," + i * size + ")"; })
        .each(function(d) { y.domain(domainByTrait[d]);
                            d3.select(this).call(yAxis); });

    // Cell and plot.
    var cell = svg.selectAll(".cell")
              .data(cross(traits, traits))
              .enter().append("g")
              .attr("class", "cell")
              .attr("transform",
                    function(d) {
                      return "translate(" + d.i * size + "," + d.j * size + ")";
                    })
              .each(plot);

//cell.call(brush);

// Titles for the diagonal.
cell.filter(function(d) { return d.i === d.j; }).append("text")
    .attr("x", size/2)
    .attr("y", size/2)
    .text(function(d) { return d.x; }).style("text-anchor", "middle");


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
      .attr("cx", function(d) {  return x(d[p.x]); })
      .attr("cy", function(d) { return y(d[p.y]); })
      .attr("r", 3)
      // this tries to color by a factor variable
      // called factorvar -- not yet implemented
      // if/when implemented it would need a factor legend
      //.style("fill", function(d) { return color(d.groupval); });
      .style("fill", function(d) { return color[d.groupval]; })
      .on("mouseover", function(d) {
          tooltip.transition()
               .duration(200)
               .style("opacity", .9);
          tooltip.html(d.group)// + "<br/> (" + xValue(d)
	        //+ ", " + yValue(d) + ")")
               .style("left", (d3.event.pageX + 1) + "px")
               .style("top", (d3.event.pageY -10) + "px");
      })
      .on("mouseout", function(d) {
          tooltip.transition()
               .duration(500)
               .style("opacity", 0);
      });
    }
}


    function cross(a, b) {
      var c = [], n = a.length, m = b.length, i, j;
      for (i = -1; ++i < n;) for (j = -1; ++j < m;) c.push({x: a[i], i: i, y: b[j], j: j});
      return c;
    }


  },

  resize: function(el, width, height, instance) {

  }

});