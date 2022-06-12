library(shiny)
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


# Define UI for application that asks for year and state and spits out employment based on industry at specified year and state
shinyUI(fluidPage(

  
  titlePanel("Malaysia's most desirable jobs"),
  plotOutput("bar",height = 500),
  fluidRow(column(2, 
                  sliderInput("slider1", h3("Select year in slider to filter based on year"), sep = "", ticks = FALSE,
                              min = min(year), max = max(year), value = max(year)),
                  # here the slider allows to keep a max, min and a set value to start the app with
                  radioButtons("radio", h3("Select the state in Malaysia to see the popular industry in the state"),
                               choices = as.list(states))
                  # and here the radio button allows to add a list with the element it will contain
                  
  )
  )
))
