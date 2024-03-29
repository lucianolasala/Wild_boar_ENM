### Mapping of Ecological Niche Models

#### Packages and libraries 
```r
library(ggsn)
library(tidyverse)
library(stars)
library(sf)
library(paletteer)
library(gridExtra)
library(readr)
library(magrittr)
library(raster)
library(ggplot2)
library(paletteer)
library(dplyr)

```
#### Suitability in study region (includes biodiversity hotspots)

```r
sr <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Argentina_and_bordering_WGS84.shp")
mal <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Malvinas_Estados.gpkg")

sa_ctroids <- cbind(sr, st_coordinates(st_centroid(sr)))
sa_ctroids1 <- sa_ctroids %>% 
  mutate(COUNTRY = case_when(NAME == "ARGENTINA" ~ "AR", 
  NAME == "BOLIVIA" ~ "BO",
  NAME == "BRAZIL" ~ "BR",
  NAME == "PARAGUAY" ~ "PY",
  NAME == "URUGUAY" ~ "UY"))

# Biodiversity hotspots

af <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Atlantic_Forest.gpkg")  
ce <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Cerrado.gpkg")
cr <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Chilean_Rainfall_Forests.gpkg")
ta <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Tropical_Andes.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

ras <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Thresh_mosaic_MSS.tif")

full_pts <- rasterToPoints(ras, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% mutate(Group =
                              case_when(Thresh_mosaic_MSS == 0 ~ "Absence", 
                                        Thresh_mosaic_MSS == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = sr, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = mal, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = af, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = ce, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = cr, alpha = 0, color = "black", size = 0.4) +
geom_sf(data = ta, alpha = 0, color = "black", size = 0.4) +
coord_sf() +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.75, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"),
legend.text = element_text(size = 14)) + #change legend text font size
annotate(geom = "text", x=-51.8, y=-25, label="AF", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-53, y=-18, label="CE", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-72, y=-34.5, label="CF", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-67, y=-20, label="TA", size = 6, color="#1F618D", fontface = "bold") +
annotate(geom = "text", x=-72.5, y=-38, label="CL", size = 6, color="black", family = "sans", fontface = "bold") +
geom_text(data = sa_ctroids1, aes(X, Y, label = COUNTRY), size = 6, family = "sans", fontface = "bold") + 
ggsn::scalebar(data = sr, location = "bottomright", anchor = c(x = -50, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")

p

ggsave(plot = p, "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Threshold models/Study_region_thresh_new.png", width = 8.4, height = 12)
```

#### Argentina

```r
arg <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/ARG_adm/Arg_adm1.shp")
st_crs(arg)  # Coordinate Reference System: WGS 84
arg$NAME_1

mosaico <- raster("./Final_model_rasters/Study_region_thresh.tif")
sa_ctroids <- cbind(arg, st_coordinates(st_centroid(arg)))

sa_ctroids1 <- sa_ctroids %>% 
  mutate(NAME_1 = case_when(NAME_1 == "Buenos Aires" ~ "B", 
  NAME_1 == "Córdoba" ~ "X",
  NAME_1 == "Catamarca" ~ "K",
  NAME_1 == "Chaco" ~ "H",
  NAME_1 == "Chubut" ~ "U",
  NAME_1 == "Corrientes" ~ "W",
  NAME_1 == "Entre Ríos" ~ "E",
  NAME_1 == "Formosa" ~ "P",
  NAME_1 == "Jujuy" ~ "Y",
  NAME_1 == "La Pampa" ~ "L",
  NAME_1 == "La Rioja" ~ "F",
  NAME_1 == "Mendoza" ~ "M",
  NAME_1 == "Misiones" ~ "N",
  NAME_1 == "Neuquén" ~ "Q",
  NAME_1 == "Río Negro" ~ "R",
  NAME_1 == "San Juan" ~ "J",
  NAME_1 == "San Luis" ~ "D",
  NAME_1 == "Santa Cruz" ~ "Z",
  NAME_1 == "Santa Fe" ~ "S",
  NAME_1 == "Santiago del Estero" ~ "G",
  NAME_1 == "Tierra del Fuego" ~ "V",
  NAME_1 == "Tucumán" ~ "T"))

# Crop and mask 

arg_masked <- crop(mosaico, arg) %>% mask(arg)

writeRaster(arg_masked,"./Final_model_rasters/ENM_argentina_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

arg_ras <- raster("./Final_model_rasters/ENM_argentina_thresh.tif")
full_pts <- rasterToPoints(arg_ras, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% mutate(Group =
                              case_when(ENM_argentina_thresh == 0 ~ "Absence", 
                                        ENM_argentina_thresh == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = arg, alpha = 0, color = "black", size = 0.5) +
coord_sf() +
scale_x_continuous(limits = c(-75,-50)) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.75, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"), 
legend.text = element_text(size = 14)) + #change legend text font size
geom_text(data = sa_ctroids1, aes(X, Y, label = NAME_1), size = 6, family = "sans", fontface = "plain") + 
annotate(geom="text", x=-67, y=-24.5, label="A", size = 7, color="black") +
ggsn::scalebar(data = arg, location = "bottomright", anchor = c(x = -55, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") +
theme(plot.margin = margin(1,0.1,0.4,0, "cm"))

p

ggsave(plot = p, "./Plots/Threshold models/Argentina_thresh.png", width = 8.4, height = 12)
```

#### Brazil 

```r
bra <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/BRA_adm/BRA_adm1.shp")
st_crs(bra)  # Coordinate Reference System: WGS 84

mosaico <- raster("./Final_model_rasters/Thresh_mosaic_MSS.tif")
bra_masked <- crop(mosaico, bra) %>% mask(bra)

writeRaster(bra_masked,"./Final_model_rasters/ENM_brasil_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

bra_masked <- raster("./Final_model_rasters/ENM_brasil_thresh.tif")

full_pts <- rasterToPoints(bra_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% mutate(Group =
                                case_when(ENM_brasil_thresh == 0 ~ "Absence", 
                                          ENM_brasil_thresh == 1 ~ "Presence")) 

sa_ctroids1 <- cbind(bra, st_coordinates(st_centroid(bra)))
sa_ctroids2 <- sa_ctroids1 %>% 
  mutate(NAME_1 = case_when(NAME_1 == "Rio Grande do Sul" ~ "RS",
  NAME_1 == "Paraná" ~ "PR",
  NAME_1 == "São Paulo" ~ "SP",
  NAME_1 == "Rio de Janeiro" ~ "RJ",
  NAME_1 == "Minas Gerais" ~ "MG",
  NAME_1 == "Mato Grosso do Sul" ~ "MS",
  NAME_1 == "Mato Grosso" ~ "MT",
  NAME_1 == "Rondônia" ~ "RO",
  NAME_1 == "Acre" ~ "AC",
  NAME_1 == "Amazonas" ~ "AM",
  NAME_1 == "Roraima" ~ "RR",
  NAME_1 == "Pará" ~ "PA",
  NAME_1 == "Amapá" ~ "AP",
  NAME_1 == "Maranhão" ~ "MA",
  NAME_1 == "Tocantins" ~ "TO",
  NAME_1 == "Piauí" ~ "PI",
  NAME_1 == "Ceará" ~ "CE",
  NAME_1 == "Bahia" ~ "BA"))

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = bra, alpha = 0, color = "black", size = 0.5) +
coord_sf() +
scale_x_continuous(limits = c(-75,-30)) +
scale_y_continuous(limits = c(-35,5)) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.2, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"),
legend.text = element_text(size = 14)) + # change legend text font size
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME_1), size = 5, family = "sans", fontface = "plain") +
annotate(geom="text", x=-49.5, y=-27, label="SC", size = 5, color="black") + 
annotate(geom="text", x=-36.3, y=-4.2, label="RN", size = 5, color="black") +
annotate(geom="text", x=-33.8, y=-6.7, label="PB", size = 5, color="black") +
annotate(geom="text", x=-33.8, y=-8.2, label="PE", size = 5, color="black") +
annotate(geom="text", x=-34.5, y=-10, label="AL", size = 5, color="black") +
annotate(geom="text", x=-36, y=-11.5, label="SE", size = 5, color="black") +
annotate(geom="text", x=-50, y=-16.5, label="GO", size = 5, color="black") +
annotate(geom="text", x=-48, y=-14.8, label="DF", size = 5, color="black") +
theme(plot.margin = margin(0,0.2,0,0.5, "cm")) +
ggsn::scalebar(data = bra, location = "bottomright", anchor = c(x = -35, y = -33),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")   

p

ggsave(plot = p, "./Plots/Threshold models/Brasil_thresh.png", width = 10, height = 10, dpi = "retina")
```

#### Uruguay

```r
uru <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/URY_adm/URY_adm1.shp")
st_crs(uru)  # Coordinate Reference System: WGS 84

mosaico <- raster("./Final_model_rasters/Thresh_mosaic_MSS.tif")
uru_masked <- crop(mosaico, uru) %>% mask(uru)
writeRaster(uru_masked,"./Final_model_rasters/ENM_uruguay_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

uru_masked <- raster("./Final_model_rasters/ENM_uruguay_thresh.tif")

full_pts <- rasterToPoints(uru_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(ENM_uruguay_thresh == 0 ~ "Absence", 
                           ENM_uruguay_thresh == 1 ~ "Presence")) 

sa_ctroids1 <- cbind(uru, st_coordinates(st_centroid(uru)))
sa_ctroids2 <- sa_ctroids1 %>% 
  mutate(NAME_1 = case_when(NAME_1 == "Artigas" ~ "AR",
  NAME_1 == "Canelones" ~ "CA",
  NAME_1 == "Cerro Largo" ~ "CL",
  NAME_1 == "Colonia" ~ "CO",
  NAME_1 == "Durazno" ~ "DU",
  NAME_1 == "Flores" ~ "FS",
  NAME_1 == "Florida" ~ "FD",
  NAME_1 == "Lavalleja" ~ "LA",
  NAME_1 == "Maldonado" ~ "MA",
  NAME_1 == "Paysandú" ~ "PA",
  NAME_1 == "Río Negro" ~ "RN",
  NAME_1 == "Rivera" ~ "RV",
  NAME_1 == "Rocha" ~ "RO",
  NAME_1 == "Salto" ~ "SA",
  NAME_1 == "San José" ~ "SJ",
  NAME_1 == "Soriano" ~ "SO",
  NAME_1 == "Tacuarembó" ~ "TA",
  NAME_1 == "Treinta y Tres" ~ "TT"))

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = uru, alpha = 0, color = "black", size = 0.5) +
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME_1), size = 6, family = "sans", fontface = "plain") +
coord_sf() +
scale_x_continuous(limits = c(-59,-52.5)) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.82, 0.85)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 14, face = "bold"), 
legend.text = element_text(size = 12)) + 
annotate(geom="text", x=-53, y=-33, label="RV", size = 7, color="black") +
annotate(geom="text", x=-56.2, y=-35.1, label="MO", size = 7, color="black") +
ggsn::scalebar(data = uru, location = "bottomright", anchor = c(x = -53, y = -35),
dist = 50,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84")

p

ggsave(plot = p, "./Plots/Threshold models/Uruguay_thresh.png", width = 10, height = 10)
```

#### Paraguay

```r
para <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/PRY_adm/PRY_adm1.shp")
st_crs(para)  # Coordinate Reference System: WGS 84
mosaico <- raster("./Final_model_rasters/Thresh_mosaic_MSS.tif")
para_masked <- crop(mosaico, para) %>% mask(para)

writeRaster(para_masked,"./Final_model_rasters/Paraguay_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

para_masked <- raster("./Final_model_rasters/Paraguay_thresh.tif")
full_pts <- rasterToPoints(para_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(Paraguay_thresh == 0 ~ "Absence", 
                           Paraguay_thresh == 1 ~ "Presence")) 

sa_ctroids1 <- cbind(para, st_coordinates(st_centroid(para)))
  sa_ctroids2 <- sa_ctroids1 %>% mutate(NAME_1 =
  case_when(NAME_1 == "Alto Paraguay" ~ "16",
  NAME_1 == "Alto Paraná" ~ "10",
  NAME_1 == "Amambay" ~ "13",
  NAME_1 == "Boquerón" ~ "19",
  NAME_1 == "Caaguazú" ~ "5",
  NAME_1 == "Caazapá" ~ "6",
  NAME_1 == "Canindeyú" ~ "14",
  NAME_1 == "Central" ~ "11",
  NAME_1 == "Concepción" ~ "1",
  NAME_1 == "Cordillera" ~ "3",
  NAME_1 == "Guairá" ~ "4",
  NAME_1 == "Itapúa" ~ "7",
  NAME_1 == "Misiones" ~ "8",
  NAME_1 == "Ñeembucú" ~ "12",
  NAME_1 == "Paraguarí" ~ "9",
  NAME_1 == "Presidente Hayes" ~ "15",
  NAME_1 == "San Pedro" ~ "2"))

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = para, alpha = 0, color = "black", size = 0.5) +
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME_1), size = 6, family = "sans", fontface = "plain") +
coord_sf() +
scale_x_continuous(limits = c(-63,-53)) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.8, 0.85)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 14, face = "bold"), 
legend.text = element_text(size = 12)) + # change legend text font size
ggsn::scalebar(data = para, location = "bottomleft", anchor = c(x = -62.5, y = -27.5), dist = 100, st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") +
theme(plot.margin=grid::unit(c(0,0.2,0,0.2), "cm"))

p

ggsave(plot = p, "./Plots/Threshold models/Paraguay_thresh.png", width = 10, height = 10)
```

#### Bolivia

```r
bol <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/BOL_adm/BOL_adm1.shp")
mosaico <- raster("./Final_model_rasters/Thresh_mosaic_MSS.tif")

bol_masked <- crop(mosaico, bol) %>% mask(bol)
writeRaster(bol_masked,"./Final_model_rasters/Bolivia_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

bol_masked <- raster("./Final_model_rasters/Bolivia_thresh.tif")
full_pts <- rasterToPoints(bol_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(Bolivia_thresh == 0 ~ "Absence", 
                           Bolivia_thresh == 1 ~ "Presence")) 

sa_ctroids1 <- cbind(bol, st_coordinates(st_centroid(bol)))
sa_ctroids2 <- sa_ctroids1 %>% 
  mutate(NAME_1 = case_when(NAME_1 == "Chuquisaca" ~ "H",
  NAME_1 == "Cochabamba" ~ "C",
  NAME_1 == "El Beni" ~ "B",
  NAME_1 == "La Paz" ~ "L",
  NAME_1 == "Oruro" ~ "O",
  NAME_1 == "Pando" ~ "N",
  NAME_1 == "Potosí" ~ "P",
  NAME_1 == "Santa Cruz" ~ "S",
  NAME_1 == "Tarija" ~ "T"))

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = bol, alpha = 0, color = "black", size = 0.5) +
geom_text(data = sa_ctroids2, aes(X, Y, label = NAME_1), size = 6, family = "sans", fontface = "plain") +
coord_sf() +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.77, 0.86)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 16, face = "bold"),
legend.text = element_text(size = 14)) +
ggsn::scalebar(data = bol, location = "bottomright", anchor = c(x = -58, y = -22.5),
dist = 100,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") +
theme(plot.margin = margin(0,0.5,0,0.5, "cm"))

p

ggsave(plot = p, "./Plots/Threshold models/Bolivia_thresh.png", width = 10, height = 12)
```

#### Chile

```r
chi <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/CHL_adm/CHL_adm1.shp")
mosaico <- raster("./Final_model_rasters/Thresh_mosaic_MSS.tif")

# Crop and mask 

chi_masked <- crop(mosaico, chi) %>% mask(chi)

writeRaster(chi_masked,"./Final_model_rasters/Chile_thresh.tif", overwrite=TRUE)

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

chi_masked <- raster("./Final_model_rasters/Chile_thresh.tif")
full_pts <- rasterToPoints(chi_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
full_bin = full_df %>% 
  mutate(Group = case_when(Chile_thresh == 0 ~ "Absence", 
                           Chile_thresh == 1 ~ "Presence")) 

p <- ggplot() +
geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
geom_sf(data = chi, alpha = 0, color = "black", size = 0.5) +
coord_sf(xlim = c(-80,-55), ylim = c(-18,-55), expand = TRUE) +
scale_fill_manual(values=c("#ffff66","#ff0066")) +
labs(x = "Longitude", y = "Latitude", fill = "Potential distribution") +
theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
axis.text.x = element_text(colour = "black", size = 18),
axis.text.y = element_text(colour = "black", size = 18)) +
theme(legend.position = c(0.75, 0.25)) +
theme(legend.key.size = unit(2, 'line'), 
legend.key.height = unit(2, 'line'), 
legend.key.width = unit(1.5, 'line'), 
legend.title = element_text(size = 14, face = "bold"), 
legend.text = element_text(size = 12)) + # change legend text font size
annotate(geom="text", x=-72, y=-18, label="AP", size = 5, color="black") +       
annotate(geom="text", x=-72, y=-20, label="TA", size = 5, color="black") +
annotate(geom="text", x=-72, y=-23, label="AN", size = 5, color="black") +
annotate(geom="text", x=-72.5, y=-27, label="AT", size = 5, color="black") +
annotate(geom="text", x=-73, y=-31, label="CO", size = 5, color="black") +
annotate(geom="text", x=-73, y=-32.5, label="VS", size = 5, color="black") +
annotate(geom="text", x=-68.5, y=-34, label="RM", size = 5, color="black") +
annotate(geom="text", x=-73, y=-34.4, label="LI", size = 5, color="black") +
annotate(geom="text", x=-69, y=-35.5, label="ML", size = 5, color="black") +
annotate(geom="text", x=-70, y=-37.2, label="BI", size = 5, color="black") +
annotate(geom="text", x=-70, y=-39, label="AR", size = 5, color="black") +
annotate(geom="text", x=-70.2, y=-40.1, label="LR", size = 5, color="black") +
annotate(geom="text", x=-70.3, y=-42.1, label="LL", size = 5, color="black") +
annotate(geom="text", x=-70.3, y=-46, label="AI", size = 5, color="black") +
annotate(geom="text", x=-70.3, y=-51, label="MA", size = 5, color="black") +
ggsn::scalebar(data = chi, location = "bottomright", anchor = c(x = -55, y = -55),
dist = 250,  st.size = 4, height = 0.01, dist_unit = "km", transform = TRUE,  model = "WGS84") 

p

ggsave(plot = p, "./Plots/Threshold models/Chile_thresh.png", width = 6.5, height = 10)
```
