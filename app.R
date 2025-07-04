library(shiny)
library(jsonlite)
library(httr)
library(tidyverse)
library(lubridate)
library(leaflet)
library(plotly)

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
  p("This app offers detailed insights into global wave and swell conditions, enabling surfers and researchers to explore, compare, and analyze ocean dynamics effortlessly. For spot comparisons, please select Spot 1 before choosing Spot 2 to ensure proper functionality."),
  

  sidebarLayout(
    sidebarPanel(
      
      selectInput("country", "🌐 Country", choices = names(spots_by_country)),
      uiOutput("spot_ui"),  # placeholder for the dynamic spot input
      uiOutput("go_button"), #with this button the api is called
      # this is mainly a button so that the api server isn't spammed 
      
      hr(),
      leafletOutput("map", height = "200px"),
      
      hr(), 

      h6("🌊 Powered by"),
      tags$a(
        href = "https://open-meteo.com/",
        "Open-Meteo Marine API",
        target = "_blank"
      )
    ),
    
    mainPanel(
      tabsetPanel(id="tabs",
        tabPanel("Single Spot Analysis", value = "single",
                 
                 tags$head(
                   tags$style(HTML(
                   "
                  .plot-container {
                  transition: transform 0.3s ease;
                  cursor: pointer;
                  padding: 10px;
                  }
                  .plot-container:hover {
                  transform: scale(1.1);
                  z-index: 999;
                  }
                 "))
                   ),
    
                 fluidPage(
                   fluidRow(
                     #column(4, div(class = "plot-container", plotOutput("wave_vs_swell"))),
                     column(6, div(class = "plot-container", plotOutput("grouped_bar"))),
                     column(6, div(class = "plot-container", plotOutput("wave_height_period"))),
                     
                   ),
                   fluidRow(
                     column(6, div(class = "plot-container", plotOutput("wind_rose"))),
                     #column(6, div(class = "plot-container", plotOutput("swell_dir"))),
                     column(6, div(class = "plot-container", plotOutput("swell_rose")))
                   )
                 ),

                 ),
        
        tabPanel("Spot Comparison", value = "multi",
                 fluidRow(
                   column(6, div(class = "plot-container", plotOutput("multi_height_over_date"))),
                   column(6, div(class = "plot-container", plotOutput("swell_bouquet")))
                 ),
                 fluidRow(
                   
                 )
        )
      )
    )
  )
)



server <- function(input, output) {
  
  ############## TEXTS
  
  output$not_implemented <- renderText({
    "This feature is not implemented yet!"
  })
  tab_selected <- reactive({ input$tabs })
  
  ############# DYNAMIC INPUTS
  
  
  output$spot_ui <- renderUI({
    req(input$country)
    req(input$tabs)
    
    spots <- spots_by_country[[input$country]]
    
    if (input$tabs == "multi") {
      spot1_selected <- input$spot1 %||% spots[1]  # use existing or default first spot
      
      # Exclude spot1 from spot2 choices
      spots_for_2 <- setdiff(spots, spot1_selected)
      
      spot2_selected <- input$spot2
      if (is.null(spot2_selected) || !(spot2_selected %in% spots_for_2)) {
        spot2_selected <- spots_for_2[1]
      }
      
      tagList(
        selectInput("spot1", "🌊 Surf Spot 1", choices = spots, selected = spot1_selected),
        selectInput("spot2", "🌊 Surf Spot 2", choices = spots_for_2, selected = spot2_selected)
      )
    } else {
      selectInput("spot", "🌊 Surf Spot", choices = spots)
    }
  })
  
  

  
  #dynamic button for dynamic interface
  output$go_button <- renderUI({
    req(input$tabs)
    
    if (input$tabs == "multi") {
      actionButton("go_multi", "🔄 Compare")
    } else {
      actionButton("go_single", "🔍 Analyse")
    }
  })
  
  ############### SINGLE API CALL 
  
  # Store the daily data reactively
  daily_data <- reactiveVal()

  #one spot api call -> daily_data
  observeEvent(input$go_single, {
    req(input$spot,input$tabs == "single")
    
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

    shinyjs::disable("go_single")
    on.exit(shinyjs::enable("go_single"))
    
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
    #print("Triggered single-spot API call")
  })
  
  ############# MULTI API CALL
  
  # store multi-spot data reactively
  multi_spot <- reactiveVal()
  
  # two spot api call
  observeEvent(input$go_multi, {
    req(input$spot1, input$tabs == "multi")
    req(input$spot2, input$tabs == "multi")
    
    coords_1 <- spot_coords[[input$spot1]]
    lat1 <- coords_1["lat"]
    lng1 <- coords_1["lng"]
    
    url1 <- paste0(
      "https://marine-api.open-meteo.com/v1/marine?",
      "latitude=", lat1,
      "&longitude=", lng1,
      "&daily=wave_height_max,wave_direction_dominant,wave_period_max,",
      "swell_wave_height_max,swell_wave_direction_dominant,swell_wave_period_max,",
      "wind_wave_height_max,wind_wave_direction_dominant,wind_wave_period_max",
      "&start_date=2024-01-01",
      "&end_date=2024-12-31",
      "&timezone=auto"
    )
    coords_2 <- spot_coords[[input$spot2]]
    lat2 <- coords_2["lat"]
    lng2 <- coords_2["lng"]
    
    url2 <- paste0(
      "https://marine-api.open-meteo.com/v1/marine?",
      "latitude=", lat2,
      "&longitude=", lng2,
      "&daily=wave_height_max,wave_direction_dominant,wave_period_max,",
      "swell_wave_height_max,swell_wave_direction_dominant,swell_wave_period_max,",
      "wind_wave_height_max,wind_wave_direction_dominant,wind_wave_period_max",
      "&start_date=2024-01-01",
      "&end_date=2024-12-31",
      "&timezone=auto"
    )

    #diable buttons while loading
    shinyjs::disable("go_multi")
    on.exit(shinyjs::enable("go_multi"))
    
    tryCatch({
      # Fetch both responses
      response1 <- jsonlite::fromJSON(url1)
      response2 <- jsonlite::fromJSON(url2)
      
      # Check if both have daily data
      if (!is.null(response1$daily) && !is.null(response2$daily)) {
        
        daily1 <- as.data.frame(response1$daily)
        daily2 <- as.data.frame(response2$daily)
        
        # Standardize column names
        names(daily1) <- names(daily2) <- c(
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
        
        # Store them separately in the reactiveVals
        multi_spot(bind_rows(
          daily1 %>% mutate(spot = input$spot1),
          daily2 %>% mutate(spot = input$spot2)
        ))
        
      } else {
        multi_spot(NULL)
        showNotification("One or both spots returned no daily data.", type = "error")
      }
    }, error = function(e) {
      multi_spot(NULL)
      showNotification(paste("Error fetching data:", e$message), type = "error")
    })
    
    #print("✅riggered multi-spot API call")
  })
  
  output$trial_multi <- renderTable({
    req(multi_spot())
    head(multi_spot(), 10)
  })
  
  ############## PLOTS AND TABLES SINGLE 
  
  #short info text for each spot
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
        #title = "Wave Height vs Swell Height",
        x = "Swell Height (m)",
        y = "Wave Height (m)",
        color = "Wave Direction (°)",     
        size = "Wave Period (s)"          
      ) +
      theme_minimal() +
      theme(plot.title = element_text(size=18),
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"),
            legend.position = "bottom",
            legend.box = "vertical")
      
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
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"),
            legend.position = "bottom",
            legend.box = "vertical")
  })
  
  # grouped bar chart that shows wave heights 
  output$grouped_bar <- renderPlot({
    req(daily_data())
    
    monthly_data <- daily_data() %>%
      mutate(month = lubridate::floor_date(lubridate::ymd(date), "month")) %>%
      group_by(month) %>%
      summarise(
        `Total Wave Height` = mean(wave_height_max, na.rm = TRUE),
        `Wind Wave Height` = mean(wind_wave_height_max, na.rm = TRUE),
        `Swell Wave Height` = mean(swell_height_max, na.rm = TRUE)
      ) %>%
      pivot_longer(
        cols = c(`Total Wave Height`, `Wind Wave Height`, `Swell Wave Height`),
        names_to = "Wave_Type",
        values_to = "Height"
      ) %>%
      mutate(
        Wave_Type = recode(Wave_Type,
                           "Total Wave Height" = "Total",
                           "Wind Wave Height" = "Wind",
                           "Swell Wave Height" = "Swell")
      )
    
    ggplot(monthly_data, aes(x = month, y = Height, fill = Wave_Type)) +
      geom_bar(
        stat = "identity",
        width = 25,
        position = position_dodge(width = 30)
      ) +
      labs(
        x = "Month",
        y = "Wave Height (m)",
        fill = "Type"
      ) +
      scale_fill_manual(
        values = c(
          "Total" = "#264653",
          "Wind" = "khaki",
          "Swell" = "#2A9D8F"
        )
      ) +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 18),
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"),
        legend.position = "bottom"
      )
  })
  
  # at which swell direction does the spot work best?
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
        #title = "Wave Height by Swell Direction",
        x = "Dominant Swell Direction (°)",
        y = "Dominant Wind Wave Direction (°)",
        size = "Wave Height (m)",
        color = "Wave Height (m)"
      )+
      theme_minimal()+
      theme(plot.title = element_text(size=18),
            plot.margin = unit(c(top = 1, right = .5, bottom = 1, left = .5), "cm"),
            legend.position = "bottom",
            legend.box = "vertical")
    
  })
  
  # interactive map
  output$map <- renderLeaflet({
    req(input$country)
    
    spots <- spots_by_country[[input$country]]
    if (is.null(spots)) return(NULL)
    
    coords <- lapply(spots, function(spot) spot_coords[[spot]])
    
    df <- data.frame(
      spot = spots,
      lat = sapply(coords, function(x) x['lat']),
      lng = sapply(coords, function(x) x['lng'])
    )
    
    # Set default spot selections
    selected_spots <- character(0)
    colors <- c()
    
    if (input$tabs == "multi") {
      spot1 <- input$spot1
      spot2 <- input$spot2
      
      if (!is.null(spot1)) {
        selected_spots <- c(selected_spots, spot1)
        colors <- c(colors, "#00798C")
      }
      if (!is.null(spot2)) {
        selected_spots <- c(selected_spots, spot2)
        colors <- c(colors, "#66C2A5")
      }
    } else if (input$tabs == "single") {
      spot <- input$spot
      if (!is.null(spot)) {
        selected_spots <- c(selected_spots, spot)
        colors <- c(colors, "#1F78B4")
      }
    }
    
    # Separate selected and unselected spots
    df_selected <- df[df$spot %in% selected_spots, ]
    df_unselected <- df[!df$spot %in% selected_spots, ]
    
    map <- leaflet() %>%
      addTiles() %>%
      
      # Add default (unselected) markers
      addCircleMarkers(
        data = df_unselected,
        ~lng, ~lat,
        color = "gray",
        radius = 4,
        stroke = FALSE,
        fillOpacity = 0.8,
        popup = ~spot
      )
    
    # Add selected markers with their respective colors
    if (nrow(df_selected) > 0) {
      for (i in seq_len(nrow(df_selected))) {
        map <- map %>%
          addCircleMarkers(
            lng = df_selected$lng[i],
            lat = df_selected$lat[i],
            color = colors[i],
            radius = 6,
            stroke = FALSE,
            fillOpacity = 1,
            popup = df_selected$spot[i]
          )
      }
    }
    
    if (nrow(df) > 0) {
      # Compute bounds for all spots in the country
      country_bounds <- list(
        c(min(df$lat), min(df$lng)),  # Southwest corner
        c(max(df$lat), max(df$lng))   # Northeast corner
      )
      
      map <- map %>%
        fitBounds(
          lng1 = country_bounds[[1]][2], lat1 = country_bounds[[1]][1],
          lng2 = country_bounds[[2]][2], lat2 = country_bounds[[2]][1]
        )
    } else {
      # No data → default to some generic view
      map <- map %>%
        setView(lng = 0, lat = 0, zoom = 2)
    }
    
    map
  })
  
  
  # wave height / wave period with wind-wave-height analysis
  output$wave_height_period <- renderPlot({
    req(daily_data())
    
    ggplot(daily_data(), aes(x = wave_period_max, y = wave_height_max, size = swell_height_max, color=wind_wave_height_max))+
      geom_point()+
      labs(
        x= "Wave Period (s)",
        y= "Wave Height (m)",
        #title="Wave Height over Wave Period",
        size="Swell Height",
        color ="Wind Wave Height"
      )+
      scale_color_gradient(low = "#264653", high = "khaki3")+
      theme_minimal()+
      theme(legend.position = "bottom",
            legend.box = "vertical")
  })
  
  output$wind_rose <- renderPlot({
    req(daily_data())
    
    # Bin directions into 30° intervals
    wind_data <- daily_data() %>%
      mutate(
        dir_bin = cut(
          wind_wave_direction_dominant,
          breaks = seq(0, 360, by = 30),
          include.lowest = TRUE,
          right = FALSE,
          labels = paste(seq(0, 330, by = 30), "°")
        )
      ) %>%
      group_by(dir_bin) %>%
      summarise(count = n(), .groups = "drop")
    
    # Create rose plot
    ggplot(wind_data, aes(x = dir_bin, y = count)) +
      geom_bar(stat = "identity", fill = "khaki", color = "black", width = 1) +
      coord_polar(start = -pi/12) +  # rotate to put 0° at top
      theme_minimal() +
      labs(
        title = "Wind",
        x = NULL,
        y = "Count"
      ) +
      theme(
        axis.text.x = element_text(size = 10),
        panel.grid.major.y = element_line(color = "gray85"),
        panel.grid.minor = element_blank(),
        legend.position = "bottom",
        legend.box = "vertical"
      )
  })
  
  output$swell_rose <- renderPlot({
    req(daily_data())
    
    
    # Bin directions into 30° intervals
    swell_data <- daily_data() %>%
      mutate(
        dir_bin = cut(
          swell_direction_dominant,
          breaks = seq(0, 360, by = 30),
          include.lowest = TRUE,
          right = FALSE,
          labels = paste(seq(0, 330, by = 30), "°")
        )
      ) %>%
      group_by(dir_bin) %>%
      summarise(count = n(), .groups = "drop")
    
    # Create rose plot
    ggplot(swell_data, aes(x = dir_bin, y = count)) +
      geom_bar(stat = "identity", fill = "#2A9D8F", color = "black", width = 1) +
      coord_polar(start = -pi/12) +  # rotate to put 0° at top
      theme_minimal() +
      labs(
        title = "Swell",
        x = NULL,
        y = "Count"
      ) +
      theme(
        axis.text.x = element_text(size = 10),
        panel.grid.major.y = element_line(color = "gray85"),
        panel.grid.minor = element_blank(),
        legend.position = "bottom",
        legend.box = "vertical"
      )
  })
  
  ################### MULTI SPOT COMPARISION
  
  #multi wave height analysis 
  output$multi_height_over_date <- renderPlot({
    req(multi_spot())
    
    multi <- multi_spot() %>%
      mutate(month = lubridate::floor_date(as.Date(date), "month")) %>%
      group_by(month, spot) %>%
      summarise(avg_wave = mean(wave_height_max, na.rm = TRUE), .groups = "drop") %>%
      arrange(month)
    
    #color palette multi comparision
    spot_colors <- setNames(
      c("#00798C", "#66C2A5"),  # Spot1 = deep teal blue, Spot2 = seafoam green
      c(input$spot1, input$spot2)
    )

    
    ggplot(multi, aes(
      x = month,
      y = avg_wave,
      fill = spot
    )) +
      geom_col(position = position_dodge(width = 20), width = 20) +  # grouped bars
      labs(
        x = "Month",
        y = "Average Monthly Wave Height (m)",
        fill = "Spot"
      ) +
      theme_minimal() +
      scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom",
        legend.box = "vertical"
      )+
      scale_fill_manual(values = spot_colors) 
  })
  
  
  #multi wave direction analysis
  output$swell_bouquet <- renderPlot({
    req(multi_spot())

    
    swell_data <- multi_spot() %>%
      mutate(
        dir_bin = cut(
          swell_direction_dominant,
          breaks = seq(0, 360, by = 30),
          include.lowest = TRUE,
          right = FALSE,
          labels = paste(seq(0, 330, by = 30), "°")
        )
      ) %>%
      filter(!is.na(dir_bin)) %>%  # remove NA bins if any
      group_by(spot, dir_bin) %>%
      summarise(count = n(), .groups = "drop")
    
    #color palette multi comparision
    spot_colors <- setNames(
      c("#00798C", "#66C2A5"),  # Spot1 = deep teal blue, Spot2 = seafoam green
      c(input$spot1, input$spot2)
    )
    
    ggplot(swell_data, aes(x = dir_bin, y = count, fill = spot)) +
      geom_bar(stat = "identity", color = "black", position = "identity", alpha = 0.5, width = 1) +
      coord_polar(start = -pi/12) +  # rotate so 0° is at top
      theme_minimal() +
      scale_fill_manual(values = spot_colors) +
      labs(
        title = "Swell",
        x = NULL,
        y = "Count",
        fill = "Spot"
      ) +
      theme(
        axis.text.x = element_text(size = 10),
        panel.grid.major.y = element_line(color = "gray85"),
        panel.grid.minor = element_blank(),
        legend.position = "bottom",
        legend.box = "vertical"
      )
    
  })
}

shinyApp(ui = ui, server = server)
