### Mapping of Ecological Niche Models

#### Packages and libraries 
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
#### Suitability in study region (includes biodiversity hotspots)

```r
sr <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.shp")
mal <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Malvinas_Estados.gpkg")

sa_ctroids <- cbind(sr, st_coordinates(st_centroid(sr)))
sa_ctroids1 <- sa_ctroids %>% 
  mutate(COUNTRY = case_when(NAME == "ARGENTINA" ~ "AR", 
  NAME == "BOLIVIA" ~ "BO",
  NAME == "BRAZIL" ~ "BR",
  NAME == "PARAGUAY" ~ "PY",
  NAME == "URUGUAY" ~ "UY"))

# Biodiversity hotspots

af <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Atlantic_Forest.gpkg")  
ce <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Cerrado.gpkg")
cr <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Chilean_Rainfall_Forests.gpkg")
ta <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Tropical_Andes.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

ras <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

full_pts <- rasterToPoints(ras, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% mutate(Group =
                              case_when(Thresh_mosaic_MSS == 0 ~ "Absence", 
                                        Thresh_mosaic_MSS == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = sr, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = mal, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = af, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = ce, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = cr, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = ta, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.75, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"),
legend.text = element_text(size = 14)) + #change legend text font size
annotate(geom = "text", x=-51.8, y=-25, label="AF", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-53, y=-18, label="CE", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-72, y=-34.5, label="CF", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-67, y=-20, label="TA", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-72.5, y=-38, label="CL", size = 6, color="black", family = "sans", fontface = "bold") +
geom_text(data = sa_ctroids1, aes(X, Y, label = COUNTRY), size = 6, family = "sans", fontface = "bold") + 
ggsn::scalebar(data = sr, location = "bottomright", anchor = c(x = -50, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Threshold models/Study_region_thresh_new.png", width = 8.4, height = 12)
```

#### Argentina

```r
arg <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Arg_adm1.shp")
st_crs(arg)  # Coordinate Reference System: WGS 84
arg$NAME_1

mosaico <- raster("./Final_model_rasters/Study_region_thresh.tif")
sa_ctroids <- cbind(arg, st_coordinates(st_centroid(arg)))

sa_ctroids1 <- sa_ctroids %>% 
  mutate(NAME_1 = case_when(NAME_1 == "Buenos Aires" ~ "B", 
  NAME_1 == "Córdoba" ~ "X",
  NAME_1 == "Catamarca" ~ "K",
  NAME_1 == "Chaco" ~ "H",
  NAME_1 == "Chubut" ~ "U",
  NAME_1 == "Corrientes" ~ "W",
  NAME_1 == "Entre Ríos" ~ "E",
  NAME_1 == "Formosa" ~ "P",
  NAME_1 == "Jujuy" ~ "Y",
  NAME_1 == "La Pampa" ~ "L",
  NAME_1 == "La Rioja" ~ "F",
  NAME_1 == "Mendoza" ~ "M",
  NAME_1 == "Misiones" ~ "N",
  NAME_1 == "Neuquén" ~ "Q",
  NAME_1 == "Río Negro" ~ "R",
  NAME_1 == "San Juan" ~ "J",
  NAME_1 == "San Luis" ~ "D",
  NAME_1 == "Santa Cruz" ~ "Z",
  NAME_1 == "Santa Fe" ~ "S",
  NAME_1 == "Santiago del Estero" ~ "G",
  NAME_1 == "Tierra del Fuego" ~ "V",
  NAME_1 == "Tucumán" ~ "T"))

# Crop and mask 

arg_masked <- crop(mosaico, arg) %>% mask(arg)

writeRaster(arg_masked,"./Final_model_rasters/ENM_argentina_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

arg_ras <- raster("./Final_model_rasters/ENM_argentina_thresh.tif")
full_pts <- rasterToPoints(arg_ras, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% mutate(Group =
                              case_when(ENM_argentina_thresh == 0 ~ "Absence", 
                                        ENM_argentina_thresh == 1 ~ "Presence")) 

# Plot without wild boar records

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = arg, alpha = 0, color = "black", size = 0.5) +
coord_sf() +
scale_x_continuous(limits = c(-75,-50)) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.75, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14)) + #change legend text font size
geom_text(data = sa_ctroids1, aes(X, Y, label = NAME_1), size = 6, family = "sans", fontface = "plain") + 
annotate(geom="text", x=-67, y=-24.5, label="A", size = 7, color="black") +
ggsn::scalebar(data = arg, location = "bottomright", anchor = c(x = -55, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") +
theme(plot.margin = margin(1,0.1,0.4,0, "cm"))

p

ggsave(plot = p, "./Plots/Threshold models/Argentina_thresh.png", width = 8.4, height = 12)
```