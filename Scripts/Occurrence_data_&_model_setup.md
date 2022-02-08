#### Packages and Libraries

```r
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(stars) # Spatiotemporal Arrays, Raster and Vector Data Cubes
library(sf) # Simple Features for R
library(magrittr) # A Forward-Pipe Operator for R
library(raster) # Geographic Data Analysis and Modeling
library(spThin) # Functions for Spatial Thinning of Species Occurrence Records for Use in Ecological Models

if(!require(devtools)){
  install.packages("devtools")
}

if(!require(kuenm)){
  devtools::install_github("marlonecobos/kuenm")
}

library(kuenm) # An R package for detailed development of ecological niche models using Maxent
```

#### Occurrence data processing
The scripts below produce spatial thinning of occurrence records to control for sampling bias.

```r
pca <- read_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA/PCA_calibration_area_reduced.tif", proxy = FALSE) %>%
  slice(band, 1) %>%
  setNames("PC1")

set.seed(100)

nas <- read_delim("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Occurrences/S_scrofa.csv", delim = ",") %>%
  dplyr::select(Longitude,
                Latitude) %>%
  filter(!is.na(Longitude),
         !is.na(Latitude)) %>%
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>%
  st_extract(pca[1], at = .) %>%
  st_as_sf() %>%
  pull(PC1) %>%
  is.na()

occ <- read_delim("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Occurrences/S_scrofa.csv", delim = ",") %>% 
  filter(!is.na(Longitude),
         !is.na(Latitude)) %>%
  dplyr::select(Longitude,
                Latitude) %>%
  filter(!nas) %>%
  mutate(sp = "Boar") %>%
  thin(loc.data = .,
       long.col = "Longitude",
       lat.col = "Latitude",
       spec.col = "sp",
       thin.par = 10, reps = 1,
       locs.thinned.list.return = TRUE,
       write.files = FALSE,
       write.log.file = FALSE) %>%
  extract2(1) %>%
  mutate(sp = "Boar") %>%
  relocate(sp) %>%
  rename("lon" = "Longitude",
         "lat" = "Latitude")

write_csv(occ, "D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Occurrences/S_scrofa_thinned.csv")  

pca <- read_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA/PCA_calibration_area_reduced.tif", proxy = FALSE) %>%
  as("Raster") %>%
  setNames(str_c("PC", 1:6))
```

#### Preparation of "samples with data" (SWD) format

The function *prepare_swd* creates csv files containing occurrence records (all, train, and test records) and background coordinates, together with values of predictor variables that later can be used to run model calibration in Maxent using the SWD format.

```r
setwd("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/")

prepare_swd(occ = occ,
            species = "sp",
            longitude = "lon",
            latitude = "lat",
            raster.layers = pca,
            sample.size = 105915,
            train.proportion = 0.75,
            save = TRUE,
            name.occ = "Boars_SWD",
            back.folder = "M_variables")
```

#### Files for projection area

```r
dir.create("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/G_variables/Set_1/Scenario_cal", recursive = TRUE)
dir.create("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/G_variables/Set_1/Scenario_proj", recursive = TRUE)

pca <- read_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA/PCA_calibration_area_reduced.tif", proxy = FALSE) %>%
  as("Raster") %>%
  writeRaster(filename = str_c("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/G_variables/Set_1/Scenario_cal/PC", 1:6, ".asc"), bylayer = TRUE, overwrite = TRUE)

pca <- read_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA/PCA_projection_area_reduced.tif", proxy = FALSE) %>%
  as("Raster") %>%
  writeRaster(filename = str_c("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/G_variables/Set_1/Scenario_proj/PC", 1:6, ".asc"), bylayer = TRUE, overwrite = TRUE)
