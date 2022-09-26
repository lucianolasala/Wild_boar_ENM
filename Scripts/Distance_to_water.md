### Building distance-to-water layers
----------

Calculating the Euclidean distance between each raster cell and the closest cell containing water during a perior equal to, o longer than, the following thresholds for the analyzed time series (&ge;20%, &ge;30%, &ge;40%, &ge;50%, &ge;60%, &ge;70%, &ge;80%, &ge;90%) corresponding to the percentage of time that the cell was occupied by water. For example, the value in each cell in the first raster (&ge;20%) corresponds to the distance between that cell and the closest cell that contained water &ge;20% of the time.   

```r
library(tidyverse)
library(sf)
library(stars)
library(FNN)

proj.arg <- "+proj=tmerc +lat_0=-90 +lon_0=-69 + k=1 + x_0 = 2500000 + y_0 = 0 +ellps = GRS80 + units = m + no_defs"

md1 <- read_stars("./data/Calibration_area/BioClim_Annual_Diurnal_Temperature_Range_M.tif") %>%
  set_names("tmp")

k1 <- which(!is.na(md1$tmp))

xy1 <- md1 %>%
  as_tibble() %>%
  filter(!is.na(tmp)) %>%
  dplyr::select(x, y) %>%
  as.matrix() %>%
  sf_project(pts = .,
             from = st_crs(md),
             to = proj.arg)

md2 <- read_stars("./data/Projection_area/BioClim_Annual_Diurnal_Temperature_Range_G.tif") %>%
  set_names("tmp")
k2 <- which(!is.na(md2$tmp))
xy2 <- md2 %>%
  as_tibble() %>%
  filter(!is.na(tmp)) %>%
  dplyr::select(x, y) %>%
  as.matrix() %>%
  sf_project(pts = .,
             from = st_crs(md),
             to = proj.arg)

for (dist in seq(from = 20, to = 90, by = 10)){

xy.water1 <- str_c("./data/Calibration_area_water/Water_occurrence_", dist, "_M.tif") %>%
read_stars()

xy.water2 <- str_c("./data/Projection_area_water/Water_occurrence_", dist, "_G.tif") %>%
read_stars()

xy.water <- st_mosaic(xy.water1, xy.water2)

xy.water <- (xy.water1 + xy.water2) %>%
set_names("wt") %>%
as_tibble(wx) %>%
filter(wt == 1) %>%
dplyr::select(x, y) %>%
as.matrix() %>%
sf_project(pts = .,
from = st_crs(md),
to = proj.arg)

dst1 <- get.knnx(xy.water, xy1, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water1 <- md1 %>%
set_names("wt") %>%
mutate(wt = NA)
dist_water1$wt[k1] <- dst1

write_stars (dist_water1,
dsn <- str_c("./data/Calibration_area/Dist_to_water_", dist, "_M.tif"))

dst2 <- get.knnx(xy.water, xy2, k = 1)
dst2 <- dst2$nn.dist/1000

dist_water2 <- md2 %>%
set_names("wt") %>%
mutate(wt = NA)
dist_water2$wt[k2] <- dst2

write_stars (dist_water2,
dsn <- str_c("./data/Projection_area/Dist_to_water_", dist, "_G.tif"))
}
```
