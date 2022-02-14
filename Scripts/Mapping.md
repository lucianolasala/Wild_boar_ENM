#### Mapping of Ecological Niche Models

##### Packages and libraries 
```r
library(tidyverse)
library(stars)
library(sf)
library(paletteer)
library(gridExtra)
library(readr)
library(magrittr)
library(raster)
```
#### Geographic representation of ENM (JMB)

```r
occ <- read_delim("./Occurrences/S_scrofa_thinned.csv", delim = ",") %>%
  filter(!is.na(lon),
         !is.na(lat)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

dt1 <- read_stars("./Final_models/cal_area_mean.tif")
dt2 <- read_stars("./Final_models/proj_area_mean.tif")

make.plot <- function(dt, zmin = NA, zmax = NA, title = "", plot.obs = TRUE) {
  
  if(is.na(zmin) | is.na(zmax)) {
    zmin <- min(dt[[1]], na.rm = TRUE)
    zmax <- max(dt[[1]], na.rm = TRUE)
  }
  
  pl <- ggplot() +
    geom_stars(data = dt) +
    coord_sf() +
    scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent",
                                n.breaks = 9, limits = c(zmin, zmax)) +
    labs(x = "Longitud", y = "Latitud", fill = "Suitabilidad") +
    ggtitle(title) +
    theme_bw()
  
  if(plot.obs) {
    pl <- pl +
      geom_sf(data = occ, size = .5, colour = "black", alpha = 0.5)
  }
  
  return(pl)
  
}

p1 <- ggplot() +
  geom_stars(data = dt1) +
  geom_sf(data = occ, size = .5, colour = "black", alpha = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitud", y = "Latitud", fill = "Suitability") +
  theme_bw()

p2 <- ggplot() +
  geom_stars(data = dt2) +
  geom_sf(data = occ, size = .5, colour = "black") +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitud", y = "Latitud", fill = "Suitabilidad") +
  theme_bw()

ggsave(plot = p1, "./Plots/Predition_calibration.png", width = 8.3, height = 11.7)
ggsave(plot = p2, "./Plots/Predition_projection.png", width = 8.3, height = 11.7)
```

#### Geographic representation of ENM (LFLS)

```r
# Loading wild boar records
occ <- read_delim("./Occurrences/S_scrofa_thinned.csv", delim = ",") %>%
  filter(!is.na(lon),
         !is.na(lat)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# Loading calibration and projection areas
dt1 <- raster("./Final_models/cal_area_mean.tif")
dt2 <- raster("./Final_models/proj_area_mean.tif")

# Loading study region
sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina and bordering countries.shp")
class(sa)
st_crs(sa)  # Coordinate Reference System: NA

# Assign CRS to sa
# Create a CRS object to define the CRS of our sf object

# Set CRS and then pass it on to sa_wgs  
sa_crs <- st_crs(4326)
sa_wgs = sa %>% st_set_crs(sa_crs)
st_crs(sa_wgs)
class(sa_wgs)

write_sf(sa_wgs, "D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")

# Merging rasters
full <- raster::merge(dt1, dt2)

# Converting to a df for plotting, in two steps:
# First, to a SpatialPointsDataFrame
full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, make it into a conventional dataframe
full_df  <- data.frame(full_pts)
head(full_df)

p3 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
  geom_sf(data = occ, size = .5, colour = "black", alpha = 0.5) +
  geom_sf(data = sa_wgs, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitud", y = "Latitud", fill = "Suitability") +
  theme_bw()
p3

ggsave(plot = p3, "./Plots/Final_plot.png", width = 8.3, height = 11.7)

# Mapping without wild boar records
p4 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
  geom_sf(data = sa_wgs, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitud", y = "Latitud", fill = "Suitability") +
  theme_bw()
p4

p4 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
  geom_sf(data = sa_wgs, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.8, 0.25)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), #change legend title font size
        legend.text = element_text(size = 14)) #change legend text font size
p4

ggsave(plot = p4, "./Plots/Final_plot_wo_wb.png", width = 8.3, height = 11.7)
```

#### Mapping thresholded model

```r
sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")
sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Saco Malvinas
sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
               case_when(NAME == "ARGENTINA" ~ "Arg", 
                         NAME == "BOLIVIA" ~ "Bol",
                         NAME == "BRAZIL" ~ "Bra",
                         NAME == "CHILE" ~ "Chi",
                         NAME == "PARAGUAY" ~ "Par",
                         NAME == "URUGUAY" ~ "Uru"))
  
# Load thresholded calibration and projection areas
dt1 <- raster("./Final_models/cal_area_median_thresh_5.tif")
dt2 <- raster("./Final_models/proj_area_median_thresh_5.tif")

# Merging rasters
full <- raster::merge(dt1, dt2)
class(full)

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame
full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, to a conventional dataframe
full_df  <- data.frame(full_pts
full_bin = full_df %>% mutate(Group =
                    case_when(layer == 0 ~ "Absence", 
                              layer == 1 ~ "Presence")) 

p5 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), #change legend title font size
        legend.text = element_text(size = 14)) + #change legend text font size
        scale_fill_manual(values=c("#ffff66","#ff0066")) +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
  p5

ggsave(plot = p5, "./Plots/Final_plot_thresh.png", width = 8.3, height = 11.7)
```
#### Binary representation  of mobility oriented parity (MOP) analysis

```r
sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")
sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Depete Malvinas
sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
                                        case_when(NAME == "ARGENTINA" ~ "Arg", 
                                                  NAME == "BOLIVIA" ~ "Bol",
                                                  NAME == "BRAZIL" ~ "Bra",
                                                  NAME == "CHILE" ~ "Chi",
                                                  NAME == "PARAGUAY" ~ "Par",
                                                  NAME == "URUGUAY" ~ "Uru"))

# Loading MOP rasters for calibration and projection areas
dt1 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_cal.tif")
dt2 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_proj.tif")

# Merging rasters
full <- raster::merge(dt1, dt2)

# Converting to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame
full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, transform into a "conventional" dataframe

full_df  <- data.frame(full_pts)

full_bin = full_df %>% mutate(Group =
                                case_when(layer == 0 ~ "Present", 
                                          layer <= 1 ~ "Absent")) 
head(full_bin)

p6 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
        labs(fill = "Extrapolation risk") +
  scale_fill_manual(values=c("#ffff66","#ff0066")) +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
p6

ggsave(plot = p6, "./Plots/MOP_binary.png", width = 8.3, height = 11.7)
```

#### Continuous representation  of mobility oriented parity (MOP) analysis

```r
sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")
sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Delete Malvinas
sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
                                        case_when(NAME == "ARGENTINA" ~ "Arg", 
                                                  NAME == "BOLIVIA" ~ "Bol",
                                                  NAME == "BRAZIL" ~ "Bra",
                                                  NAME == "CHILE" ~ "Chi",
                                                  NAME == "PARAGUAY" ~ "Par",
                                                  NAME == "URUGUAY" ~ "Uru"))

# Loading MOP rasters for calibration and projection areas
dt1 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_cal.tif")
dt2 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_proj.tif")

# Merging rasters
full <- raster::merge(dt1, dt2)

# Converting to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame
full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, transform into a conventional dataframe
full_df  <- data.frame(full_pts)

p7 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
  labs(fill = "Extrapolation risk") +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
p7

ggsave(plot = p7, "./Plots/MOP_continuous.png", width = 8.3, height = 11.7)
```

#### Mapping study region

```r
eco_cal <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Ecorregions_study_region_occ_dissolved.shp")
eco_proj <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Ecorregions_study_region_wo_occ_dissolved.shp") 

countries <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina and bordering countries.shp")
st_crs(countries)  # Coordinate Reference System: NA

count_crs = st_crs(4326)
countries_WGS = countries %>% st_set_crs(count_crs)
st_crs(countries_WGS)

sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(countries_WGS)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Delete Malvinas

sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
                                        case_when(NAME == "ARGENTINA" ~ "Arg", 
                                                  NAME == "BOLIVIA" ~ "Bol",
                                                  NAME == "BRAZIL" ~ "Bra",
                                                  NAME == "CHILE" ~ "Chi",
                                                  NAME == "PARAGUAY" ~ "Par",
                                                  NAME == "URUGUAY" ~ "Uru"))


p8 <- ggplot() +
  geom_sf(data = eco_cal, alpha = 1, color = "black", size = 0.5, aes(fill = NAME), show.legend = T) +
  geom_sf(data = eco_proj, alpha = 1, color = "black", size = 0.5, aes(fill = NAME), show.legend = T) + 
  geom_sf(data = countries_WGS, alpha = 0, color = "#e60000", size = 0.4) +
  scale_fill_manual(values = c("#2ECC71","#FFFFFF")) +
  labs(x = "Longitude", y = "Latitude") +
  coord_sf() +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
  labs(fill = "Area") +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
  
p8  

ggsave(plot = p8, "./SA_cal_proj.png", width = 8.3, height = 11.7)``r
```