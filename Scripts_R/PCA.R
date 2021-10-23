library(tidyverse)
library(sf)
library(stars)

files1 <- list.files(path = "./data/Calibration_area", pattern = ".tif$", full.names = TRUE)
files2 <- list.files(path = "./data/Projection_area", pattern = ".tif$", full.names = TRUE)

vnames <- list.files(path = "./data/Projection_area", pattern = ".tif$", full.names = FALSE) %>%
  str_replace("_G.tif", "")

dir.create("./data/pca")

## Identify cells with data

st1 <- read_stars(files1[1]) %>% set_names("z")
n1 <- which(!is.na(st1$z))  #71% of non-na cells in both areas

st2 <- read_stars(files2[1]) %>% set_names("z")
n2 <- which(!is.na(st2$z))  # 29% of non-na cells in both areas

## Sample
set.seed(100)
ssize <- 2000
sm1 <- sample(n1, size = floor(ssize * .71))
sm2 <- sample(n2, size = floor(ssize * .29))

## Sample data data
dt <- NULL
for (i in 1:59){
  st1 <- read_stars(files1[i]) %>% set_names("z")
  st2 <- read_stars(files2[i]) %>% set_names("z")
  dt <- cbind(dt, c(st1$z[sm1], st2$z[sm2]))
}

dt <- dt %>%
  as_tibble(.name_repair = "minimal") %>%
  set_names(vnames)

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
to.remove <- names(sort(table(c(cr$v1,cr$v2)),decreasing=TRUE))

# Extract each variable in turn and the run the flattenCorrMatrix function:

while(length(to.remove) > 0){

  dt <- dt %>%
    dplyr::select(-to.remove[1])
  cr <- get.corr(dt)
  to.remove <- names(sort(table(c(cr$v1,cr$v2)),decreasing=TRUE))
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
  write_stars("./data/pca/PCA_calibration_area.tif", chunk_size = c(2000, 2000), NA_value = -9999)

colnames(dt) <- nm2
pca2 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack2 <- read_stars(files2, proxy = TRUE)

pred2 <- predict(stack2, pca2) %>%
  merge() %>%
  write_stars("./data/pca/PCA_projection_area.tif", chunk_size = c(2000, 2000), NA_value = -9999)

