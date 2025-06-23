


library(shiny)
library(jsonlite)
library(httr)
library(tidyverse)
library(lubridate)

source("data/spots_and_countries.R")
source("data/coords_by_spot.R")
source("data/spot_info.R")

color_wheel <- colorRampPalette(c(
  "#E0FFFF",  # Light Cyan (0°)
  "#1E90FF",  # Dodger Blue (~120°)
  "#00008B",  # Dark Blue (~240°)
  "#E0FFFF"   # Light Cyan again (360°)
))(100)


ui <- fluidPage(
  titlePanel("Surf Spot Analysis Made Simple"),
  hr(),
  h4("About This Application"),
  p("This app provides comprehensive insights into global wave and swell conditions, empowering surfers and researchers to explore, analyze, and understand ocean dynamics with ease."),
  

  sidebarLayout(
    sidebarPanel(
      
      selectInput("country", "🌐 Country", choices = names(spots_by_country)),
      uiOutput("spot_ui"),  # placeholder for the dynamic spot input
      actionButton("view", "view forecast!"),
      
      hr(), 
      
      h4("Spot Summary"),
      textOutput("spot_summary"),
      
      hr(),
      h6("🌊 Powered by"),
      tags$a(
        href = "https://open-meteo.com/",
        "Open-Meteo Marine API",
        target = "_blank"
      )
    ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel("Annual Wave Variation", 
                 fluidRow(
                   column(12, plotOutput("wave_height_yearly"))
                    )
                 ),
        
       # tabPanel("Data Table",  
      #           tableOutput("trial")
       #          ), 
        
        tabPanel("Wave-Swell Correlation",
                 fluidRow(
                   column(12, plotOutput("wave_vs_swell")),
                   #column(12, plotOutput("wave_period_plot"))
                    )
                 ),
        tabPanel("Wind vs Swell Influence",
                 fluidRow(
                   column(12, plotOutput("swell_dir")),
                   column(12, plotOutput("wind_waves"))
                    )
                 ),
      )
    )
  )
)



server <- function(input, output) {
  
  # responsive function that maps user input -> lat/lng of actual spot
  output$spot_ui <- renderUI({
    req(input$country)  # make sure a country is selected first
    selectInput("spot", "🌊 Surf Spot", choices = spots_by_country[[input$country]])
  })
  
  # Store the daily data reactively
  daily_data <- reactiveVal()
  
  observeEvent(input$view, {
    req(input$spot)
    
    coords <- spot_coords[[input$spot]]
    lat <- coords["lat"]
    lng <- coords["lng"]
    
    url <- paste0(
      "https://marine-api.open-meteo.com/v1/marine?",
      "latitude=", lat,
      "&longitude=", lng,
      "&daily=wave_height_max,wave_direction_dominant,wave_period_max,",
      "swell_wave_height_max,swell_wave_direction_dominant,swell_wave_period_max,",
      "wind_wave_height_max,wind_wave_direction_dominant,wind_wave_period_max",
      "&start_date=2024-01-01",
      "&end_date=2024-12-31",
      "&timezone=auto"
    )
    
    shinyjs::disable("view")  # requires shinyjs package
    on.exit(shinyjs::enable("view"))
    
    tryCatch({
      response <- jsonlite::fromJSON(url)
      
      if (!is.null(response$daily)) {
        daily <- as.data.frame(response$daily)
        names(daily) <- c(
          "date", 
          "wave_height_max", 
          "wave_direction_dominant", 
          "wave_period_max",
          "swell_height_max", 
          "swell_direction_dominant", 
          "swell_period_max",
          "wind_wave_height_max",
          "wind_wave_direction_dominant",
          "wind_wave_period_max"
        )
        daily_data(daily)  # store in reactiveVal
      } else {
        # Handle case where daily data is missing
        daily_data(NULL)
        showNotification("No daily data returned from API.", type = "error")
      }
    }, error = function(e) {
      # Handle errors like connection problems, JSON parsing issues, etc.
      daily_data(NULL)
      showNotification(paste("Error fetching data:", e$message), type = "error")
    })
    
  })
  
  # Render the preview table
  output$trial <- renderTable({
    req(daily_data())
    head(daily_data(), 10)
  })
  
  output$spot_summary <- renderText({
    req(input$spot)
    
    info <- spot_info[[input$spot]]
    if (is.null(info)) {
      return("No description available for this spot.")
    }
    paste("You've selected:", input$spot, "\n\n", info)
  })
  
  # shows how swell height influences wave height
  output$wave_vs_swell <- renderPlot({
    req(daily_data())
    
    ggplot(daily_data(), aes(
      x = swell_height_max, 
      y = wave_height_max, 
      size = wave_period_max, 
      color = wave_direction_dominant
    )) +
      geom_point(alpha = 0.8) +
      scale_color_gradientn(
        colours =  color_wheel,
        limits = c(0, 360),
        guide = guide_colorbar(title = "Wave Direction (°)")
      ) +
      labs(
        title = "Wave Height vs Swell Height",
        x = "Swell Height (m)",
        y = "Wave Height (m)",
        color = "Wave Direction (°)",     
        size = "Wave Period (s)"          
      ) +
      theme_minimal() +
      theme(plot.title = element_text(size=18),
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"))
      
  })
  
  # shows how wave height differs around the year
  output$wave_height_yearly <- renderPlot({
    req(daily_data())
    
    ggplot(daily_data(), aes(
      x = ymd(date),
      y = wave_height_max,
      color = wave_height_max,
      size = wave_height_max
    )) +
      geom_point(alpha=0.8) +
      scale_x_date(date_labels = "%b %Y")+
      labs(
        title = "Wave height differences in a year",
        x = "Date",
        y = "Wave Height (m)",
      )+
      theme_minimal()+
      theme(plot.title = element_text(size=18),
            legend.position = "none",
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"))
  })
  
  # shows the height of wind-waves in relation to actual waves at the spot
  output$wind_waves <- renderPlot({
    req(daily_data())
    
    ggplot(daily_data(), aes(x = ymd(date))) +
      geom_line(aes(y = wave_height_max, color = "Total Wave Height")) +
      geom_line(aes(y = wind_wave_height_max, color = "Wind Wave Height")) +
      labs(
        title = "Total vs Wind-Generated Wave Heights Over Time",
        x = "Date",
        y = "Wave Height (m)",
        color = "Wave Type"
      ) +
      scale_color_manual(
        values = c(
          "Total Wave Height" = "darkblue",
          "Wind Wave Height" = "cyan3"
        )
      ) +
      theme_minimal()+
      theme(plot.title = element_text(size=18),
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"))
  })
  
  #wave height over wave period -> not super useful
  output$wave_period_plot <- renderPlot({
    req(daily_data())
    
    ggplot(daily_data(), aes( 
      x = wave_period_max,
      y = wave_height_max,
      color = wave_direction_dominant,
      size = wave_period_max
    ))+
      geom_point(alpha=0.8)+
      scale_color_gradientn(
        colours =  color_wheel,
        limits = c(0, 360),
        guide = guide_colorbar(title = "Wave Direction (°)")
      ) +
      labs(
        title = "Wave Period vs Wave Height",
        x = "Wave Period (s)",
        y = "Wave Height (m)",
        color = "Wave Direction (°)",     
        size = "Wave Period (s)"          
      ) +
      theme_minimal()
  })
  
  #at which swell direction does the spot work best?
  output$swell_dir <- renderPlot({
    req(daily_data())
    
    ggplot(daily_data(), aes(
      x = swell_direction_dominant,
      y = wind_wave_direction_dominant,
      size = wave_height_max,
      color = wave_height_max,
    ))+
      geom_point(alpha=0.8)+
      labs(
        title = "Wave Height by Swell Direction",
        x = "Dominant Swell Direction (°)",
        y = "Dominant Wind Wave Direction (°)",
        size = "Wave Height (m)",
        color = "Wave Height (m)"
      )+
      theme_minimal()+
      theme(plot.title = element_text(size=18),
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"))
    
  })
}

shinyApp(ui = ui, server = server)
