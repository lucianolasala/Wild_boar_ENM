#### Protected areas data processing
> The folloging script is used to download and process protected areas (PAs) spatial data from the Protected Planet public repository (https://www.protectedplanet.net/en). 
Data from all PAs in the six countries included in the study were processed.
A country code table including the WITS System country names for statistical purposes for the other countries should be consulted here (https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm)

#### Packages and libraries 

```r
install.packages("remotes")
remotes::install_github("luisdva/annotater")
install.packages("wdpar", repos = "https://cran.rstudio.com/")
install.packages("netstat")

library(wdpar) # Interface to the World Database on Protected Areas 
library(dplyr) # A Grammar of Data Manipulation 
library(magrittr) # A Forward-Pipe Operator for R
library(raster) # Geographic Data Analysis and Modeling
library(sf) # Simple Features for R
library(stars) # Spatiotemporal Arrays, Raster and Vector Data Cubes
library(ggmap) # Spatial Visualization with ggplot2 
library(prepr) # Automatic Repair of Single Polygons

# Side note: if error message "Error in wdman::phantomjs(verbose = FALSE) : 
# PhantomJS signals port = 4567 is already in use" appears, restart R session to free port
```

#### Argentina
> The following script was used to download and process PA data for Argentina, and can be adapted, with minor changes, to process data from the other countries (i.e., Chile, Uruguay, Brasil, Bolivia, and Paraguay). 

```r
arg_pa <- wdpa_fetch("ARG", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg")
plot(arg_pa$geometry)

arg_pa <- wdpa_fetch("ARG", wait = TRUE, download_dir = tempdir())
class(arg_pa)
```

##### Clean the data

```r
arg_pa_clean <- wdpar::wdpa_clean(arg_pa)
class(arg_pa_clean)
head(arg_pa_clean)

type <- as.data.frame(arg_pa_clean$MARINE)
summary(type)  #  marine: 21; partial: 22; terrestrial: 406

unique(arg_pa_clean$MARINE)  # "terrestrial" "marine" "partial"  # Codes 0, 1 and 2 in shapefile
st_crs(arg_pa_clean)  # WGS84

arg_pa_clean <- st_transform(arg_pa_clean, crs = st_crs(arg_pa))
st_crs(arg_pa_clean)

st_write(arg_pa_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_clean.shp")
```

##### Subset terrestrial and partial protected areas and generate/save a list

```r
arg_pa_land <-
    arg_pa_clean %>%
    filter(MARINE == "terrestrial" | MARINE == "partial")

# Reproject

arg_pa_land <- st_transform(arg_pa_land, crs = st_crs(arg_pa))

st_write(arg_pa_land, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")

# Generate a list containing all PAs in Argentina

arg <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")

arg_list <- select(arg, NAME, DESIG)

arg_list <- st_drop_geometry(arg_list)

arg_namesDF <- as.data.frame(arg_names)

write.xlsx(arg_list, file = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_list.xls", sheetName = "Sheet1", 
           col.names = TRUE, row.names = TRUE, append = FALSE)
```

#### Calculate percentage of land inside protected areas

```r
statistics2 <-
    arg_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CAT) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    mutate(percentage = (area_km/sum(area_km)) * 100) %>%
    arrange(desc(area_km))

print(statistics2)

statistics2 %>% 
    summarise(a = sum(percentage))  # 100%


# Explore levels for IUCN_CAT = Not reported

colnames(arg_pa_land_WGS84)

sub1 = select(filter(arg_pa_land_WGS84, IUCN_CAT == "Not Reported" & DESIG_ENG == "Ramsar Site, Wetland of International Importance"))
sub1 
colnames(sub1)

sub1 = select(arg_pa_land_WGS84, DESIG_ENG, IUCN_CAT) %>%
       filter(IUCN_CAT == "Not Reported" & DESIG_ENG == "Ramsar Site, Wetland of International Importance")

unique(sub1$DESIG_ENG) 
length(sub1$DESIG_ENG)  # 29

plot(sub1$geometry)

sub5 = unique(arg_pa_land_WGS84$DESIG_ENG)             
sub5  # 94 tipos 

sub2 = select(filter(arg_pa_land_WGS84, IUCN_CAT == "Not Reported" & DESIG_ENG == "Provincial Reserve"))
sub2 
plot(sub2$geometry)

sub3 = select(filter(arg_pa_land_WGS84, IUCN_CAT == "Not Reported" & DESIG_ENG == "Provincial Park"))
sub3 
plot(sub3$geometry)
```



