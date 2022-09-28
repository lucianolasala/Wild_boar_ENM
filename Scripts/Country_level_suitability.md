### Country-level suitability
----------

Calculation of suitable area in the whole study region and by country.

```r
mosaico <- raster("./Final_model_rasters/mosaic_MSS.asc")
countries <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/Argentina and bordering countries.shp")

masked <- crop(mosaico, countries) %>% mask(countries)
writeRaster(masked, "./Final_model_rasters/mosaic_MSS_mask.asc")
mosaico <- raster("./Final_model_rasters/mosaic_MSS_mask.asc")

suit <- which(mosaico[]==1) 
unsuit <- which(mosaico[]==0)
Nas <- which(is.na(mosaico[]))  # 163771
study_region_suit = round((suit/tot)*100,1)
study_region_suit  # 35.8% of total area has suitability = 1
```

#### Loop over each country

```r
cal = raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/cal_area_mean_thresh_MSS.tif")
proj = raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/proj_area_mean_thresh_MSS.tif")
mosaico = mosaico <- mosaic(cal, proj, fun = "max")
ext <- mosaico@extent

writeRaster(mosaico, filename = "D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS", format = "GTiff", overwrite = TRUE)

mosaico <- raster("./Final_model_rasters/Thresh_mosaic_MSS.tif")

countries <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Paises region estudio_2.gpkg")

count_names <- unique(countries$NAME_0)

tot.suit <- c()
tot.unsuit <- c()
prop.suit <- c()
prop.unsuit <- c()

for(i in 1:length(count_names)) {  
a <- countries %>% filter(NAME_0==count_names[i]) 
masked <- crop(mosaico, a) %>% mask(a)
tot.suit[i] <- sum(values(masked==1), na.rm=TRUE)*100
tot.unsuit[i] <- sum(values(masked==0), na.rm=TRUE)*100
prop.unsuit[i] <- round(as.numeric(table(masked[])[1]/sum(table(masked[])))*100,2)
prop.suit[i] <- round(as.numeric(table(masked[])[2]/sum(table(masked[])))*100,2)
}

table <- data.frame(count_names, tot.suit, tot.unsuit, prop.suit, prop.unsuit) %>% mutate(across(where(is.numeric), ~ round(., 1)))

res <- table[order(table$prop.suit, decreasing = T),]

write.xlsx(res, file = "D:/Trabajo/Analisis/MNE_jabali/Countries/Summary_table_suitability.xls", sheetName = "Sheet1", colNames = TRUE, rowNames = TRUE, append = FALSE)
```
