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
  tags$style("body {background-color:#d5d5d5;}",
             HTML('#panel_controls {background-color: #e4e4e4}')), 
  
  navbarPage(theme = shinytheme("spacelab"),
             title=div(img(src="hand_logo.png",  
                           width = "20%",
                       style = "margin:-12px -12px"), #image in www folder
  "Forest fire detection app"),
                      
  # Beautiful graphics
  #tags$head(
    # Include our custom CSS
    #includeCSS("./src/flatly_styles.css")
    #includeScript("./src/gomap.js")
  #),
  
  column(width = 9,
         
         leafletOutput("mymap", height = 550, width = 950),
  
  # Panel contenant les informations relatives au site du détaillant
  absolutePanel(id        = "panel_controls", 
                class     = "panel panel-default", 
                draggable = FALSE, 
                top       = 70, #plus il est petit, plus il est haut
                left      = 1000, 
                width     = 350, 
                height    = 550,
                style = "color: #fff; border-color: #fff",
                
                h4(textOutput("snapshot"), align = "center"),
                
                h5(textOutput("text_device"), align = "center"),
                
                div(imageOutput("myimage", height = "200px"), style = "margin:12px 10px"),
                
                div(textOutput("info_device"), style = "margin:12px 90px"),
                tags$head(tags$style("#info_device{color: red;
                                 font-size: 15px}"
                         )
                ),
                
                div(actionButton(inputId = "call911", 
                                 label = "Call 911",
                                 icon = icon("earphone", lib = "glyphicon"), 
                   # style = "margin:12px 120px"
                    style="color: #fff; border-color: #000; margin:60px 120px; height:60px; width:120px;position:absolute;bottom:1em;")
                )
                
  )
)
)
)


# == Server ====================================================

server = shinyServer(function(input, output, session) {
  
  # Gonna read a file each second
  vals <- reactiveValues(counter = 0)
  
  # File containing fire localisation
  loc_fire_to_display = reactive({
    invalidateLater(millis = 1000, session)
    vals$counter <- isolate(vals$counter) + 1
    
    fread("./static/images/geo_loc_on_fire.csv", data.table = FALSE, encoding = 'UTF-8')
    
    
  })
  
  # Carte
  output$mymap <- renderLeaflet({
    
    # Fond de carte
    leaflet() %>%
      setView(lat= 44, lng = 6, zoom = 8) %>%
      addTiles(urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga", attribution = 'Google')
    
  })
  
  # ASTUCE : avec observe, il est possible de conserver la vue lorsque les paramètres se mettent à jour
  observe({
    
    leafletProxy("mymap") %>%
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
      })
  
  # Création de l'objet click (sur un feu de foret)
  click = reactive({
    if(is.null(input$mymap_marker_click))
      return()
    return(input$mymap_marker_click)
  })
  
  # Affichage d'une capture d'écran avec le feu de forêt
  output$myimage = renderImage({
    
    if(is.null(input$mymap_marker_click)){
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
    if(is.null(input$mymap_marker_click))
      return("")
    
    "Snapshot from the camera"
  })
  
  
  # Nom du device
  output$text_device = renderText({
    if(is.null(input$mymap_marker_click))
      return("")
    
    paste("Device name : ", click()$id)
  })
  
  # Info sur le device
  output$info_device = renderText({
    
    if(is.null(input$mymap_marker_click))
      return()
    
    sprintf("Probability of fire : %.f%% ", 
          100 * loc_fire_to_display() %>% filter(name == click()$id) %>% select(proba))
    
   
  })
})

# == Application ==============================================

shinyApp(ui = ui, server = server)

