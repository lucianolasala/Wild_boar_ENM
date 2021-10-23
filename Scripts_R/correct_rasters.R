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


st52 <- read_stars(files[52]) %>% set_names("var")
st53 <- read_stars(files[53]) %>% set_names("var")
st54 <- read_stars(files[54]) %>% set_names("var")
st55 <- read_stars(files[55]) %>% set_names("var")



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



st52 <- read_stars(files[52]) %>% set_names("var")
st53 <- read_stars(files[53]) %>% set_names("var")
st54 <- read_stars(files[54]) %>% set_names("var")
st55 <- read_stars(files[55]) %>% set_names("var")

k1 <- which(!is.na(st1$var) & is.na(st52$var))
k2 <- which(!is.na(st1$var) & is.na(st53$var))
k3 <- which(!is.na(st1$var) & is.na(st54$var))
k4 <- which(!is.na(st1$var) & is.na(st55$var))

st52$var[k1] <- 0
st53$var[k2] <- 0
st54$var[k3] <- 0
st55$var[k4] <- 0

write_stars(st52, dsn = files[52])
write_stars(st53, dsn = files[53])
write_stars(st54, dsn = files[54])
write_stars(st55, dsn = files[55])

