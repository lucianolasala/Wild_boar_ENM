### Model Averaging
The following script performs calculations across model bootstrap replicates of the selected models, and derives raster layers with mean and standard deviation values in each pixel for the calibration and projection areas.

#### Packages and libraries

```r
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(sf) # Simple Features for R
library(stars) # Spatiotemporal Arrays, Raster and Vector Data Cubes
library(stringr) # Simple, Consistent Wrappers for Common String Operations
``` 
#### Model averaging for models with extrapolation

```r
selected <- read_csv("./Candidate_models_eval/selected_models.csv")
selected_grid <- expand_grid(mod = selected$Model, mn = 0:9)
paths1 <- str_c("./Final_models/", selected_grid$mod, "_E/Boar_", selected_grid$mn, "_Scenario_cal.asc")
paths2 <- str_c("./Final_models/", selected_grid$mod, "_E/Boar_", selected_grid$mn, "_Scenario_proj.asc")

names1 <- str_c(selected_grid$mod, "_cal_", selected_grid$mn)
names2 <- str_c(selected_grid$mod, "_proj_", selected_grid$mn)

mean1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_mean_E.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_sd_E.tif", chunk_size = c(2000, 2000), NA_value = -9999)

mean2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_mean_E.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_sd_E.tif", chunk_size = c(2000, 2000), NA_value = -9999)
```

#### Model averaging and dispersion for models with extrapolation and clamping

```r
selected <- read_csv("./Candidate_models_eval/selected_models.csv")
selected_grid <- expand_grid(mod = selected$Model, mn = 0:9)
paths1 <- str_c("./Final_models/", selected_grid$mod, "_EC/Boar_", selected_grid$mn, "_Scenario_cal.asc")
paths2 <- str_c("./Final_models/", selected_grid$mod, "_EC/Boar_", selected_grid$mn, "_Scenario_proj.asc")

names1 <- str_c(selected_grid$mod, "_cal_", selected_grid$mn)
names2 <- str_c(selected_grid$mod, "_proj_", selected_grid$mn)

mean1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_mean_EC.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_sd_EC.tif", chunk_size = c(2000, 2000), NA_value = -9999)

mean2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_mean_EC.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_sd_EC.tif", chunk_size = c(2000, 2000), NA_value = -9999)
```

#### Model averaging and dispersion for models without extrapolation 

```r
selected <- read_csv("./Candidate_models_eval/selected_models.csv")
selected_grid <- expand_grid(mod = selected$Model, mn = 0:9)
paths1 <- str_c("./Final_models/", selected_grid$mod, "_NE/Boar_", selected_grid$mn, "_Scenario_cal.asc")
paths2 <- str_c("./Final_models/", selected_grid$mod, "_NE/Boar_", selected_grid$mn, "_Scenario_proj.asc")

names1 <- str_c(selected_grid$mod, "_cal_", selected_grid$mn)
names2 <- str_c(selected_grid$mod, "_proj_", selected_grid$mn)

mean1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_mean_NE.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_sd_NE.tif", chunk_size = c(2000, 2000), NA_value = -9999)

mean2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_mean_NE.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_sd_NE.tif", chunk_size = c(2000, 2000), NA_value = -9999)
```