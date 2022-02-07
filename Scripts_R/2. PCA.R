#------------------------------------------------------------------------
# Loading packages and libraries
#------------------------------------------------------------------------

rm(list=ls(all=TRUE))

library(tidyverse)
library(sf)
library(stars)
library(stringr)
library(magrittr)

#------------------------------------------------------------------------
# Loading files
#------------------------------------------------------------------------
# Nota. Arhivos tif en carpetas de Calibracion y Proyeccion tienen _M y _G
# como terminacion de nombre

files1 <- list.files(path = "D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/Calibration_area",
                     pattern = ".tif$", full.names = TRUE)

files2 <- list.files(path ="D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/Projection_area", 
                     pattern = ".tif$", full.names = TRUE)

vnames <- list.files(path = "D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/Projection_area", pattern = ".tif$", full.names = FALSE) %>%
  str_replace("_G.tif", "")  # Guardo nombre de variables sin "_G" en objeto vnames

dir.create("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA")

#------------------------------------------------------------------------
# Identify cells with data
#------------------------------------------------------------------------

st1 <- read_stars(files1[1]) %>% set_names("z")
n1 <- which(!is.na(st1$z))  # 71% of non-na cells in both areas

st2 <- read_stars(files2[1]) %>% set_names("z")
n2 <- which(!is.na(st2$z))  # 29% of non-na cells in both areas

## Sample

set.seed(100)
ssize <- 2000

sm1 <- sample(n1, size = floor(ssize * .71))
sm2 <- sample(n2, size = floor(ssize * .29))

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

#------------------------------------------------------------------------
# Explore correlation and remove highly correlated variables
# Remove each variable in turn and re-run this bit until all correlations 
# are below 0.8.
#------------------------------------------------------------------------

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

#------------------------------------------------------------------------
# Extract each variable in turn and the run the flattenCorrMatrix function
#------------------------------------------------------------------------

while(length(to.remove) > 0){
  
  dt <- dt %>%
    dplyr::select(-to.remove[1])
  cr <- get.corr(dt)
  to.remove <- names(sort(table(c(cr$v1,cr$v2)), decreasing=TRUE))
}

#------------------------------------------------------------------------
# PCA for calibration and projection areas
#------------------------------------------------------------------------

nm <- colnames(dt)

nm1 <- str_c(nm, "_M.tif")
nm2 <- str_c(nm, "_G.tif")

files1 <- str_c("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/Calibration_area/", nm1) # Con str_c une dos strings, en este caso pega al _G o _M al nombre del raster
files2 <- str_c("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/Projection_area/", nm2)

colnames(dt) <- nm1

#----LFLS-------------------------------------------------------------
pca_full <- prcomp(na.omit(dt), scale = TRUE)  # Quito rank para ver todos
names(pca_full)
summary(pca_full)  # The first six comp. explain 0.92482 of total variance

PCA <- c("1","2","3","4","5","6")

Proportion <- c(0.4325,0.1965,0.1319,0.0696,0.05404,0.04028)
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

ggsave(filename="D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Screeplot_PCA.jpg", plot = p, device = "tiff", path = NULL,
       scale = 1, dpi = 100, limitsize = TRUE)

#---------------------------------------------------------------------

pca1 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)  
stack1 <- read_stars(files1, proxy = TRUE)

for(i in files1){
  a <- read_stars(i, proxy = F, along = NA)
  print(st_dimensions(a))
}

stack1 <- read_stars(files1, proxy = TRUE)

pred1 <- predict(stack1, pca1) %>%
  merge() %>%
  write_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA/PCA_calibration_area.tif", 
              chunk_size = c(2000, 2000), NA_value = -9999)

colnames(dt) <- nm2
pca2 <-  prcomp(na.omit(dt), scale = TRUE, rank = 6)
stack2 <- read_stars(files2, proxy = TRUE)

pred2 <- predict(stack2, pca2) %>%
  merge() %>%
  write_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/pca/PCA_projection_area.tif", 
              chunk_size = c(2000, 2000), NA_value = -9999)

#------------------------------------------------------------------------
# Reduce resolution
#------------------------------------------------------------------------

rm(list=ls(all=TRUE))

pca <- read_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/pca/PCA_calibration_area.tif",
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
  write_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/pca/PCA_calibration_area_reduced.tif")

#---------------------------------------------------------

pca <- read_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/PCA/PCA_projection_area.tif", proxy = FALSE)

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
  write_stars("D:/LFLS/Analyses/Jabali_ENM/Modelado_6/Variables/pca/PCA_projection_area_reduced.tif")

