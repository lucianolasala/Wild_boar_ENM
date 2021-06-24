library(tidyverse)
library(sf)
library(stars)

files <- list.files(path = "./data/Calibration_area", pattern = ".tif$", full.names = TRUE)

st1 <- read_stars(files[1]) %>% set_names("var")
st20 <- read_stars(files[20]) %>% set_names("var")
st26 <- read_stars(files[26]) %>% set_names("var")
st40 <- read_stars(files[40]) %>% set_names("var")

nas <- which(is.na(st1$var))

st20$var[nas] <- NA
write_stars(st20, dsn <- files[20])

st26$var[nas] <- NA
write_stars(st26, dsn <- files[26])

st40$var[nas] <- NA
write_stars(st40, dsn <- files[40])

files <- list.files(path = "./data/Projection_area", pattern = ".tif$", full.names = TRUE)

st1 <- read_stars(files[1]) %>% set_names("var")
st20 <- read_stars(files[20]) %>% set_names("var")
st26 <- read_stars(files[26]) %>% set_names("var")
st40 <- read_stars(files[40]) %>% set_names("var")

nas <- which(is.na(st1$var))

st20$var[nas] <- NA
write_stars(st20, dsn <- files[20])

st26$var[nas] <- NA
write_stars(st26, dsn <- files[26])

st40$var[nas] <- NA
write_stars(st40, dsn <- files[40])
