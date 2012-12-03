class Burst
  constructor: (options) ->
    @title = options.title || ""

    @width = options.width || 300
    @height = options.height || 300

    @radius = Math.min(@width, @height) / 2

    # @color = options.color || d3.interpolateHsl(
    #   d3.hsl("hsl(80,0%,20%)"),
    #   d3.hsl("hsl(80.5,100%,20%)"))

    @color = d3.scale.category20c()

    @formatNumber = d3.format(",d")

    @year = "2013"
    @comparator = options.comparator || (d, year) ->
      Math.max(0, d.values[year] || 0)

    @x = d3.scale.linear()
      .range([0, 2 * Math.PI])

    @y = d3.scale.sqrt()
      .range([0, @radius])

    @container = d3.select("#chart").append("div")
    @container.append("div").attr("class", "title").text(@title)

    @vis = @container.append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("transform", "translate(" + @width / 2 + "," + @height / 2 + ")")

    @nodeDesc = @container.append("div").attr("class", "nodeDesc").text("")

    @partition = d3.layout.partition()
      .value( (d) => @comparator(d, @year) )
      .children( (d) -> return d.values )

    @arc = d3.svg.arc()
      .startAngle((d)  => Math.max(0, Math.min(2 * Math.PI, @x(d.x))) )
      .endAngle((d)    => Math.max(0, Math.min(2 * Math.PI, @x(d.x + d.dx))) )
      .innerRadius((d) => Math.max(0, @y(d.y)) )
      .outerRadius((d) => Math.max(0, @y(d.y + d.dy)) );

    @label = (d) ->
      d.key + " : " + @formatNumber(d.value * 1000)

    @load()

  setYear: (year) =>
    @click(@path[0])
    @year = year
    @update()

  load: ->
    # Read data
    d3.csv "/data/2013_byradets_forslag_drift.csv", (data) =>

      @tree = d3.nest()
        .key((d) -> d.Avdelingsnavn)
        .key((d) -> d.Kapittelnavn)        
        .key((d) -> d.Artsgruppenavn)
        .rollup((d) -> 
          el = d[0]
          ["2013", "2014", "2015", "2016"].map (year) ->
            el[year] = d.reduce ((pre, el, index, array) -> pre + +el[year]),0
          el
          )
        .entries(data)

      @tree = 
        values: @tree
        key: "Sum " + @title 

      # console.info(tree)
      # console.info(tree.values[0].values[0].values[0].values)
      # console.info(@width)
      # console.info(@vis)

      @update()

  update: ->
    # console.info("updating")

    @path = @vis.data([@tree]).selectAll("path").data(@partition.nodes)
    @path.exit().remove()
    @path.transition().attr("d", @arc)
    @path.enter().append("path")
      .attr("d", @arc)
      .style("fill", (d) => @color(d.key))
      .on("click", @click)
      .on("mouseover", (d) => @nodeDesc.text(@label(d)))
      .on("mouseout", (d) => @nodeDesc.text(""))
      .append("svg:title")
        .text( (d) => @label(d) )


  click: (d) =>
    @path.transition()
      .duration(750)
      .attrTween("d", @arcTween(d))

  # Interpolate the scales!
  arcTween: (d) => 
    xd = d3.interpolate(@x.domain(), [d.x, d.x + d.dx])
    yd = d3.interpolate(@y.domain(), [d.y, 1])
    yr = d3.interpolate(@y.range(), [(if d.y == 0 then 0 else 40), @radius])

    return (d, i) => 
      if i == 0
        (t) => 
          @arc(d)
      else
        (t) => 
          @x.domain(xd(t))
          @y.domain(yd(t)).range(yr(t))
          return @arc(d)

window.Burst = Burst
