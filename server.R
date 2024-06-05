#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(leaflet)
library(plotly)
library(dplyr)
library(readxl)
library(fmsb)
library(ggplot2)
library(sf)
library(maps)
library(mapdata)
library(rlang)
library(scales)
library(RColorBrewer)
library(geojsonio)
library(tigris)
source("helpers.R")
counties <- read.csv("data/Choropleth California_County_Boundaries.csv")
bar_data <- read_xlsx("data/Bar Chart - Vehicle Type Stolen.xlsx")
statistic_data <- read_xlsx("data/Choropleth - Statistics.xlsx")
radar_data <- read_xlsx("data/SpiderRadar Chart - Time of Day Nationwide.xlsx")
ca_counties <- counties(state = "CA", cb = TRUE)

# Print the resulting object to verify
counties <- counties %>%
  left_join(statistic_data,  by = c("CountyName" = "COUNTY"))

counties <- counties %>%
  distinct(CountyName, .keep_all = TRUE)

ca_merged <- ca_counties %>%
  left_join(counties, by = c("NAME" = "CountyName"))
print(ca_merged)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  
  bar_data <- bar_data %>%
    mutate(`MANUFACTURE YEAR Group` = cut(`MANUFACTURE YEAR`, breaks = seq(min(`MANUFACTURE YEAR`), max(`MANUFACTURE YEAR`), by = 5), include.lowest = TRUE, right = FALSE))
  
  observe({
    
  req(input$choropleth_statistic)
    
  data <- switch (input$choropleth_statistic,
                  "Theft number" = "Theft",
                  "Population" = "Population",
                  "Median household income" = "Income",
                  "Crime rate" = "Crime_rate",
                  stop("Invalid input$choropleth_statistic")
  )
  
  print(data)
  # Ensure the selected variable data is numeric and handle missing data
  if (!is.numeric(ca_merged[[data]])) {
    ca_merged[[data]] <- as.numeric(ca_merged[[data]])
  }
  ca_merged[[data]][is.na(ca_merged[[data]])] <- 0
  
  # Define color palette based on the selected variable
  palette <- colorNumeric(
    palette = "YlOrRd",
    domain = ca_merged[[data]],
    na.color = "transparent"
  )

  output$choroplethMap <- renderLeaflet({
    leaflet(ca_merged) %>%
      addTiles() %>%
      setView(lng = -119.4179, lat = 36.7783, zoom = 6) %>%
      addPolygons(
      fillColor = ~palette(ca_merged[[data]]),
      weight = 1,
      opacity = 1,
      color = "white",
      dashArray = "3",
      fillOpacity = 0.7,
      highlightOptions = highlightOptions(
        weight = 5,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE
      ),
      label = ~paste(NAME," : ", input$choropleth_statistic, ":", ca_merged[[data]])) %>%
      addLegend(
        pal = palette,
        values = ~ca_merged[[data]],
        opacity = 0.7,
        title = input$choropleth_statistic,
        position = "bottomleft"
      )
      
  })
  })
  

    output$hoverInfo <- renderText({
      "Hover over a county for more details."
    })
    
    
    output$radar_Chart <- renderPlot({
      
      radar_data <- radar_data[radar_data$Year == input$radar_year, ]
      theft_data <- as.data.frame(radar_data$TheftNumber)
      # Ensure there are at least 3 unique values
      if (length(unique(theft_data)) < 3) {
        fill_colors <- brewer.pal(3, name = "Set3")
      } else {
        fill_colors <- brewer.pal(n = length(unique(theft_data)), name = "Set3")
      }     
      data <- rbind(rep(60000, ncol(theft_data)), rep(20000, ncol(theft_data)), t(theft_data))
      data <- as.data.frame(data)
      colnames(data) <- c("0.00", "23.00" , "22.00" , "21.00" , "20.00" , "19.00", "18.00" , "17.00" , "16.00", "15.00", "14.00", "13.00", "12.00", "11.00", "10.00", "9.00", "8.00", "7.00", "6.00", "5.00", "4.00", "3.00", "2.00", "1.00")
      
      print(data)
      radarchart(data, axistype = 1,
                 # custom polygon
                 pcol = input$pcol, pfcol = input$pfcol, plwd = 1,
                 # custom the grid
                 cglcol = "skyblue", cglty = 1, axislabcol = "grey", caxislabels = seq(20000, 60000, 10000), cglwd = 1,
                 # custom labels
                 vlcex = 0.7)
      legend("bottomright", legend = unique(input$radar_year), fill = unique(fill_colors), title = "Year")

    })
    output$bar_chart <- renderPlot({
      fill_var <- if (input$bar_filter == "Make") "Model" else "Make"
      ggplot(bar_data, aes(x =!!sym(input$bar_filter), y = `NUMBER OF THEFTS`, fill = !!sym(fill_var))) +
        geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
        facet_wrap(~ `MANUFACTURE YEAR Group`, scales = "free_x") +
        coord_flip() +
        theme_minimal() +
        labs(title = paste("Number of Thefts by", input$bar_filter),
             x = input$bar_filter,
             y = "Number of Thefts",
             fill = fill_var)
    })
    
    

}
