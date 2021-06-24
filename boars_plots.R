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
