#### Correlation and Principal Component Analysis (PCA)
----------

The scripts below are used to (1) perform correlation analysis, (2) perform principal component analysis (PCA) on those environmental variables remaining after correlation analysis, and (3) reduce final resolution of PCA axes, and (4) make a scree plot showing variance (%) explained by each PCA axis.

```r
library(tidyverse)
library(sf)
library(stars)
library(raster)
library(stringr)
library(magrittr)
library(rgdal)

files1 <- list.files(path = "./Variables/Calibration_area", 
                     pattern = ".tif$", full.names = TRUE)

files2 <- list.files(path ="./Variables/Projection_area", 
                     pattern = ".tif$", full.names = TRUE)

vnames <- list.files(path = "./Variables/Projection_area", pattern = ".tif$", full.names = FALSE) %>%
  str_replace("_G.tif", "")  # Guardo nombre de variables sin "_G" en objeto vnames

dir.create("D:/LFLS/Analyses/Jabali_ENM/Modelling/Variables/PCA")
```

#### Identifying cells with data

```r
st1 <- read_stars(files1[1]) %>% set_names("z")
n1 <- which(!is.na(st1$z))  # 76.3% of non-na cells in both areas
length(n1)  # 12861402

st2 <- read_stars(files2[1]) %>% set_names("z")
n2 <- which(!is.na(st2$z))  # 23.7 of non-na cells in both areas
length(n2)  # 4002844

tot = length(n1)+length(n2)  # 16864246 
tot

p1 = round(length(n1)/tot, 3)
p1

p2 = round(length(n2)/tot,3)
p2

p1+p2

# Sample

set.seed(100)
ssize <- 10000

sm1 <- sample(n1, size = floor(ssize * .76))
sm2 <- sample(n2, size = floor(ssize * .24))

## Sample data data

dt <- NULL

for(i in 1:24){  
  st1 <- read_stars(files1[i]) %>% set_names("z")
  st2 <- read_stars(files2[i]) %>% set_names("z")
  dt <- cbind(dt, c(st1$z[sm1], st2$z[sm2]))
}

dt <- dt %>%
  as_tibble(.name_repair = "minimal") %>%
  set_names(vnames)
```

#### Explore correlation and remove highly correlated variables

```r
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
    filter(cor >= .8)
  return(crr)
}

cr <- get.corr(dt)

to.remove <- names(sort(table(c(cr$v1,cr$v2)), decreasing=TRUE))
to.remove
```

#### Extract each variable in turn and the run the flattenCorrMatrix function

```r
while(length(to.remove) > 0){
  dt <- dt %>%
    dplyr::select(-to.remove[1])
  cr <- get.corr(dt)
  to.remove <- names(sort(table(c(cr$v1,cr$v2)), decreasing=TRUE))
}
```

#### PCA for calibration and projection areas

```r
nm <- colnames(dt)

nm1 <- str_c(nm, "_M.tif")
nm1
nm2 <- str_c(nm, "_G.tif")
nm2

files1 <- str_c("./Variables/Calibration_area/", nm1) # Con str_c une dos strings, en este caso pega al _G o _M al nombre del raster
files2 <- str_c("./Variables/Projection_area/", nm2)

colnames(dt) <- nm1

pca1 <- prcomp(na.omit(dt), scale = TRUE, rank = 6)  
stack1 <- stars::read_stars(files1, proxy = TRUE)


pred1 <- predict(stack1, pca1) %>%
  merge() %>%
  write_stars("./Variables/PCA/PCA_calibration_area.tif", 
              chunk_size = c(2000, 2000), NA_value = -9999)


colnames(dt) <- nm2
pca2 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack2 <- read_stars(files2, proxy = TRUE)

pred2 <- predict(stack2, pca2) %>%
  merge() %>%
  write_stars("./Variables/PCA/PCA_projection_area.tif", 
              chunk_size = c(2000, 2000), NA_value = -9999)
```

#### Reduce resolution

```r
pca <- read_stars("./Variables/PCA/PCA_calibration_area.tif",
                  proxy = FALSE)

dims <- st_dimensions(pca)

ng <- st_as_stars(st_bbox(pca),
                  dx = abs(dims$x$delta) * 10,
                  dy = abs(dims$x$delta) * 10)

pca <- st_warp(src = pca,
               dest = ng,
               use_gdal = TRUE,
               method = "average",
               no_data_value = -9999) %>%
  st_set_dimensions(which = "band", values = str_c("PC", 1:6)) %>%
  write_stars("./Variables/PCA/PCA_calibration_area_reduced.tif")

pca <- read_stars("./Variables/PCA/PCA_projection_area.tif", proxy = FALSE)

dims <- st_dimensions(pca)

ng <- st_as_stars(st_bbox(pca),
                  dx = abs(dims$x$delta) * 10,
                  dy = abs(dims$x$delta) * 10)

pca <- st_warp(src = pca,
               dest = ng,
               use_gdal = TRUE,
               method = "average",
               no_data_value = -9999) %>%  # mean
  st_set_dimensions(which = "band", values = str_c("PC", 1:6)) %>%
  write_stars("./Variables/pca/PCA_projection_area_reduced.tif")
```

#### Scree plot PCA in calibration area

```r
pca_full <- prcomp(na.omit(dt), scale = TRUE)  # Quito rank para ver todos
names(pca_full)
summary(pca_full)  # The first six comp. explain 0.92482 of total variance

PCA <- c("1","2","3","4","5","6")

Proportion <- c(0.4064, 0.2064, 0.1334, 0.06982, 0.05483, 0.04342)
Proportion <- round(Proportion, digits = 3)*100
Proportion

plot <- data.frame(PCA, Proportion)
plot

plot$PCA <- factor(plot$PCA, levels=c("1","2","3","4","5","6"))

p <- ggplot() + geom_col(aes(y = Proportion, x = PCA), position = "stack", data = plot, color="blue", fill="white")

p <- p + geom_text(data = plot, aes(x = PCA, y = Proportion, label = Proportion, vjust = -0.5), size = 3.5) +
  xlab("Principal Component") +
  ylab("Variance explained (%)") +
  
  theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), color =           "black", size = 11, face = "bold"),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), color =            "black",   size = 11, face = "bold")) +
  scale_x_discrete(limits = c("1","2","3","4","5","6")) +
  coord_cartesian(ylim=c(0, 60)) +
  theme(plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"),
        axis.text.x = element_text(colour="black", size = 11, angle = 360, hjust = 1),
        axis.line.x = element_line(),
        axis.text.y = element_text(colour="black", size = 11))
p

ggsave(filename="./Plots/PCA_calibration.jpg", plot = p, device = "tiff", path = NULL,
       scale = 1, dpi = 100, limitsize = TRUE)
```
