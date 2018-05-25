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
setwd("C:/Users/Mehdi/Desktop/Vivatech_hand")

library(shiny)
library(leaflet)
library(ggplot2)
library(data.table)
library(tidyr)
library(dplyr)

# == 1 - Ouverture des données =========================

# Icone du feu
icon_fire = makeIcon(
  iconUrl = "./data/icon_fire.png",
  iconWidth = 21.8, iconHeight = 27.2
)

# Localisation des feux
loc_fire = data.frame(lat = c(44),
                      lng = c(7.05))

# == 2 - Application cartographique =======================

ui = fluidPage(
  
  #Titre
  titlePanel("Forest fire detection application"),
  
  column(width = 3,
         
   # Afichage de l'icone feu
   radioButtons(inputId = "display_fire", label = "Fire ?", 
                choiceNames = c("yes", "no"), selected = "no", inline = TRUE,
                choiceValues = c("yes", "no")), 
         
  leafletOutput("mymap", height = 530, width = 950) %>% print,
  
  # Panel contenant les informations relatives au site du détaillant
  absolutePanel(id        = "panel_controls", 
                class     = "panel panel-default", 
                draggable = TRUE, 
                top       = 60, #plus il est petit, plus il est haut
                left      = 1000, 
                width     = 340, 
                height    = 500,
                
                imageOutput("myimage")
  )
  
  )
)

# == Server ====================================================

server = shinyServer(function(input, output, session) {
  
  # Dataframe of localisation of fire wrt input$display_fire
  loc_fire_to_display = reactive({
    if(input$display_fire == "yes"){
      loc_fire
    }else{
      loc_fire %>% filter(lat == 0)
    }
  })
  
  output$mymap <- renderLeaflet({
    
    # Fond de carte
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      setView(lat= 44, lng = 6, zoom = 8) %>%
      #addProviderTiles(providers$Esri.NatGeoWorldMap)
      #addTiles(urlTemplate = "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G", attribution = 'Google')
      addTiles(urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga", attribution = 'Google')
    
  })
  
  # ASTUCE : avec observe, il est possible de conserver la vue lorsque les paramètres se mettent à jour
  observe({
    
    leafletProxy("mymap") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addMarkers(lat = loc_fire_to_display()$lat, lng = loc_fire_to_display()$lng, 
                 icon = icon_fire,
                 layerId = "fire") %>%
      addCircleMarkers(data = loc_fire_to_display(),
                       lng  = ~lng,
                       lat  = ~lat,
                       radius = 25,
                       color = "red",
                       fillOpacity = 0.0,
                       weight = 3) 
  })
  
  # Création de l'objet click (sur un feu de foret)
  click = reactive({
    if(is.null(input$mymap_shape_click))
      return()
    return(input$mymap_shape_click)
  })
  
  # Affichage d'une capture d'écran avec le feu de forêt
  output$myimage = renderImage({
    
    filename <- normalizePath(file.path('./data/frame261.jpg'))
    list(src = filename, 
         contentType = "image/png", 
         height = 185)
    
  }, deleteFile = FALSE)
  
})

# == Application ==============================================

shinyApp(ui = ui, server = server)

