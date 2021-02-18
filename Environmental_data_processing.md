
### The following code creates raster layers modeling the (pixel-wise) distance between each location and pixels contaning water.

``` r
if(!require(tidyverse)){
  install.packages("tidyverse")
}

if(!require(sf)){
  install.packages("sf")
}

if(!require(stars)){
  install.packages("stars")
}

if(!require(FNN)){
  install.packages("FNN")
}

library(tidyverse)
library(sf)
library(stars)
library(FNN)

proj.arg <- "+proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"

md1 <- read_stars("C:/Users/User/Documents/Analyses/Wild boar ENM/Rasters TIF/Calibration_area/BioClim_Annual_Diurnal_Temperature_Range_M.tif") %>%
  set_names("tmp")

k1 <- which(!is.na(md1$tmp))

xy1 <- md1 %>%
  as_tibble() %>%
  filter(!is.na(tmp)) %>%
  dplyr::select(x, y) %>%
  as.matrix() %>%
  sf_project(pts = .,
             from = st_crs(md1),
             to = proj.arg)

md2 <- read_stars("C:/Users/User/Documents/Analyses/Wild boar ENM/Rasters TIF/Projection_area/BioClim_Annual_Diurnal_Temperature_Range_G.tif") %>%
  set_names("tmp")

k2 <- which(!is.na(md2$tmp))

xy2 <- md2 %>%
  as_tibble() %>%
  filter(!is.na(tmp)) %>%
  dplyr::select(x, y) %>%
  as.matrix() %>%
  sf_project(pts = .,
             from = st_crs(md2),
             to = proj.arg)

for(dist in seq(from = 20, to = 90, by = 10)){
  
  xy.water1 <- str_c("C:/Users/User/Documents/Analyses/Wild boar ENM/Rasters TIF/Calibration_area_water/Water_occurrence_", dist, "_M.tif") %>%
    read_stars()
  
  xy.water2 <- str_c("C:/Users/User/Documents/Analyses/Wild boar ENM/Rasters TIF/Projection_area_water/Water_occurrence_", dist, "_G.tif") %>%
    read_stars()
  
  xy.water <- st_mosaic(xy.water1, xy.water2)
  
  xy.water <- (xy.water1 + xy.water2) %>%
    set_names("wt") %>%
    as_tibble(wx) %>%
    filter(wt == 1) %>%
    dplyr::select(x, y) %>%
    as.matrix() %>%
    sf_project(pts = .,
               from = st_crs(md1),
               to = proj.arg)
  
  dst1 <- get.knnx(xy.water, xy1, k = 1)
  dst1 <- dst1$nn.dist/1000
  
  dist_water1 <- md1 %>%
    set_names("wt") %>%
    mutate(wt = NA)
  dist_water1$wt[k1] <- dst1
  
  write_stars (dist_water1,
               dsn <- str_c("C:/Users/User/Documents/Analyses/Wild boar ENM/Rasters TIF/Calibration_area/Dist_to_water_", dist, "_M.tif"))
  
  dst2 <- get.knnx(xy.water, xy2, k = 1)
  dst2 <- dst2$nn.dist/1000
  
  dist_water2 <- md2 %>%
    set_names("wt") %>%
    mutate(wt = NA)
  dist_water2$wt[k2] <- dst2
  
  write_stars (dist_water2,
               dsn <- str_c("C:/Users/User/Documents/Analyses/Wild boar ENM/Rasters TIF/Projection_area/Dist_to_water_", dist, "_G.tif"))
}
```
