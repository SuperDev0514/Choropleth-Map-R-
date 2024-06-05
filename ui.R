#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(leaflet)
library(plotly)
library(bslib)
library(fmsb)
library(maps)
library(mapproj)
library(colourpicker)

# Define UI for application that draws a histogram
fluidPage(
  tags$head(
    tags$style(HTML("
      .center-title {
        text-align: center;
      }
      .title-description {
        text-align: center;
        font-size: 20px;
      }
      .sub-description {
        text-align: center;
        font-size: 15px;
      }
    "))
  ),
    titlePanel(
      tags$div("My Shiny App", class = "center-title")
    ),
    card(  
      tags$div("My description", class = "title-description")    
    ),
    hr(),
    fluidRow(
      column(3,
             wellPanel(
               h3("Choropleth Map"),
               hr(),
               selectInput("choropleth_statistic", "Select Data:", choices = c("Theft number", "Population", "Median household income", "Crime rate"), selected ="Theft number" ),
               sliderInput("choropleth_year", "Select Year:", min = 2010, max = 2024, value = 2022)

             )
      ),
      column(6,
             wellPanel(
               leafletOutput("choroplethMap"), 
               textOutput("hoverInfo")
             ),
             card(  
               tags$div("description1", class = "sub-description")    
             )
      ),
      column(3,
             card(
               card_title(tags$div("tutorial", class = "sub-description")),
               tags$div("Choropleth Map", class = "sub-description")
             ) 
      )
    ),
    
    hr(),
    
    fluidRow(
      column(3,
             wellPanel(
               h3("Radar Chart"),
               hr(),
               sliderInput("radar_year", "Select Year:", min = 2020, max = 2024, value = 2022),
               colourInput("pcol", "Select Polygon Color:", value = "red"),
               colourInput("pfcol", "Select Fill Color:", value = "skyblue")

             )
      ),
      column(6,
             wellPanel(
               plotOutput("radar_Chart"),

             ),
             card(  
               tags$div("description2", class = "sub-description")    
             )
      ),
      column(3,
             card(
               card_title(tags$div("tutorial", class = "sub-description")),
               tags$div("Radar Chart", class = "sub-description")    
             ) 
      )
    ),
    
    hr(),
    fluidRow(
      column(3,
             wellPanel(
               h3("Bar Chart"),
               hr(),
               selectInput("bar_filter", "Filter by:", choices = c("Make", "Model"), selected = "Make"),
            
             )
      ),
      column(6,
             wellPanel(
               plotOutput("bar_chart")
             
             ),
             card(  
               tags$div("description3", class = "sub-description")    
             )
      ),
      column(3,
             card(
               card_title(tags$div("tutorial", class = "sub-description")),
               tags$div("Bar Chart", class = "sub-description")
             ) 
      )
    )
    
)
