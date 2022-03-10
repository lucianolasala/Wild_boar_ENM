#### Protected areas data processing
> The folloging script is used to download and process protected areas (PAs) spatial data from the public repository  [Protected Planet](https://www.protectedplanet.net/en). 

https://cran.r-project.org/web/packages/wdpar/vignettes/wdpar.html

rm(list=ls(all=TRUE))

install.packages("remotes")
remotes::install_github("luisdva/annotater")
library(annotater) # Annotate Package Load Calls

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

# Note: when error message "Error in wdman::phantomjs(verbose = FALSE) : 
# PhantomJS signals port = 4567 is already in use" appears, restart R session to free port

#-----------------------------------------------------------------------------
# Argentina
#-----------------------------------------------------------------------------

arg_pa <- wdpa_fetch("ARG", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg")
plot(arg_pa$geometry)

arg_pa <- wdpa_fetch("ARG", wait = TRUE, download_dir = tempdir())
class(arg_pa)

# Clean data

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

# Checking geometry validity

valid = st_is_valid(arg_pa_clean)
length(valid)  # 449

which(valid=="FALSE") # 0
length(which(valid=="TRUE")) # 449  

pa[c(...),]


#--------------------------------------------------------------
# Source to Argentina's boundary data 
#--------------------------------------------------------------

rm(list=ls(all=TRUE))

file_path <- tempfile(fileext = "rds")

download.file("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_ARG_0_sf.rds",
file_path)

# Import Argentina's boundary

arg_boundary_data <- readRDS(file_path)
class(arg_boundary_data)
plot(arg_boundary_data$geometry)
st_crs(arg_boundary_data)

# Working with shapefile that includes Malvinas

arg_boundary_data <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/ARG_adm/ARG_adm0.shp")
plot(arg_boundary_data$geometry)
st_crs(arg_boundary_data)


# Repair any geometry issues, dissolve the border, reproject to same
# coordinate system as the protected area data, and repair the geometry again

arg_boundary_data <-
    arg_boundary_data %>%
    st_set_precision(1000) %>%
    sf::st_make_valid() %>%
    st_set_precision(1000) %>%
    st_combine() %>%
    st_union() %>%
    st_set_precision(1000) %>%
    sf::st_make_valid() %>%
    st_transform(st_crs(arg_pa_clean)) %>%
    sf::st_make_valid()

class(arg_boundary_data)
plot(arg_boundary_data)

st_crs(arg_boundary_data)  # WGS84

st_write(arg_boundary_data, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_bound.shp")


# Clip protected areas to the coastline

# In original data base, allowed values are: 
# 0 (predominantly or entirely terrestrial)
# 1 (Coastal: marine and terrestrial)
# 2 (predominantly or entirely marine)

arg_pa_land <-
    arg_pa_clean %>%
    filter(MARINE == "terrestrial" | MARINE == "partial") %>%
    st_intersection(arg_boundary_data) %>%
    rbind(arg_pa_clean %>%
              filter(MARINE == "patial" | MARINE == "terrestrial") %>%
              st_difference(arg_boundary_data))

class(arg_pa_land)
plot(arg_pa_land$geometry)
st_crs(arg_pa_land)  # Tiene muchos ID y parametros diferentes a lo reproyectado abajo 

# Reproject data

arg_pa_land <- st_transform(arg_pa_land, crs = st_crs(arg_pa))
st_crs(arg_pa_land)

st_write(arg_pa_land, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")

# Generate a list containing all PAs in Argentina

arg <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")

arg_list <- select(arg, NAME, DESIG)
head(arg_list)

arg_list <- st_drop_geometry(arg_list)
head(arg_list)
is.data.frame(arg_list)

arg_namesDF <- as.data.frame(arg_names)
class(arg_namesDF)
arg_namesDF

write.xlsx(arg_list, file = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_list.xls", sheetName = "Sheet1", 
           col.names = TRUE, row.names = TRUE, append = FALSE)


#--------------------------------------------------------------------
# Calculate total amount of area inside protected areas (km^2)
#--------------------------------------------------------------------

statistics1 <-
    arg_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(MARINE) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    arrange(desc(area_km))

print(statistics1)

#--------------------------------------------------------------------
# Calculate percentage of land inside protected areas (km^2)
#--------------------------------------------------------------------

statistics2 <-
    arg_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CAT) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    mutate(percentage = (area_km / sum(area_km)) * 100) %>%
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



#-----------------------------------------------------------------------------
# Chile
#-----------------------------------------------------------------------------

library(wdpar) # Interface to the World Database on Protected Areas 
library(dplyr) # A Grammar of Data Manipulation 
library(ggmap) # Spatial Visualization with ggplot2 

chile_pa <- wdpa_fetch("CHL", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi")
plot(arg_pa$geometry)

chile_pa <- wdpa_fetch("CHL", wait = TRUE, download_dir = tempdir())

# Clean data

chile_clean <- wdpar::wdpa_clean(chile_pa)
st_crs(chile_clean)
st_crs(chile_pa)

chile_clean <- st_transform(chile_clean, crs = st_crs(chile_pa))
st_crs(chile_clean)

st_write(chile_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Chi_clean.shp")

#--------------------------------------------------------------
# Source to Chile's boundary data 
#--------------------------------------------------------------

rm(list=ls(all=TRUE))

file_path <- tempfile(fileext = "rds")

download.file("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_CHL_0_sf.rds",
              file_path)

# Import Chile's boundary

chil_boundary_data <- readRDS(file_path)

class(chil_boundary_data)
plot(chil_boundary_data$geometry) # old-style crs object detected; please recreate object with a recent sf::st_crs()
st_crs(chil_boundary_data)

# Repair any geometry issues, dissolve the border, reproject to same
# coordinate system as the protected area data, and repair the geometry again

chil_boundary_data <-
    chil_boundary_data %>%
    st_set_precision(1000) %>%
    sf::st_make_valid() %>%
    st_set_precision(1000) %>%
    st_combine() %>%
    st_union() %>%
    st_set_precision(1000) %>%
    sf::st_make_valid() %>%
    st_transform(st_crs(chile_pa)) %>%
    sf::st_make_valid()

st_crs(chil_boundary_data)  # WGS84

st_write(chil_boundary_data, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Chi_bound.shp")

# Clip protected areas to the coastline

chi_pa_land <-  # Selection of thos PAs that are either exclusively terrestrial or partial
    chile_clean %>%
    filter(MARINE == "terrestrial" | MARINE == "partial") 
plot(chi_pa_land$geometry)

st_write(chi_pa_land, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Chi_PA_land.shp")


#--------------------------------------------------------------------
# Calculate total amount of area inside protected areas (km^2)
#--------------------------------------------------------------------

chi_pa_land = st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Chi_PA_final.shp")

statistics1 <-
    chi_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(MARINE) %>%
    summarize(area_km = sum(AREA_KM)) %>%
    ungroup() %>%
    arrange(desc(area_km))

print(statistics1)

write.csv(statistics1,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Stats_1.csv") 

#--------------------------------------------------------------------
# Calculate percentage of land inside protected areas (km^2)
#--------------------------------------------------------------------

statistics2 <-
    chi_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CA) %>%
    summarize(area_km = sum(AREA_KM)) %>%
    ungroup() %>%
    mutate(percentage = (area_km / sum(area_km)) * 100) %>%
    arrange(desc(area_km))

print(statistics2)

write.csv(statistics2,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Stats_2.csv") 

statistics2 %>% 
    summarise(a = sum(percentage))  # 100%

#-----------------------------------------------------------------------------
# Uruguay
#-----------------------------------------------------------------------------

library(wdpar) # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas
library(dplyr) # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation
library(ggmap) # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2

uru_pa <- wdpa_fetch("URY", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury")

uru_pa <- wdpa_fetch("URY", wait = TRUE, download_dir = tempdir())

# Clean data

uru_clean <- wdpar::wdpa_clean(uru_pa)
st_crs(uru_clean)
st_crs(uru_pa)

uru_clean <- st_transform(uru_clean, crs = st_crs(uru_pa))
st_crs(uru_clean)

st_write(uru_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury/Ury_clean.shp")

# Select terrestrial and partial

uru_land <-  # Selection of thos PAs that are either exclusively terrestrial or partial
    uru_clean %>%
    filter(MARINE == "terrestrial" | MARINE == "partial") 
plot(uru_land$geometry)

st_write(uru_land, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury/Ury_PA_land.shp")


#--------------------------------------------------------------------
# Calculate total amount of area inside protected areas (km^2)
#--------------------------------------------------------------------

uru_pa_land = st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury/Ury_PA_land.shp")

statistics1 <-
    uru_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(MARINE) %>%
    summarize(area_km = sum(AREA_KM)) %>%
    ungroup() %>%
    arrange(desc(area_km))

print(statistics1)

write.csv(statistics1,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury/Stats_1.csv") 

#--------------------------------------------------------------------
# Calculate percentage of land inside protected areas (km^2)
#--------------------------------------------------------------------

statistics2 <-
    uru_pa_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CA) %>%
    summarize(area_km = sum(AREA_KM)) %>%
    ungroup() %>%
    mutate(percentage = (area_km / sum(area_km)) * 100) %>%
    arrange(desc(area_km))

print(statistics2)

write.csv(statistics2,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury/Stats_2.csv") 

statistics2 %>% 
    summarise(a = sum(percentage))  # 100%


#-----------------------------------------------------------------------------
# Paraguay
#-----------------------------------------------------------------------------

library(wdpar) # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas
library(dplyr) # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation
library(ggmap) # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2

para_pa <- wdpa_fetch("PRY", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury")

para_pa <- wdpa_fetch("PRY", wait = TRUE, download_dir = tempdir())

# Clean data

para_clean <- wdpar::wdpa_clean(para_pa)

para_clean <- st_transform(para_clean, crs = st_crs(para_pa))
st_crs(para_clean)

st_write(para_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Pry/Pry_clean.shp")

#--------------------------------------------------------------------
# Calculate total amount of area inside protected areas (km^2)
#--------------------------------------------------------------------

statistics1 <-
    para_clean %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(MARINE) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    arrange(desc(area_km))

print(statistics1)

write.csv(statistics1,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Pry/Stats_1.csv") 

#--------------------------------------------------------------------
# Calculate percentage of land inside protected areas (km^2)
#--------------------------------------------------------------------

statistics2 <-
    para_clean %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CAT) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    mutate(percentage = (area_km / sum(area_km)) * 100) %>%
    arrange(desc(area_km))

print(statistics2)

write.csv(statistics2,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Pry/Stats_2.csv") 

statistics2 %>% 
    summarise(a = sum(percentage))  # 100%

#-----------------------------------------------------------------------------
# Bolivia
#-----------------------------------------------------------------------------

library(wdpar) # Interface to the World Database on Protected Areas 
library(dplyr) # A Grammar of Data Manipulation 
library(ggmap) # Spatial Visualization with ggplot2 

bol_pa <- wdpa_fetch("BOL", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Ury")

bol_pa <- wdpa_fetch("BOL", wait = TRUE, download_dir = tempdir())

# Clean data

bol_pa_clean <- wdpar::wdpa_clean(bol_pa)

bol_pa_clean <- st_transform(bol_pa_clean, crs = st_crs(bol_pa))
st_crs(bol_pa_clean)

st_write(bol_pa_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bol/Bol_clean.shp")

#--------------------------------------------------------------------
# Calculate total amount of area inside protected areas (km^2)
#--------------------------------------------------------------------

statistics1 <-
    bol_pa_clean %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(MARINE) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    arrange(desc(area_km))

print(statistics1)

write.csv(statistics1,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bol/Stats_1.csv") 

#--------------------------------------------------------------------
# Calculate percentage of land inside protected areas (km^2)
#--------------------------------------------------------------------

statistics2 <-
    bol_pa_clean %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CAT) %>%
    summarize(area_km = sum(AREA_KM2)) %>%
    ungroup() %>%
    mutate(percentage = (area_km / sum(area_km)) * 100) %>%
    arrange(desc(area_km))

print(statistics2)

write.csv(statistics2,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bol/Stats_2.csv") 

statistics2 %>% 
    summarise(a = sum(percentage))  # 100%


#-----------------------------------------------------------------------------
# Brasil
#-----------------------------------------------------------------------------

library(wdpar) # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas # Interface to the World Database on Protected Areas
library(dplyr) # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation # A Grammar of Data Manipulation
library(ggmap) # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2 # Spatial Visualization with ggplot2

bra_pa <- wdpa_fetch("BRA", wait = TRUE, download_dir = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra")

bra_pa <- wdpa_fetch("BRA", wait = TRUE, download_dir = tempdir())

# Clean data

bra_clean <- wdpar::wdpa_clean(bra_pa)
st_crs(bra_clean)
st_crs(bra_pa)

bra_clean <- st_transform(bra_clean, crs = st_crs(bra_pa))
st_crs(bra_clean)

st_write(bra_clean, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_clean.shp")

# Brazil boundary data

file_path <- tempfile(fileext = "rds")

download.file("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_BRA_0_sf.rds",
              file_path)

# Import Brazil's boundary

bra_boundary <- readRDS(file_path)
class(bra_boundary)
st_crs(bra_boundary)

# Repair any geometry issues, dissolve the border, reproject to same
# coordinate system as the protected area data, and repair the geometry again

bra_boundary <-
    bra_boundary %>%
    st_set_precision(1000) %>%
    sf::st_make_valid() %>%
    st_set_precision(1000) %>%
    st_combine() %>%
    st_union() %>%
    st_set_precision(1000) %>%
    sf::st_make_valid() %>%
    st_transform(st_crs(bra_pa)) %>%
    sf::st_make_valid()

class(bra_boundary)
st_crs(bra_boundary)

st_write(bra_boundary, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_bound.shp")

# Clip protected areas to the coastline

bra_land <-
    bra_clean %>%
    filter(MARINE == "terrestrial" | MARINE == "partial")

plot(bra_land$geometry)

st_write(bra_land, "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_PA_land.shp")

# Generate a list containing all PAs in Brazil

bra <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_PA_land.shp")
head(bra)

bra_names <- bra$NAME
head(bra_names)

write.xlsx(bra_names, file = "C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_PA_land.xls", sheetName = "Sheet1", 
           col.names = TRUE, row.names = TRUE, append = FALSE)


#--------------------------------------------------------------------
# Calculate total amount of area inside protected areas (km^2)
#--------------------------------------------------------------------

bra_land = st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_PA_land.shp")

statistics1 <-
    bra_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(MARINE) %>%
    summarize(area_km = sum(AREA_KM)) %>%
    ungroup() %>%
    arrange(desc(area_km))

print(statistics1)

write.csv(statistics1,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Stats_1.csv") 

#--------------------------------------------------------------------
# Calculate percentage of land inside protected areas (km^2)
#--------------------------------------------------------------------

statistics2 <-
    bra_land %>%
    as.data.frame() %>%
    select(-geometry) %>%
    group_by(IUCN_CA) %>%
    summarize(area_km = sum(AREA_KM)) %>%
    ungroup() %>%
    mutate(percentage = (area_km / sum(area_km)) * 100) %>%
    arrange(desc(area_km))

print(statistics2)

write.csv(statistics2,"C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Stats_2.csv") 

statistics2 %>% 
    summarise(a = sum(percentage))  # 100%


#----------------------------------------------------------------------
# Calculo de AP en areas con jabali
#----------------------------------------------------------------------

r <- read_stars("C:/Users/User/Desktop/Julian/Modelado_6_cal_area_mean_thresholded.tif")

pa <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")
pa_bra <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Bra/Bra_PA_final.shp")
pa_chi <- st_read("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Chi/Chi_PA_final.shp")


pa <- pa %>% mutate(
    Max = st_extract(r, pa, fun = max, na.rm = TRUE))

remove(pa)
pa

# Error in s2_geography_from_wkb(x, oriented = oriented, check = check) : 
# Evaluation error: Found 1 feature with invalid spherical geometry.
# [1] Loop 0 is not valid: Edge 111 crosses edge 113.

valid = st_is_valid(pa, reason = TRUE)
length(valid)

which(valid=="FALSE") # 8 (166 374 392 414 425 426 452 496) 
length(which(valid=="TRUE")) # 496  

pa[c(166, 374, 392, 414, 425, 426, 452, 496),]

# [166] "Loop 0: Edge 111 crosses edge 113" (Lago Puelo)
# [374] "Loop 13: Edge 16 crosses edge 37" (Reserva Costa Atlantica de Tierra del Fuego) 
# [392] "Loop 2: Edge 1 crosses edge 10" (Lagunas y Esteros del Iberá)
# [414] "Loop 0: Edge 106 crosses edge 108" (Palmar Yatay) 
# [425] "Loop 26: Edge 22 crosses edge 67" (Península Valdés)    
# [426] "Loop 20: Edge 0 crosses edge 2" (Ischigualasto / Talampaya Natural Parks) 
# [452] "Loop 73: Edge 2 crosses edge 30" (Costa Atlántica Tierra del Fuego)
# [496] "Loop 0 edge 10 crosses loop 1 edge 0" (Mar Chiquita - Dragones de Malvinas)




#--------Metodo 2---------------------------

v <- extract(r, pa_argentina)
head(v)
class(v)

pct <- function(x, p = 1) {
    if(length(x[x >= p]) < 1 )  return(0) 
    if(length(x[x >= p]) == length(x) ) return(1) 
    else return( length(x[x >= p]) / length(x) ) 
}


unlist(lapply(v, pct))


pa_argentina@data$pcts <- unlist(lapply(v, pct))
pa_argentina@data
raster:spplot(pa_argentina, "pcts")


#-----------------------------------------------------------------

# Function to tabulate pixel values by region & return a data frame

tabFunc <- function(indx, extracted, region, regname) {
    dat <- as.data.frame(table(extracted[[indx]]))
    dat$name <- region[[regname]][[indx]]
    return(dat)
}

tabs <- lapply(seq(v), tabFunc, v, pa_argentina, "NAME")


#----------------------------------------------------------------------
# Extraction of PAs with wild boar records
#----------------------------------------------------------------------

# Load complete data set with occurrences

wb <- read.csv("C:/Users/User/Documents/Analyses/Wild boar ENM/Occurrences/S_scrofa_PA.csv")
head(wb)

# Load PAs in Argentina

pa_arg <- readOGR("C:/Users/User/Documents/Analyses/Wild boar ENM/Vectors/AP_Arg/Arg_PA_final.shp")
head(pa_arg)


