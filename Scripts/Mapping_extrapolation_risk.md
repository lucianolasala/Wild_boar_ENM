### Mapping Output from Extrapolation Risk Analysis
----------

#### <ins>MOP continuous</ins>


```r
rm(list=ls(all=TRUE))

setwd("D:/LFLS/Analyses/Jabali_ENM/Modelling")

sa <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.shp")
mal <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Malvinas_Estados.gpkg")

sa_ctroids <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids1 <- sa_ctroids %>% 
  mutate(COUNTRY = case_when(NAME == "ARGENTINA" ~ "Arg", 
  NAME == "BOLIVIA" ~ "Bol",
  NAME == "BRAZIL" ~ "Bra",
  NAME == "CHILE" ~ "Chi",
  NAME == "PARAGUAY" ~ "Par",
  NAME == "URUGUAY" ~ "Uru"))

# Load MOP rasters for calibration and projection areas

dt1 <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/MOP_analysis/MOP_results/Set_1/MOP_0.5%_Current.tif")

dt1_masked <- crop(dt1, sa) %>% mask(sa)

writeRaster(dt1_masked,"./Final_model_rasters/MOP_0.5%_Current.tif", overwrite=TRUE)

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame

mop <- raster("./Final_model_rasters/MOP_0.5%_Current.tif")
full_pts <- rasterToPoints(dt1, spatial = TRUE)

# Second, to a "conventional" dataframe

full_df  <- data.frame(full_pts)

p <- ggplot() +
geom_raster(data = full_df, aes(x = x, y = y, fill = MOP_0.5._Current)) +
geom_sf(data = sa, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = mal, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.75, 0.25)) +
theme(legend.key.size = unit(2, "line"), 
legend.key.height = unit(2, "line"), 
legend.key.width = unit(1.5, "line"), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14)) + # Change legend text font size
labs(fill = "Extrapolation risk") +
geom_text(data = sa_ctroids1, aes(X, Y, label = COUNTRY), size = 8, family = "sans", fontface = "bold") +
ggsn::scalebar(data = sa, location = "bottomright", anchor = c(x = -50, y = -55),
dist = 250, st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE, model = "WGS84")

p

ggsave(plot = p, "./Plots/MOP/MOP_continuous.png", width = 8.3, height = 11.7)

```  

#### <ins>MOP binary</ins>

```r
sa <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.shp")
mal <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Malvinas_Estados.gpkg")

sa_ctroids <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids1 <- sa_ctroids %>% 
  mutate(COUNTRY = case_when(NAME == "ARGENTINA" ~ "Arg", 
  NAME == "BOLIVIA" ~ "Bol",
  NAME == "BRAZIL" ~ "Bra",
  NAME == "CHILE" ~ "Chi",
  NAME == "PARAGUAY" ~ "Par",
  NAME == "URUGUAY" ~ "Uru"))

# Load MOP rasters for calibration and projection areas

mop <- raster("./Final_model_rasters/MOP_0.5%_Current.tif")

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(mop, spatial = TRUE)

# Second, to a "conventional" dataframe

full_df  <- data.frame(full_pts)
head(full_df)


full_bin = full_df %>% mutate(Group =
                                case_when(MOP_0.5._Current == 0 ~ "Present", 
                                          MOP_0.5._Current <= 1 ~ "Absent")) 
head(full_bin)

plot.new()
p16 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.4) +
  geom_sf(data = mal, alpha = 0, color = "black", size = 0.4) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.25)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
  labs(fill = "Extrapolation risk") +
  scale_fill_manual(values=c("#2ECC71","#FF0000")) +
  geom_text(data = sa_ctroids1, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold") + 
  ggsn::scalebar(data = sa, location = "bottomright", anchor = c(x = -50, y = -55),
           dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")
p16

ggsave(plot = p16, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/MOP/MOP_binary.png", width = 8.3, height = 11.7)
```
