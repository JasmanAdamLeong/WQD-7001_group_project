#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Extract necessary libraries
library(shinycustomloader)
library(plotly)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(dplyr)
library(shiny)
library(googlesheets4)
library(ggplot2)
library(gghighlight)
library(reshape2)
library(tidyr)


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
shinyServer(function(input, output, session) {
    range_input <- reactive({
      dataset <- subset(job_data, Year == input$slider1)
      dataset <- subset(dataset, State == input$radio)
      dataset <- dataset[order(unlist(dataset$Employed)),]
      dataset
    })
    
    line_input <- reactive({
      dataset <- subset(job_data, Industry == input$select1)
      dataset <- subset(dataset, State %in% input$radio2)
      dataset <- subset(dataset, select = -c(Industry))
      dataset <- pivot_wider(dataset, names_from="State",values_from = "Employed")
      dataset <- melt(dataset, id="Year")
      dataset
    })
    
    output$bar <- renderPlotly({
      
      ggplot(data=range_input(), aes(x=reorder(Industry,Employed), y=Employed)) +
        geom_bar(fill = "coral",  stat="identity") + coord_flip() + xlab("Industry") + ylab("Employed (Thousands)") +
        theme(text = element_text(size = 15))      
    })
    
    
    output$line <- renderPlotly({
      
      ggplot(data=line_input(), aes(x= Year, y = value,  colour = variable)) +
        geom_line()+
        labs(x = "Years", y = "Employed (Thousands)", title = "Industry over time")
    }) 
    
    
    output$summary <- renderPrint({
      summary(dataset())
    })
    
    output$table <- renderTable({
      dataset.frame(x=dataset())
    })
    
    # display 10 rows initially
    output$dataTable <- DT::renderDataTable({
      DT::datatable(job_data, options = list(pageLength = 25))
    })
    
    
  })
