# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# Création le 25 mai 2018
#
# Descriptif  : carte avec apparation d'un feu de forêt
#
# Remarques : 
#
# ATTENTION : 
#
# BUG     : 
#
# TODO    : 
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

# == 0 - Setup ========================================

rm(list=ls())
cat("\014")
setwd("C:/Users/Mehdi/Desktop/Vivatech_hand/src/tc2018_hands")

library(shiny)
library(shinythemes) #for beautiful themes
library(shinydashboard) #for box
library(leaflet)
library(ggplot2)
library(data.table)
library(tidyr)
library(dplyr)

# == 1 - Ouverture des données statiques =========================

# Icone du feu
icon_fire = makeIcon(
  iconUrl = "./static/images/icon_fire.png",
  iconWidth = 21.8, iconHeight = 27.2
)

# == 2 - Application cartographique =======================

ui = fluidPage(
  
  #Favicon
  tags$head(tags$link(rel="shortcut icon", href="favicon_transparent.png")),
  
  # Général style
  tags$style("body {background-color:#d5d5d5;}",
             HTML('#panel_controls {background-color: #e4e4e4}')), #only for panel_controls
  
  navbarPage(theme = shinytheme("spacelab"),
             windowTitle = "Forest fire detection app",
             title = div(img(src = "hand_logo.png", 
                             width = "20%",
                             style = "margin:-12px -12px"), #image in www folder
                         "Forest fire detection app"),
                      
  column(width = 9,
         
         # Load leaflet.js
         #tags$head(HTML("<script src='https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/leaflet.js'></script> ")),
         
         leafletOutput("windyty", height = 550, width = 950),
         
         # Setup Windy.Com API
         tags$head(tags$script(
           "
           var windytyInit = {
           // Required: API key
           key: 'PsL-At-XpsPTZexBwUkO7Mx5I',
           
           // Optional: Initial state of the map
           lat: 44,
           lon: 6,
           zoom: 6,

           }
           
           // Required: Windyty main function is called after
           // initialization of API
           //
           // @map is instance of Leaflet maps
           //
           function windytyMain(map) {
           var popup = L.marker()
           //.setLatLng([50.4, 14.3])
           //.setContent('Hello World')
             .setLatLng([44, 7.05])
           .openOn( map );
           }
           "
         )),
         
         # Load map by running the following js script. It creates a Leaflet Map inside windyty div with id = "map_container"
         tags$head(HTML("<script async defer src='https://api.windytv.com/v2.3/boot.js'></script> ")),
         

         
         # Panel contenant les informations relatives au site du détaillant
         absolutePanel(id        = "panel_controls",
                       class     = "panel panel-default", 
                       draggable = FALSE, 
                       top       = 70, #plus il est petit, plus il est haut
                       left      = 1000, 
                       width     = 350, 
                       height    = 550,
                       style     = "color: #fff; border-color: #fff",
                       
                       h4(textOutput("snapshot"), align = "center"),
                       
                       h5(textOutput("text_device"), align = "center"),
                       
                       div(imageOutput("myimage", height = "200px"), style = "margin:12px 10px"),
                       
                       div(textOutput("info_device"), style = "margin:12px 85px"),

                       tags$head(tags$style("#info_device{color: red;font-weight: bold;font-size: 15px}")),
                       
                       div(actionButton(inputId = "call911", 
                                        label = "Emergency call",
                                        icon = icon("earphone", lib = "glyphicon"), 
                                        style = "color: #fff; border-color: #000; margin:60px 90px; height:60px; width:180px;position:absolute;bottom:1em;")
                           )
                       )
         )
  )
)

# == Server ====================================================

server = shinyServer(function(input, output, session) {
  
  # Gonna read a file each second
  vals = reactiveValues(counter = 0)
  
  # File containing fire localisation
  loc_fire_to_display = reactive({
    invalidateLater(millis = 1000, session)
    vals$counter = isolate(vals$counter) + 1
    
    fread("./static/images/geo_loc_on_fire.csv", data.table = FALSE, encoding = 'UTF-8')
    
  })
  
  # Carte
  output$windyty <- renderLeaflet({
    
    # Fond de carte
    leaflet(options = leafletOptions(zoomControl = FALSE, dragging = FALSE, 
                                     minZoom = 6, maxZoom = 6)) %>%
      setView(lat= 44, lng = 6, zoom = 6) %>%
      clearMarkers() %>%
      clearShapes()
     # addTiles(urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga", attribution = 'Google')
    
  })
  
  # ASTUCE : avec observe, il est possible de conserver la vue lorsque les paramètres se mettent à jour
  observe({
    
    if(nrow(loc_fire_to_display()) != 0){
    
    leafletProxy("windyty") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addMarkers(lat = loc_fire_to_display()$lat, lng = loc_fire_to_display()$lng, 
                 icon = icon_fire,
                 layerId = loc_fire_to_display()$name) %>%
      addCircles(lng  = loc_fire_to_display()$lng,
                 lat  = loc_fire_to_display()$lat,
                 weight = 5,
                 color = "red",
                 fillOpacity = 0.0,
                 radius = 1e4 * loc_fire_to_display()$proba) 
    }
      })
  
  # Création de l'objet click (sur un feu de foret)
  click = reactive({
    if(is.null(input$windyty_marker_click))
      return()
    return(input$windyty_marker_click)
  })
  
  # Affichage d'une capture d'écran avec le feu de forêt
  output$myimage = renderImage({
    
    if(is.null(input$windyty_marker_click)){
      filename <- normalizePath(file.path("./static/images/empty_transparent.png"))
      list(src = filename, 
           height = 185)
    }else if(grepl(x = click()$id, pattern = "device")){
    filename <- normalizePath(file.path(paste0("./static/images/", click()$id, ".jpg")))
    list(src = filename, 
         height = 185)
    }
    
  }, deleteFile = FALSE)
  
  # Affichage du titre du snapshot
  output$snapshot = renderText({
    if(is.null(input$windyty_marker_click))
      return("")
    
    "Snapshot from the camera"
  })
  
  
  # Nom du device
  output$text_device = renderText({
    if(is.null(input$windyty_marker_click))
      return("")
    
    paste("Device name : ", click()$id)
  })
  
  # Info sur le device
  output$info_device = renderText({
    
    if(is.null(input$windyty_marker_click))
      return()
    
    sprintf("Probability of fire : %.f%% ", 
          100 * loc_fire_to_display() %>% filter(name == click()$id) %>% select(proba))
  })
})

# == Application ==============================================

shinyApp(ui = ui, server = server)

