#### Mapping of Ecological Niche Models

##### Packages and libraries 
```r
library(ggsn)
library(tidyverse)
library(stars)
library(sf)
library(paletteer)
library(gridExtra)
library(readr)
library(magrittr)
library(raster)
library(ggplot2)
library(paletteer)
library(dplyr)

```
#### Suitability in all countries (includes biodiversity hotspots)

```r
sa <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.gpkg")
mal <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Malvinas_Estados.gpkg")

# Define CRS for layer "sa" by creating a CRS object to define the CRS of our sf object

sa_crs <- st_crs(4326)
sa %>% st_set_crs(sa_crs)
st_crs(sa)

sa_wgs = sa %>% st_set_crs(sa_crs)
st_crs(sa_wgs)

write_sf(sa_wgs, "D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.gpkg")

sa_wgs <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.gpkg") 

sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
length(sa_ctroids1$NAME)
sa$NAME

sa_ctroids2 <- sa_ctroids1 %>% 
mutate(NAME = case_when(NAME == "BOLIVIA" ~ "BO", 
                        NAME == "PARAGUAY" ~ "PY",
                        NAME == "URUGUAY" ~ "UY",
                        NAME == "ARGENTINA" ~ "AR",
                        NAME == "BRAZIL" ~ "BR"))
                    
# Loading biodiversity hotspots                                                  
af <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Atlantic Forest.gpkg")  
ce <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Cerrado.gpkg")
cr <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Chilean Rainfall Forests.gpkg")
ta <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Tropical Andes.gpkg")

# Load mosaic of whole model and study region

mosaico <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(mosaico, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

p <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = sa, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = af, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = ce, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = cr, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = ta, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22), 
      axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
      axis.text.x = element_text(colour = "black", size = 18),
      axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.8, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
      legend.key.height = unit(2, 'line'),
      legend.key.width = unit(1.5, 'line'), 
      legend.title = element_text(size = 16, face = "bold"), 
      legend.text = element_text(size = 14)) +
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME), size = 6,
          family = "sans", fontface = "bold") +
annotate(geom = "text", x=-51.8, y=-25, label="AF", size = 6, color="black", fontface = "bold") +
annotate(geom = "text", x=-53, y=-18, label="CE", size = 6, color="black", fontface = "bold") +
annotate(geom = "text", x=-72, y=-34.5, label="CF", size = 6, color="black", fontface = "bold") +
annotate(geom = "text", x=-67, y=-20, label="TA", size = 6, color="black", fontface = "bold") +
annotate(geom = "text", x=-72.5, y=-38, label="CL", size = 6, color="black", family = "sans", fontface = "bold") +
  scalebar(data = sa, location = "bottomright", anchor = c(x = -50, y = -55), dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Continuous models/Figure 1aa.png", width = 8.3, height = 11.7)
```