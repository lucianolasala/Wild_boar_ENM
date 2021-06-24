library(tidyverse)
library(stars)
library(sf)
library(magrittr)
library(kuenm)
library(raster)

pca <- read_stars("./data/pca/PCA_calibration_area_reduced.tif", proxy = FALSE)

library(spThin)

set.seed(100)

nas <- read_delim("./data/S_scrofa.csv", delim = ";") %>% # n = 2576
  dplyr::select(Longitude,
                Latitude) %>%
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>%
  st_extract(pca[1], pts = .) %>%
  st_as_sf() %>%
  pull(PC1) %>%
  is.na()

occ <- read_delim("./data/S_scrofa.csv", delim = ";") %>% # n = 2576
  dplyr::select(Longitude,
                Latitude) %>%
  filter(!nas) %>%
  mutate(sp = "Boar") %>%
  thin(loc.data = .,
       long.col = "Longitude",
       lat.col = "Latitude",
       spec.col = "sp",
       thin.par = 5, reps = 1,
       locs.thinned.list.return = TRUE,
       write.files = FALSE,
       write.log.file = FALSE) %>%
  extract2(1) %>%
  mutate(sp = "Boar") %>%
  relocate(sp)  %>%
  rename("lon" = "Longitude",
         "lat" = "Latitude")

prep <- prepare_swd(occ = occ,
                    species = "sp",
                    longitude = "lon",
                    latitude = "lat",
                    raster.layers = pca,
                    sample.size = 105915,
                    train.proportion = 0.75,
                    save = TRUE,
                    name.occ = "Boars_SWD",
                    back.folder = "Boars_background")


## Files for projection area

## Stars package cannot export directly to ASCII
## https://gis.stackexchange.com/questions/362943/exporting-ascii-file-from-stars-package/362956

library(raster)
dir.create("./G_variables/Set_1", recursive = TRUE)

pca <- read_stars("./data/pca/PCA_projection_area_reduced.tif", proxy = FALSE) %>%
  as("Raster") %>%
  writeRaster(filename = str_c("./G_variables/Set_1/PCA", 1:6, ".asc"), bylayer = TRUE)


## Move files to server
## Remember to turn VPN on!

file.copy(from = str_c("/home/julian/Documents/Boars/Boars_SWD_", c("joint", "test", "train"), ".csv"),
          to = str_c("/net/hafsbotn.hafro.is/export/home/sjor/julian/Boars_kuenm/Boars_SWD_",
                     c("joint", "test", "train"), ".csv"), overwrite = TRUE)

R.utils::copyDirectory("/home/julian/Documents/Boars/Boars_background/",
                       "/net/hafsbotn.hafro.is/export/home/sjor/julian/Boars_kuenm/Boars_background/")

R.utils::copyDirectory("/home/julian/Documents/Boars/G_variables/",
                       "/net/hafsbotn.hafro.is/export/home/sjor/julian/Boars_kuenm/G_variables/")
