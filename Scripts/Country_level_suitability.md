### Country-level suitability
----------
Calculation of suitable area in the whole study region and by country 


#### All countries

```r
mosaico <- raster("./Final_model_rasters/mosaic_MSS.asc")
class(mosaico)

vals <- which(!is.na(mosaico[]))  # 0 and 1
vals[1000]
length(vals)  # 172216

not.na <- cellStats(mosaico, function(i,...) sum(!is.na(i))) # 172216

freq(mosaico)  # 54655 cells = 1

NAs <- freq(mosaico, value=NA)
NAs  # 259459

ceros <- freq(mosaico, value=0)
ceros  # 117286

unos <- freq(mosaico, value=1)
unos  # 54930

total <- unos+ceros
total  # 172216

# Alternativamente...

Nas <- which(is.na(mosaico[]))  # 259459
length(Nas)

unsuit = mosaico[mosaico[] == 0]
unsuit_vals <- length(unsuit)  # 117286
unsuit_vals

suit = mosaico[mosaico[] == 1]
suit_vals <- length(suit)   # 54930
suit_vals

total <- suit_vals + unsuit_vals
total  # 172216


test <- Which(mosaico, cells=TRUE)  # zeros become FALSE
length(test)
summary(test)
test[991]
length(test)

mosaico2 <- read_stars("./Final_model_rasters/mosaic_MSS.asc")
class(mosaico2)

vals3 <- which(!is.na(mosaico2[[1]]))  # OK
vals3

vals <- mosaico2[1]  # stars object with 2 dimensions and 1 attribute
class(vals)  # "stars"

mosaico2["mosaico_MSS.asc"]  # Equivalente al anterior
```

#### Crop and mask to study region, leaving out pixels in ecoregions that lie outside 

```r
mosaico <- raster("./Final_model_rasters/mosaic_MSS.asc")

countries <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/Argentina and bordering countries.shp")

masked <- crop(mosaico, countries) %>% mask(countries)

writeRaster(masked, "./Final_model_rasters/mosaic_MSS_mask.asc")

mosaico <- raster("./Final_model_rasters/mosaic_MSS_mask.asc")

suit <- which(mosaico[]==1) 
suit <- length(suit)  # 53632

suit1 = mosaico[mosaico[]==1]
length(suit1)  # 53632

unsuit <- which(mosaico[]==0)
unsuit <- length(unsuit)  # 96099  

tot = suit + unsuit
tot

Nas <- which(is.na(mosaico[]))  # 163771
length(Nas)   

dim(mosaico)
pixels_tot = 686*457  # 313502 pixels
pixels_tot  # 313502 (NAs + 0s + 1s)

test = length(Nas)+suit+unsuit  # 313502
test

# Percentage study region with wild boar suitable area

study_region_suit = round((suit/tot)*100,1)
study_region_suit  # 35.8% of total area has suitability = 1
```

#### Loop over each country

```r
mosaico <- raster("./Final_model_rasters/mosaic_MSS.asc")
countries <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/Argentina and bordering countries.shp")
countries1 <- countries[-7,]  # Drop Malvinas

paises <- countries1$NAME
prop.suit <- c()
prop.unsuit <- c()

for(i in 1:length(paises)) {  # Loops over every pais
  a <- countries %>% filter(NAME==paises[i])  # Stores in "a" each pais polygon 
  
masked <- crop(mosaico, a) %>% mask(a)  # Crop and mask
  
prop.unsuit[i] <- round(as.numeric(table(masked[])[1]/sum(table(masked[])))*100, 2)
  
prop.suit[i] <- round(as.numeric(table(masked[])[2]/sum(table(masked[])))*100,2)
}

table <- data.frame(paises, prop.suit, prop.unsuit)
table
```
