### Correct Rasters
----------
The following script runs functions to correct errors in some rasters using Bioclim_Annual_Precipitation in calibration and projection areas as "reference" layers.

```r
library(tidyverse)
library(sf)
library(stars)
library(magrittr)
```
Raster correction in calibration area
----------

#### Correct DEM layer by replacing NAs with zeros.

```r
files <- list.files(path = "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Calibration_area/", pattern = ".tif$", full.names = TRUE)
files

st1 <- read_stars(files[1]) %>% set_names("var") # Bioclim_Annual_Precipitation_M
st5 <- read_stars(files[5]) %>% set_names("var") 

nas <- which(is.na(st1$var))

st5$var[nas] <- NA
write_stars(st5, dsn <- files[4])
write_stars(s5, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Calibration_area_corrected/DEM_M.tif") 
```

#### Correct rasters with NA where there should be data (high mountains)

```r
st1 <- read_stars(files[1]) %>% set_names("var") # Bioclim_Annual_Precipitation_M

st20 <- read_stars(files[20]) %>% set_names("var") # PML_Gross_Primary_Product
st21 <- read_stars(files[21]) %>% set_names("var") # PML_Interception_canopy_M
st22 <- read_stars(files[22]) %>% set_names("var") # PML_Soil_Transpiration_M
st23 <- read_stars(files[23]) %>% set_names("var") # PML_Vegetation_Transpiration_M

k1 <- which(!is.na(st1$var) & is.na(st20$var))
k2 <- which(!is.na(st1$var) & is.na(st21$var))
k3 <- which(!is.na(st1$var) & is.na(st22$var))
k4 <- which(!is.na(st1$var) & is.na(st23$var))

st20$var[k1] <- 0
st21$var[k2] <- 0
st22$var[k3] <- 0
st23$var[k4] <- 0

write_stars(st20, dsn = files[20])
write_stars(st20, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Calibration_area_corrected/PML_Gross_Primary_Product_M.tif")

write_stars(st21, dsn = files[21])
write_stars(st21, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Calibration_area_corrected/PML_Interception_canopy_M.tif")

write_stars(st22, dsn = files[22])
write_stars(st22, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Calibration_area_corrected/PML_Soil_Transpiration_M.tif")

write_stars(st23, dsn = files[23])
write_stars(st23, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Calibration_area_corrected/PML_Vegetation_Transpiration_M.tif")
```

Raster correction in projection area
----------

The following script runs functions, using "Bioclim_Annual_Precipitation_G" as reference layer.

#### Correct DEM layer by replacing NAs with zeros.

```r
files <- list.files(path = "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Projection_area", pattern = ".tif$", full.names = TRUE)
files

st1 <- read_stars(files[1]) %>% set_names("var")  # Bioclim_Annual_Precipitation_G
st5 <- read_stars(files[5]) %>% set_names("var")  # DEM_G

nas <- which(is.na(st1$var))

st5$var[nas] <- NA
write_stars(st5, dsn <- files[5])
write_stars(st5, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Projection_area_corrected/DEM_G.tif")
```

#### Correct rasters with NA where there should be data (high mountains)

```r
st1 <- read_stars(files[1]) %>% set_names("var")    # Bioclim_Annual_Precipitation_G

st20 <- read_stars(files[20]) %>% set_names("var")  # PML_Gross_Primary_Product_G
st21 <- read_stars(files[21]) %>% set_names("var")  # PML_Interception_canopy_G
st22 <- read_stars(files[22]) %>% set_names("var")  # PML_Soil_Transpiration_G
st23 <- read_stars(files[23]) %>% set_names("var")  # PML_Vegetation_Transpiration_G

k1 <- which(!is.na(st1$var) & is.na(st20$var))
k2 <- which(!is.na(st1$var) & is.na(st21$var))
k3 <- which(!is.na(st1$var) & is.na(st22$var))
k4 <- which(!is.na(st1$var) & is.na(st23$var))

st20$var[k1] <- 0
st21$var[k2] <- 0
st22$var[k3] <- 0
st23$var[k4] <- 0

write_stars(st20, dsn = files[20])
write_stars(st20, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Projection_area_corrected/PML_Gross_Primary_Product_G.tif")

write_stars(st21, dsn = files[21])
write_stars(st21, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Projection_area_corrected/PML_Interception_canopy_G.tif")

write_stars(st22, dsn = files[22])
write_stars(st22, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Projection_area_corrected/PML_Soil_Transpiration_G.tif")

write_stars(st23, dsn = files[23])
write_stars(st23, "D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/Projection_area_corrected/PML_Vegetation_Transpiration_G.tif")
```

