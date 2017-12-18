library(shiny)
library(datasets)
library(quantmod)
library(PerformanceAnalytics)

## Intialize DAX data
AdjustedPrice = 6
.GDAXI = getSymbols('^GDAXI', warnings = FALSE, auto.assign = FALSE)
GDAXI = na.fill(.GDAXI, fill = "extend")[,AdjustedPrice, drop=FALSE]


# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  
  # Return the requested dataset
  datasetInput <- reactive({
    
    
     .stockdata = getSymbols(input$stock_id, warnings = FALSE, auto.assign = FALSE)
     stockdata = na.fill(.stockdata, fill = "extend")[, AdjustedPrice, drop=FALSE]
     
     stockdata = merge (GDAXI, stockdata)

     no_of_datapoints = dim(stockdata)[1]
     
     min = input$range[1]/100 * no_of_datapoints
     max = input$range[2]/100 * no_of_datapoints
     
     # AdjustedPrice
     out = stockdata[min:max,]
     
     return (out)
  })
  
  
  # generate a plot
  output$timeseries <- renderPlot({

    AdjustedPrice <- datasetInput()
    
    Returns <- AdjustedPrice/lag(AdjustedPrice, 1) -1
    charts.PerformanceSummary(Returns)
    
  })
  
  output$histogram.GDAXI <- renderPlot({
    
    AdjustedPrice <- datasetInput()[,1,drop=FALSE]
    Returns <- AdjustedPrice/lag(AdjustedPrice, 25) -1
    
    chart.Histogram(Returns, methods = c( "add.density", "add.normal"), xlim = c(-0.4, 0.4))
    
  })
  
  output$histogram.stockdata <- renderPlot({
    
    AdjustedPrice <- datasetInput()[,2,drop=FALSE]
    Returns <- AdjustedPrice/lag(AdjustedPrice, 25) -1
    
    chart.Histogram(Returns, methods = c( "add.density", "add.normal"), xlim = c(-0.4, 0.4))
    
  })
  
  output$boxplot <- renderPlot({
    
    AdjustedPrice <- datasetInput()
    Returns <- AdjustedPrice/lag(AdjustedPrice, 25) -1
    
    chart.Boxplot(Returns)
    
  })
  

})