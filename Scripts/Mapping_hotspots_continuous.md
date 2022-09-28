### Mapping of ecological niche model for biodiversity hotspots

```r
library(sf)
library(raster)
library(magrittr)
library(ggplot2)
library(oompaBase)
library(paletteer)
```

#### Atlantic Forest

```r
af <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Atlantic_Forest.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

mosaic_masked <- crop(mosaic, af) %>% mask(af)
full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

af <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = af, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.85, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"),
legend.text = element_text(size = 14)) + #change legend text font size
ggsn::scalebar(data = af, location = "bottomright", anchor = c(x = -40, y = -32.5),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
annotate(geom = "text", x=-57, y=-3, label = "A", size = 8, color = "black") + theme(plot.margin = unit(c(0.4,0,0.4,0), "cm"))

af

ggsave(plot = af, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Atlantic Forest.png", width = 8.3, height = 10)
```

#### Cerrado 

```r
hs <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/NAME_Cerrado.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

mosaic_masked <- crop(mosaic, hs) %>% mask(hs)
full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

ce <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = hs, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.1, 0.2)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(1.5, 'line'), 
legend.key.width = unit(1, 'line'), 
legend.title = element_text(size = 14, face = "bold"), 
legend.text = element_text(size = 12)) + 
ggsn::scalebar(data = hs, location = "bottomright", anchor = c(x = -40, y = -25),
dist = 250,  st.size = 4, height = 0.015, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
theme(plot.margin = unit(c(0,0.5,0,0.5), "cm")) +
annotate(geom = "text", x=-62, y=-4, label="B", size = 8, color="black")

ce

ggsave(plot = ce, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Cerrado.png", width = 8.3, height = 8.3)
```

#### Chilean Winter Rainfall and Valdivian Forests continuous 

```r
hs <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Chilean_Rainfall_Forests.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

mosaic_masked <- crop(mosaic, hs) %>% mask(hs)

full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

ch <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = hs, alpha = 0, color = "black", size = 0.4) +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.85,0.2)) +
theme(legend.key.height = unit(2.4,'line'), 
legend.key.width = unit(2.2,'line'), 
legend.title = element_text(size = 20, face = "bold"), 
legend.text = element_text(size = 18)) + 
coord_sf(xlim = c(-78,-65), ylim = c(-22.5,-47.5), expand = TRUE) +
ggsn::scalebar(data = hs, location = "bottomright", anchor = c(x = -66, y = -47),
dist = 150,  st.size = 6, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
annotate(geom = "text", x=-77, y=-23, label = "C", size = 10, color="black") +
theme(plot.margin = unit(c(0,1,0.5,0.5), "cm"))

ch

ggsave(plot = ch, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Chilean_Winter_Rainfall.png", width = 8.3, height = 17)
```

#### Tropical Andes 

```r
hs <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Tropical_Andes.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

mosaic_masked <- crop(mosaic, hs) %>% mask(hs)
full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

trop <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = hs, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
 scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.2,0.3)) +
theme(legend.key.size = unit(2,'line'), 
legend.key.height = unit(2,'line'), 
legend.key.width = unit(1.5,'line'), 
legend.title = element_text(size = 16, face = "bold"), 
        legend.text = element_text(size = 14)) +
ggsn::scalebar(data = hs, location = "bottomright", anchor = c(x = -72, y = -29),
dist = 150,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
annotate(geom = "text", x=-64, y=-13, label = "D", size = 10, color="black") +
theme(plot.margin = unit(c(0,1,0.5,0.5), "cm"))

trop

ggsave(plot = trop, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Tropical_Andes.png", width = 8.3, height = 12)
```
