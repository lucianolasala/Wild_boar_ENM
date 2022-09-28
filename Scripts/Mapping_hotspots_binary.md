### Mapping binary ENM for biodiversity hotspots

#### style="text-decoration:underline">Atlantic Forest</span>

```r
af <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Atlantic_Forest.gpkg")  

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

# Crop and mask

mosaic_masked <- crop(mosaic, af) %>% mask(af)

full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
head(full_df)

full_bin = full_df %>% 
  mutate(Group = case_when(Thresh_mosaic_MSS == 0 ~ "Absence", 
                           Thresh_mosaic_MSS == 1 ~ "Presence")) 
                           
p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = af, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.8, 0.25)) +
theme(legend.key.size = unit(2, 'line'), # Change legend key size
legend.key.height = unit(2, 'line'), # Change legend key height
legend.key.width = unit(1.5, 'line'), # Change legend key width
legend.title = element_text(size = 16, face = "bold"), #change legend title font size
legend.text = element_text(size = 14)) + #change legend text font size
ggsn::scalebar(data = af, location = "bottomright", anchor = c(x = -40, y = -32.5),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
theme(plot.margin = unit(c(0.4,0,0.4,0), "cm"))

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Atlantic_Forest_binary.png", width = 8.3, height = 10)
```

#### Cerrado

```r
ce <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Cerrado.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

# Crop and mask

mosaic_masked <- crop(mosaic, ce) %>% mask(ce)

full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(Thresh_mosaic_MSS == 0 ~ "Absence", 
                           Thresh_mosaic_MSS == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = ce, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.25, 0.85)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'),
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14)) + #change legend text font size
ggsn::scalebar(data = ce, location = "bottomright", anchor = c(x = -40, y = -25),
dist = 250, st.size = 4, height = 0.015, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
theme(plot.margin = unit(c(0,0.4,0,0.5), "cm"))

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Cerrado_binary.png", width = 8.3, height = 8.3)
```

#### Chilean Winter Rainfall and Valdivian Forests

```r
cr <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Chilean Rainfall Forests.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

# Crop and mask

mosaic_masked <- crop(mosaic, cr) %>% mask(cr)
full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(Thresh_mosaic_MSS == 0 ~ "Absence", 
                           Thresh_mosaic_MSS == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = cr, alpha = 0, color = "black", size = 0.4) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.8, 0.15)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14)) + 
coord_sf(xlim = c(-78,-65), ylim = c(-22.5,-47.5), expand = TRUE) +
ggsn::scalebar(data = cr, location = "bottomright", anchor = c(x = -66, y = -47),
dist = 150,  st.size = 6, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
theme(plot.margin = unit(c(0,1,0.5,0.5), "cm"))

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Chilean_Winter_Rainfall_binary.png", width = 8.3, height = 17)
```

#### Tropical Andes

```r
ta <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Tropical Andes.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

# Crop and mask

mosaic_masked <- crop(mosaic, ta) %>% mask(ta)

full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(Thresh_mosaic_MSS == 0 ~ "Absence", 
                           Thresh_mosaic_MSS == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = ta, alpha = 0, color = "black", size = 0.4) +
coord_sf() + 
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.2, 0.2)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'),
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14)) + #change legend text font size
ggsn::scalebar(data = ta, location = "bottomright", anchor = c(x = -72, y = -29),
dist = 150,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") + 
theme(plot.margin = unit(c(0,1,0.5,0.5), "cm"))

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual hotspots/Tropical_Andes_binary.png", width = 8.3, height = 12)
```