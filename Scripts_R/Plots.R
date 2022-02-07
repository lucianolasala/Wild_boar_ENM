library(tidyverse)
library(stars)
library(sf)
library(viridis)


dt <- read_csv("/net/hafsbotn.hafro.is/export/home/sjor/julian/Boars_kuenm/Final_models/M_0.1_F_lq_Set_1/Boar_avg.csv") %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_rasterize(dx=0.08983153, dy=0.08983153)

occ <- read_delim("/home/julian/Documents/Boars/data/S_scrofa.csv", delim = ";") %>%
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

ggplot() +
  geom_stars(data = dt) +
  geom_sf(data = occ, size = .5, colour = "red") +
  coord_sf() +
  scale_fill_viridis(na.value = "transparent") +
  labs(x = "Longitud", y = "Latitud", fill = "Suitabilidad") +
  theme_bw()

ggsave("/home/julian/Documents/Boars/plots/Predition.png", width = 8.3, height = 11.7)

#-----------------------------------------------------------

library(tidyverse)
library(stars)
library(sf)
library(paletteer)
library(gridExtra)


occ <- read_delim("./Occurrences/S_scrofa.csv", delim = ",") %>%
  filter(!is.na(Longitude),
         !is.na(Latitude)) %>%
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

dt1 <- read_stars("./Final_models/cal_area_mean.tif")
dt2 <- read_stars("./Final_models/proj_area_mean.tif")


make.plot <- function(dt, zmin = NA, zmax = NA, title = "", plot.obs = TRUE) {
  
  if (is.na(zmin) | is.na(zmax)) {
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
  
  if (plot.obs) {
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
  labs(x = "Longitud", y = "Latitud", fill = "Suitabilidad") +
  theme_bw()

p2 <- ggplot() +
  geom_stars(data = dt2) +
  geom_sf(data = occ, size = .5, colour = "black") +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitud", y = "Latitud", fill = "Suitabilidad") +
  theme_bw()

ggsave(plot = p1, "./plots/Predition_calibration.png", width = 8.3, height = 11.7)

ggsave(plot = p2, "./plots/Predition_projection.png", width = 8.3, height = 11.7)
