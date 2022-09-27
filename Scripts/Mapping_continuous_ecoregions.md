### Mapping of ecological niche model for individual ecoregions

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
library(colorspace)
library(RColorBrewer)
```

```r
ecoregiones <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Ecoregions/Ecoregions_study_region_final.gpkg")

mosaico <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

eco_names <- unique(ecoregiones$ECO_NAME)

eco_names <- gsub("/", " ", eco_names)

plot_ecorregion <- function(masked_df, eco){
plot <- ggplot() +
geom_tile(data = masked_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = eco, alpha = 0, color = "black") +
coord_sf() +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +  # title = eco$ECO_NAME
theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12),
axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0), size = 12), 
axis.text.x = element_text(colour = "black", size = 8),
axis.text.y = element_text(colour = "black", size = 8))      
ggsave(plot = plot, paste("D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual ecoregions NC/", eco$ECO_NAME, '.png',sep = ''), dpi = 600, scale = 2.5)
print(paste(i, eco$ECO_NAME))
}
  
for(i in 1:length(eco_names)){
eco = ecoregiones %>% filter(ECO_NAME == eco_names[i])
masked <- crop(mosaico, eco) %>% mask(eco)
df <- rasterToPoints(masked, spatial = TRUE) %>% data.frame(.)
plot_ecorregion(df, eco)
}   
```

#### Individual plot Atacama Desert

```r
ecoregiones <- st_read("C:/Users/Lucho/Downloads/MAPAS ECORREGIONES/MAPAS ECORREGIONES/Ecoregions_study_region_final.gpkg")
atacama <- ecoregiones %>% filter(ECO_NAME == "Atacama desert")

bbox <- st_bbox(atacama)  #  xmin        ymin       xmax       ymax 
                          # -70.39394 -26.31445 -68.42628 -18.39400 
bbox
mosaico <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

# Crop and mask 

atacama_masked <- crop(mosaico, atacama) %>% mask(atacama)
full_pts <- rasterToPoints(atacama_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

p <- ggplot() +
geom_tile(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = atacama, alpha = 0, color = "black") +
coord_sf(xlim = c(-72.5,-67), ylim = c(-18,-27), expand = TRUE) +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12),
axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0), size = 12), 
axis.text.x = element_text(colour = "black", size = 8),
axis.text.y = element_text(colour = "black", size = 8)) +      
theme(plot.title = element_text(size = 14, face = "bold.italic", hjust = .5)) 

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual ecoregions NC/Atacama Desert.png", dpi = 600, scale = 2.5)
```

#### Individual plot Chilean Matorral

```r
ecoregiones <- st_read("C:/Users/Lucho/Downloads/MAPAS ECORREGIONES/MAPAS ECORREGIONES/Ecoregions_study_region_final.gpkg")

chi_mat <- ecoregiones %>% filter(ECO_NAME == "Chilean matorral")

bbox <- st_bbox(chi_mat)  #  xmin        ymin       xmax       ymax 
                          # -73.15704    -39.47673  -69.09183  -22.95849 
bbox

mosaico <- raster(""D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

# Crop and mask 

mat_masked <- crop(mosaico, chi_mat) %>% mask(chi_mat)
full_pts <- rasterToPoints(mat_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

p <- ggplot() +
geom_tile(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = chi_mat, alpha = 0, color = "black") +
coord_sf(xlim = c(-75,-67), ylim = c(-22.5,-40), expand = TRUE) +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12),
axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0), size = 12), 
axis.text.x = element_text(colour = "black", size = 8),
axis.text.y = element_text(colour = "black", size = 8)) +      
theme(plot.title = element_text(size = 14, face = "bold.italic", hjust = .5)) 

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual ecoregions NC/Chilean Matorral.png", dpi = 600, scale = 2.5)
```

#### Individual plot Parana Flooded Savanna

```r
ecoregiones <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Ecoregions/Ecoregions_study_region_final.gpkg")

par_sav <- ecoregiones %>% filter(ECO_NAME == "Paraná flooded savanna")

bbox <- st_bbox(par_sav)  #  xmin        ymin       xmax       ymax 
                          # -60.84721    -34.29865  -57.56040  -25.39141
bbox

mosaico <- raster(""D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

# Crop and mask 

par_sav_masked <- crop(mosaico, par_sav) %>% mask(par_sav)

full_pts <- rasterToPoints(par_sav_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
head(full_df)

p <- ggplot() +
geom_tile(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = par_sav, alpha = 0, color = "black") +
coord_sf(xlim = c(-57,-61.5), ylim = c(-25.5,-34.5), expand = TRUE) +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12),
axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0), size = 12), 
axis.text.x = element_text(colour = "black", size = 8),
axis.text.y = element_text(colour = "black", size = 8)) +      
theme(plot.title = element_text(size = 14, face = "bold.italic", hjust = .5)) 

p

ggsave(p = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual ecoregions NC/Paraná Flooded Savanna.png", dpi = 600, scale = 2.5)
```

#### Individual plot Southern Andean Yungas

```r
ecoregiones <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Ecoregions/Ecoregions_study_region_final.gpkg")

yungas <- ecoregiones %>% filter(ECO_NAME == "Southern Andean Yungas")

bbox <- st_bbox(yungas)  #  xmin        ymin       xmax       ymax 
                         # -66.50806    -29.12975  -63.41831  -18.04249
bbox

mosaico <- raster(""D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

# Crop and mask 

yungas_masked <- crop(mosaico, yungas) %>% mask(yungas)

full_pts <- rasterToPoints(yungas_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
head(full_df)

p <- ggplot() +
geom_tile(data = full_df, aes(x = x, y = y, fill = Mosaic_all)) +
geom_sf(data = yungas, alpha = 0, color = "black") +
coord_sf(xlim = c(-63,-67), ylim = c(-18,-29.5), expand = TRUE) +
scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12),
axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0), size = 12),
axis.text.x = element_text(colour = "black", size = 8),
axis.text.y = element_text(colour = "black", size = 8)) +      
theme(plot.title = element_text(size = 14, face = "bold.italic", hjust = .5)) 

p

ggsave(plot = plot, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Individual ecoregions NC/Southern Andean Yungas.png", dpi = 600, scale = 2.5)
```
