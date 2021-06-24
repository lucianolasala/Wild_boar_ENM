----------
The following code creates raster layers modeling the (pixel-wise)
distance between each location and pixels contaning water, based on the
corresponding rasters created in GEE (Global Surface Water).

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

----------
The following code performs Principal Component Analysis (PCA) to control for multicollinearity problems between variables and reduce matrix dimensions

``` r
library(tidyverse)
library(sf)
library(stars)

files1 <- list.files(path = "./data/Calibration_area", pattern = ".tif$", full.names = TRUE)
files2 <- list.files(path = "./data/Projection_area", pattern = ".tif$", full.names = TRUE)

names1 <- list.files(path = "./data/Calibration_area", pattern = ".tif$", full.names = FALSE)
names2 <- list.files(path = "./data/Projection_area", pattern = ".tif$", full.names = FALSE)

dir.create("./data/merged_areas")

## Identify cells with data

st1 <- read_stars(files1[1]) %>% set_names("z")
n1 <- which(!is.na(st1$z))  #71% of non-na cells in both areas

st2 <- read_stars(files2[1]) %>% set_names("z")
n2 <- which(!is.na(st2$z))  # 29% of non-na cells in both areas

## Sample
set.seed(100)
ssize = 2000
sm1 <- sample(n1, size = floor(ssize * .71))
sm2 <- sample(n2, size = floor(ssize * .29))

## Sample data data
dt <- NULL
for (i in 1:60){
  st1 <- read_stars(files1[i]) %>% set_names("z")
  st2 <- read_stars(files2[i]) %>% set_names("z")
  dt <- cbind(dt, c(st1$z[sm1], st2$z[sm2]))
}

## PCA for calibration area
colnames(dt) <- names1
pca1 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack1 <- read_stars(files1, proxy = TRUE)
pred1 <- merge(predict(stack1, pca1))
write_stars (pred1, dsn = "./data/pca/pca_calibration.tif", chunk_size = c(1000, 1000))

## PCA for projection area
colnames(dt) <- names2
pca2 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack2 <- read_stars(files2, proxy = TRUE)
pred2 <- merge(predict(stack2, pca2))
write_stars (pred2, dsn = "./data/pca/pca_projection.tif", chunk_size = c(1000, 1000))

```