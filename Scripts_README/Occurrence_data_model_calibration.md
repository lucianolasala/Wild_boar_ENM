
#### Following we randomly allocate occurrence data to training and testing sets used for model calibration and validation, respectively.

```r
rm(list=ls(all=TRUE))
library(kuenm)

setwd("C:/Users/User/Documents/Analyses/Wild boar ENM/Occurrences")

occs <- read.csv("S_scrofa.csv") 

set.seed(1)

split <- kuenm_occsplit(occ = occs, train.proportion = 0.7, method = "random", save = TRUE, name = "occ")
```
