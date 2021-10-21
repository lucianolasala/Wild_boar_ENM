
library(tidyverse)
library(sf)
library(stars)

rm(list=ls(all=TRUE))

setwd("~/Analyses/Wild boar ENM")

files1 <- list.files(path = "./Rasters TIF/Calibration_area", pattern = ".tif$", full.names = TRUE)
files2 <- list.files(path = "./Rasters TIF/Projection_area", pattern = ".tif$", full.names = TRUE)

vnames <- list.files(path = "./Rasters TIF/Projection_area", pattern = ".tif$", full.names = FALSE) %>%
  str_replace("_G.tif", "")

dir.create("./pca")

## Identify cells with data

st1 <- read_stars(files1[1]) %>% set_names("z")  # set_names changes long variable name to "z" or whatever w want to call it 

str(st1)
plot(st1)
dim(st1)  # 5567*7746 = 43121982 cells 

st1a <- raster(files1[1])  # Open same file using "raster" to extract extent.
str(st1a)
extent(st1a)

# class      : Extent 
# xmin       : -83.00433 
# xmax       : -32.99512 
# ymin       : -58.57016 
# ymax       : 11.01335 

n1 <- which(!is.na(st1$z))  # 71% of non-na cells in both areas
head(n1)
length(n1)  # 11986163 not NA


st2 <- read_stars(files2[1]) %>% set_names("z")
plot(st2)
dim(st2)  # 5567*7746 = 43121982

n2 <- which(!is.na(st2$z))  # 29% of non-na cells in both areas
head(n2)
length(n2)  # 4934061

pixels_data = length(n1) + length(n2)  # 16920224
pixels_data

(length(n1)*100)/pixels_data  # 70.83927
(length(n2)*100)/pixels_data  # 29.16073

st2a <- raster(files2[1])
extent(st2a)

# class      : Extent 
# xmin       : -83.00433 
# xmax       : -32.99512 
# ymin       : -58.57016 
# ymax       : 11.01335

## Sample

set.seed(100)

ssize = 2000  # Por que 2000?

sm1 <- sample(n1, size = floor(ssize * .71))
sm2 <- sample(n2, size = floor(ssize * .29))

## Sample data

dt <- NULL

for (i in 1:60){
  st1 <- read_stars(files1[i]) %>% set_names("z")
  st2 <- read_stars(files2[i]) %>% set_names("z")
  dt <- cbind(dt, c(st1$z[sm1], st2$z[sm2]))
}

dt <- dt %>%
  as_tibble(.name_repair = "minimal") %>%
  set_names(vnames)

colnames(dt)

## Explore correlation and remove highly correlated variables
## Remove each variable in turn and re-run this bit until all correlations are below 0.9.

get.corr <- function(x){
  crr <- Hmisc::rcorr(as.matrix(x), type = "spearman")
  ut <- upper.tri(crr$r)
  vnames <- colnames(crr$r)
  crr <- data.frame(v1 = vnames[row(crr$r)[ut]],
                    v2 = vnames[col(crr$r)[ut]],
                    cor = crr$r[ut]) %>%
    as_tibble() %>%
    mutate(cor = abs(cor)) %>%
    arrange(desc(cor)) %>%
    filter(cor >= .9)
  return(crr)
}

cr <- get.corr(dt)

to.remove <- names(sort(table(c(cr$v1, cr$v2)), decreasing = TRUE))

# Extract each variable in turn and then run the flattenCorrMatrix function:

while(length(to.remove) > 0){

  dt <- dt %>%
    dplyr::select(-to.remove[1])
  cr <- get.corr(dt)
  to.remove <- names(sort(table(c(cr$v1, cr$v2)), decreasing = TRUE))
}


## PCA for calibration area

nm <- colnames(dt)

nm1 <- str_c(nm, "_M.tif")
nm2 <- str_c(nm, "_G.tif")

files1 <- str_c("./data/Calibration_area/", nm1)
files2 <- str_c("./data/Projection_area/",nm2)

colnames(dt) <- nm1
pca1 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack1 <- read_stars(files1, proxy = TRUE)

pred1 <- predict(stack1, pca1) %>%
  merge() %>%
  write_stars("./data/pca/PCA_calibration_area.tif", chunk_size = c(2000, 2000))

colnames(dt) <- nm2
pca2 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack2 <- read_stars(files2, proxy = TRUE)

pred2 <- predict(stack2, pca2) %>%
  merge() %>%
  write_stars("./data/pca/PCA_projection_area.tif", chunk_size = c(2000, 2000))


## Reduce resolution

pca <- read_stars("./data/pca/PCA_calibration_area.tif", proxy = FALSE)

dims <- st_dimensions(pca)

ng <- st_as_stars(st_bbox(pca),
                  dx = abs(dims$x$delta) * 10,
                  dy = abs(dims$x$delta) * 10)

pca <- st_warp(src = pca,
               dest = ng,
               use_gdal = TRUE,
               method = "average") %>%
  st_set_dimensions(which = "band", values = str_c("PC", 1:6)) %>%
  write_stars("./data/pca/PCA_calibration_area_reduced.tif")

pca <- read_stars("./data/pca/PCA_projection_area.tif", proxy = FALSE)

dims <- st_dimensions(pca)

ng <- st_as_stars(st_bbox(pca),
                  dx = abs(dims$x$delta) * 10,
                  dy = abs(dims$x$delta) * 10)

pca <- st_warp(src = pca,
               dest = ng,
               use_gdal = TRUE,
               method = "average") %>%
  st_set_dimensions(which = "band", values = str_c("PC", 1:6)) %>%
  write_stars("./data/pca/PCA_projection_area_reduced.tif")
