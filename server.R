#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Extract necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(googlesheets4)


#Calling from google sheets with data and proper authentication
google_sheet_url <- "https://docs.google.com/spreadsheets/d/1ViRLEHmMd9klb-PlNtfv31arjRyBs8VIffK_0sykTtw/edit?usp=sharing"
gs4_auth(cache = ".secrets", email = TRUE, use_oob = TRUE)

#reading data as dataframe, creating vectors with unique values for input selection
job_data <- read_sheet(google_sheet_url)
states <- unique(job_data$State)
year <- unique(job_data$Year)
industry <- unique(job_data$Industry)
job_data$Employed <- lapply(job_data$Employed, function(x) as.numeric(as.character(x)))
job_data$Employed <- unlist(job_data$Employed)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  range_input <- reactive({
    dataset <- subset(job_data, Year == input$slider1)
    dataset <- subset(dataset, State == input$radio)
    dataset <- dataset[order(unlist(dataset$Employed)),]
    dataset
  })
  
  
  
  output$bar <- renderPlot({
    ggplot(data=range_input(), aes(x=reorder(Industry,Employed), y=Employed)) +
      geom_bar(stat="identity") + coord_flip() + xlab("Industry") + ylab("Persons employed (Thousands)") + ggtitle("The most popular industry based on state and year selected")
  })
})
