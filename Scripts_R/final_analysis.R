library(kuenm)
library(tidyverse)
library(sf)
library(stars)
library(stringr)


## Merging all output

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
  write_stars("./Final_models/cal_area_mean.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd1 <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/cal_area_sd.tif", chunk_size = c(2000, 2000), NA_value = -9999)

mean2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_mean.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd2 <- read_stars(paths2) %>%
  set_names(names2) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models/proj_area_sd.tif", chunk_size = c(2000, 2000), NA_value = -9999)

## Average suitability per department

dep <- read_sf("./data/ARG_adm/ARG_adm2.shp") %>%
  select(NAME_1, NAME_2)

vals <- aggregate(mean1, dep, mean, na.rm = TRUE) %>%
  st_as_sf()



## Extrapolation risk analysis

ksuenm_mmop(G.var.dir = "G_variables",
           M.var.dir = "M_variables",
           is.swd = TRUE,
           sets.var = c("Set_1"),
           out.mop = "mop_results",
           percent = 50,
           comp.each = 2000,
           parallel = FALSE)
