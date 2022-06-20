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


# Define UI for application that asks for year and state and spits out employment based on industry at specified year and state
shinyUI(fluidPage(
    theme = shinytheme("flatly"),
    titlePanel("Job Sniffer"),
    hr(),
    tabsetPanel(
      id = 'tab',
      
      tabPanel(
        'Line Graph',
        
        h3('Job industry trends from year 2000-2020'),
        p('Select Year and State from below:'),
        
        sidebarLayout(
          sidebarPanel(
            width = 3,
            
            selectizeInput("select1", h3("Select Industry"),
                           choices = as.list(industry)),
            # and here the radio button allows to add a list with the element it will contain
            
            checkboxGroupInput("radio2", h3("Select State"), choices = as.list(states))
            # and here the radio button allows to add a list with the element it will contain
          ),
          mainPanel(
            withLoader(
              plotlyOutput('line', height = 750),
            )
          )
        ),
      ),
      
      tabPanel(
        'Bar Graph',
        
        h3('High demand job industry based on states'),
        p('Select Year and State from below:'),
        
        sidebarLayout(
          sidebarPanel(
            width = 3,
            sliderInput("slider1", h3("Select year"), sep = "",
                        min = min(year), max = max(year), value = c(2005,2017)),
            # here the slider allows to keep a max, min and a set value to start the app with
            
            radioButtons("radio", h3("Select State"),
                         choices = as.list(states))
            # and here the radio button allows to add a list with the element it will contain
          ),
          mainPanel(
            withLoader(
              plotlyOutput('bar', height = 750),
            )
          )
        )
      ),
      
      tabPanel(
        'Data Table', 
        
        p('Below is the data used for this project. You may browse, sort and search in the table below.'),
        
        withLoader(
          DT::dataTableOutput('dataTable'),
        )
      ),
      
      tabPanel(
        'Use Guide',
        
        h3('How to Use The App?'),
        
        tags$ol(
          tags$li('Click', a ('https://', target = '_blank'), 'to Malaysia Most Desirable Jobs.'),
          
          tags$li('There are four (4) different tab panel to check out. Click on each tab to find out more what is available in this App'),
          
          tags$li('The landing page is a line graph that indicate the trends for job industry in Malaysia from year 2000 to 2020.'),
          
          tags$li('Click on Industry to select or deselect the job industry.'),
          tags$img(src = 'selectIndustry.png'),
          
          tags$li('Click on State to select or deselect the state.'),
          tags$img(src = 'selectState.png'),
          
          tags$li('Visualization of the graph from selected variable above.'),
          h4('Line Graph'),
          tags$img(src = 'linegraph.png'),
          
          tags$li('Slide the year'),
          tags$img(src = 'selectYear.png'),
          
          tags$li('Click on State to select or deselect the state.'),
          tags$img(src = 'selectState.png'),
          
          tags$li('Visualization of the graph from selected variable above.'),
          h4('Bar Graph'),
          tags$img(src = 'bargraph.png'),
          
          tags$li('The dataset for each states is available under Data Table'),
          tags$img(src = 'datatable.png'),
          
        ),
      )
    ),
  ))
