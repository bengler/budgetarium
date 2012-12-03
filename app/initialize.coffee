# App Namespace
# Change `Hipster` to your app's name
@Hipster ?= {}
Hipster.Routers ?= {}
Hipster.Views ?= {}
Hipster.Models ?= {}
Hipster.Collections ?= {}

$ ->
    # Load App Helpers
    require '../lib/app_helpers'
    require './burst'

    # Initialize App
    Hipster.Views.AppView = new AppView = require 'views/app_view'

    # Initialize Backbone History
    Backbone.history.start pushState: yes

    expenditureOptions =
      title: "Utgifter"
      width: 400
      height: 400
      comparator: (d, year) -> Math.max(0, d.values[year] || 0)
      color: d3.interpolateHsl(d3.hsl("hsl(20,20%,30%)"),
                               d3.hsl("hsl(20.5,100%,25%)"))

    incomeOptions =
      title: "Inntekter"
      width: 400
      height: 400
      comparator: (d, year) -> (Math.min(0, d.values[year]) || 0) * -1
      color: d3.interpolateHsl(d3.hsl("hsl(83,80%,30%)"),
                               d3.hsl("hsl(83.5,100%,25%)"))

    charts = [new Burst(expenditureOptions), new Burst(incomeOptions)]

    setChartYear = (year) ->
      charts.map( (c) -> c.setYear(year))

    $("span#2013").click () -> setChartYear("2013")
    $("span#2014").click () -> setChartYear("2014")
    $("span#2015").click () -> setChartYear("2015")
    $("span#2016").click () -> setChartYear("2016")
