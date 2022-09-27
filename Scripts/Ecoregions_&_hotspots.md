#### Ecoregions data processing
The folloging script is used to produce summary statistics for each ecoregion in the study region. 


*Note.* Polygon #5 (Fernando de Noronha-Atol das Rocas moist forests) falls outside the export area defined in GEE and yields an error. Also, the following polygons have no pixels and give NA and Inf in the estimation; then they are excluded from the analysis. These are #63 San Felix-San Ambrosio Islands temperate forests, and #69 Juan Fernandez Islands temperate forests. 

#### Loading and merging calibration and projection rasters for the final model.

```r
cal = raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modelado_7/Final_models/cal_area_mean.tif")
proj = raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modelado_7/Final_models/proj_area_mean.tif")
ras = merge(cal, proj)
```
>Loading vector file for all ecoregions, and leaving out the ones mentioned above.

```r
setwd("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors")
ecoregiones <- st_read("./Ecoregions_study_region.gpkg")
eco_names <- unique(ecoregiones$ECO_NAME)
eco_names <- eco_names[-c(5,63,69)]
```
>Creating a function to iterate through all eroregions, calculating the necessary statistics and saving as plain text file.

```r
procesado <- function(nombre_eco){
eco = ecoregiones[ecoregiones$ECO_NAME == nombre_eco,]
eco_mask <- crop(ras, eco) %>% mask(eco)
    
eco_mean = cellStats(eco_mask, stat = "mean", na.rm = TRUE, asSample = TRUE)
eco_min = cellStats(eco_mask, stat = "min", na.rm = TRUE, asSample = TRUE)
eco_max = cellStats(eco_mask, stat = "max", na.rm = TRUE, asSample = TRUE)
eco_sd = cellStats(eco_mask, stat = "sd", na.rm = TRUE, asSample = TRUE)
return(c(eco_mean, eco_min, eco_max, eco_sd))
}

eco_means <- c()
eco_mins <- c()
eco_maxs <- c()
eco_sds <- c()

for(i in eco_names){
a <- procesado(i)
eco_means <- append(eco_means, a[1])
eco_mins <- append(eco_mins, a[2])
eco_maxs <- append(eco_maxs, a[3])
eco_sds <- append(eco_sds, a[4])
}

res <- data.frame(eco_names,eco_means,eco_mins,eco_maxs,eco_sds) %>% mutate(across(where(is.numeric), ~ round(., 3)))
res <- res[order(res$eco_means, decreasing = T), ]
res_unique <- res[!duplicated(res[1]), ]
length(res_unique$eco_names)

write.csv(res_unique, "C:/Users/User/Documents/Analyses/Wild boar ENM/Ecoregions/Summary_table.csv")
```

### Suitability analysis in hotspot areas (thresholded model)

```r
mosaico <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

# Loading vector file for all ecoregions, and leaving out the one mentioned above.

hotspots <- st_read("./Hotspots/Biodiversity hotspots.gpkg")
colnames(hotspots)
hot_names <- unique(hotspots$NAME)

tot.suit <- c()
tot.unsuit <- c()
prop.suit <- c()
prop.unsuit <- c()

for(i in 1:length(hot_names)) {  # Loops over every ecoregion
  a <- hotspots %>% filter(NAME==hot_names[i])  # Stores in "a" each hotspot polygon 
  
  masked <- crop(mosaico, a) %>% mask(a)  # Crop and mask
  
  tot.suit[i] <- sum(values(masked==1), na.rm=TRUE)*100
  tot.unsuit[i] <- sum(values(masked==0), na.rm=TRUE)*100
  
  prop.unsuit[i] <- round(as.numeric(table(masked[])[1]/sum(table(masked[])))*100,2)
  prop.suit[i] <- round(as.numeric(table(masked[])[2]/sum(table(masked[])))*100,2)
}

table <- data.frame(hot_names, tot.suit, tot.unsuit, prop.suit, prop.unsuit) %>%
  mutate(across(where(is.numeric), ~ round(., 1)))

table

res <- table[order(table$prop.suit, decreasing = T), ]
res

write.xlsx(res, file = "D:/Trabajo/Analisis/MNE_jabali/Hotspots/Summary_table_hotspots.xls", sheetName = "Sheet1",
           col.names = TRUE, row.names = TRUE, append = FALSE)

```


