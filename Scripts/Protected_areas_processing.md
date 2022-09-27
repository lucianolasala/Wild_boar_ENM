### Protected areas data processing 

The folloging script is used to download and process protected areas (PAs) spatial data from the Protected Planet public repository (https://www.protectedplanet.net/en). Data from all PAs in the six countries included in the study were processed. 

```r
install.packages("remotes")
remotes::install_github("luisdva/annotater")
install.packages("wdpar", repos = "https://cran.rstudio.com/")
install.packages("netstat")
install.packages("ggmap")
install.packages("prepr")  # not available (for R version 4.0.2)

library(wdpar) # Interface to the World Database on Protected Areas
library(dplyr) # A Grammar of Data Manipulation 
library(magrittr) # A Forward-Pipe Operator for R
library(sf) # Simple Features for R
library(prepr) # Automatic Repair of Single Polygons
library(netstat)

# Side note: if error message "Error in wdman::phantomjs(verbose = FALSE) : 
# PhantomJS signals port = 4567 is already in use" appears, restart R session to free port
```

### Argentina
> The following script was used to download and process PA data for Argentina and can be adapted, with minor changes, to process data from the other countries (i.e., Chile, Uruguay, Brasil, Bolivia, and Paraguay). 

```r
arg_pa <- wdpa_fetch("ARG", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra")
plot(arg_pa$geometry)

arg_pa <- wdpa_fetch("ARG", wait = TRUE, download_dir = tempdir())
```

> Clean the data Briefly, the cleaning steps include: excluding protected areas that are not yet implemented, excluding protected areas with limited conservation value, replacing missing data codes (e.g. "0") with missing data values (NA), replacing protected areas represented as points with circular protected areas that correspond to their reported extent, repairing any topological issues with the geometries, and erasing overlapping areas.

```r
arg_pa_clean <- wdpar::wdpa_clean(arg_pa, erase_overlaps = FALSE)
type <- as.data.frame(arg_pa_clean$MARINE)
summary(type)  #  marine: 21; partial: 22; terrestrial: 406

unique(arg_pa_clean$MARINE)  # "terrestrial" "marine" "partial" codes 0, 1 and 2 in shapefile
st_crs(arg_pa_clean)  # WGS84

arg_pa_clean <- st_transform(arg_pa_clean, crs = st_crs(arg_pa))

st_write(arg_pa_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_clean.shp")
```

> Subset terrestrial and partial protected areas and generate/save a list

```r
arg_pa_clean <- arg_pa_clean %>% filter(MARINE == "terrestrial" | MARINE == "partial")

arg_pa_clean <- st_transform(arg_pa_clean, crs = st_crs(arg_pa))

st_write(arg_pa_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")
```

> Generate a list containing all PAs in Argentina

```r
arg <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")

arg_list <- select(arg, NAME, DESIG)
arg_list <- st_drop_geometry(arg_list)

arg_namesDF <- as.data.frame(arg_names)

write.xlsx(arg_list, file = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_list.xls", sheetName = "Sheet1", 
col.names = TRUE, row.names = TRUE, append = FALSE)
```

> Calculate percentage of land inside protected areas

```r
statistics2 <- arg_pa_land %>%
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
```

> Explore levels for IUCN_CAT = Not reported

```r
colnames(arg_pa_land_WGS84)

sub1 = select(filter(arg_pa_land_WGS84, IUCN_CAT == "Not Reported" & DESIG_ENG == "Ramsar Site, Wetland of International Importance"))

sub1 = select(arg_pa_land_WGS84, DESIG_ENG, IUCN_CAT) %>%
filter(IUCN_CAT == "Not Reported" & DESIG_ENG == "Ramsar Site, Wetland of International Importance")

unique(sub1$DESIG_ENG) 
length(sub1$DESIG_ENG)  # 29

sub5 = unique(arg_pa_land_WGS84$DESIG_ENG)             
sub5  # 94 types 

sub2 = select(filter(arg_pa_land_WGS84, IUCN_CAT == "Not Reported" & DESIG_ENG == "Provincial Reserve"))
sub2 
plot(sub2$geometry)

sub3 = select(filter(arg_pa_land_WGS84, IUCN_CAT == "Not Reported" & DESIG_ENG == "Provincial Park"))
sub3 
plot(sub3$geometry)
```