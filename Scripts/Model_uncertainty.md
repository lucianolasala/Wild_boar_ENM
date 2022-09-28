### Model standard deviation and range
----------

#### <ins>Model standard deviation</ins>

```r
sa_wgs <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.gpkg") 

sa_ctroids1 <- cbind(sa_wgs, st_coordinates(st_centroid(sa_wgs)))
sa_ctroids2 <- sa_ctroids1 %>% 
mutate(NAME = case_when(NAME == "BOLIVIA" ~ "BO", 
                        NAME == "PARAGUAY" ~ "PY",
                        NAME == "URUGUAY" ~ "UY",
                        NAME == "ARGENTINA" ~ "AR",
                        NAME == "BRAZIL" ~ "BR"))

# Create mosaic using SD layers for calibration and projection areas

calSD <- raster("./Final_model_rasters/cal_area_sd.tif") 
projSD <- raster("./Final_model_rasters/proj_area_sd.tif")
mosaico <- mosaic(calSD, projSD, fun = mean)
writeRaster(mosaico,"./Final_model_rasters/Mosaic_SD.tif", overwrite=TRUE)
mosaic_masked <- crop(mosaico, sa_wgs) %>% mask(sa_wgs)

writeRaster(mosaic_masked,"./Final_model_rasters/Mosaic_SD_no_isl.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaico <- raster("./Final_model_rasters/Mosaic_SD_no_isl.tif")

full_pts <- rasterToPoints(mosaico, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

p <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
geom_sf(data = sa_wgs, alpha = 0, color = "black", size = 0.5) +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "SD") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.8, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14),
legend.title.align=0.5) + 
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME), size = 6,
family = "sans", fontface = "bold", color = "white") +
annotate(geom = "text", x=-72.5, y=-38, label="CL", size = 6, color="white", family = "sans", fontface = "bold") +
ggsn::scalebar(data = sa_wgs, location = "bottomright", anchor = c(x = -50, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")

p

ggsave(plot = p, "./Plots/Continuous models/Model_SD.png", width = 8.3, height = 11.7)
```

#### <ins>Model range</ins>

```r
sa_wgs <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.gpkg") 

sa_ctroids1 <- cbind(sa_wgs, st_coordinates(st_centroid(sa_wgs)))
sa_ctroids2 <- sa_ctroids1 %>% 
  mutate(NAME = case_when(NAME == "BOLIVIA" ~ "BO", 
  NAME == "PARAGUAY" ~ "PY",
  NAME == "URUGUAY" ~ "UY",
  NAME == "ARGENTINA" ~ "AR",
  NAME == "BRAZIL" ~ "BR"))

# Create mosaic using SD layers for calibration and projection areas

cal_range <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_Model_Stats/Statistics_E/Scenario_cal_range.tif") 
proj_range <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_Model_Stats/Statistics_E/Scenario_proj_range.tif")

mosaico <- mosaic(cal_range, proj_range, fun = mean)
writeRaster(mosaico,"./Final_model_rasters/Mosaic_range.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaico <- raster("./Final_model_rasters/Mosaic_SD_no_isl.tif")

full_pts <- rasterToPoints(mosaico, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

p <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
geom_sf(data = sa_wgs, alpha = 0, color = "black", size = 0.5) +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Range") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.8, 0.25)) +
theme(legend.key.height = unit(1.5, 'line'),
legend.key.width = unit(2, 'line'), 
legend.title = element_text(size = 16, face = "bold"),
legend.text = element_text(size = 14),
legend.title.align = 0.5) + 
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME), size = 6, family = "sans", fontface = "bold", color = "white") +
annotate(geom = "text", x=-72.5, y=-38, label="CL", size = 6, color="white", family = "sans", fontface = "bold") +
ggsn::scalebar(data = sa_wgs, location = "bottomright", anchor = c(x = -50, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")

p

ggsave(plot = p, "./Plots/Continuous models/Model_range.png", width = 8.3, height = 11.7)
```
