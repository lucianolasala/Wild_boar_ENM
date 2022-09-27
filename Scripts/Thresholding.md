### Model thresholding
----------
As threshold value we used the one that maximized sensitivity plus specificity. 


```r
paths <- str_c("./Final_models_proj/", selected$Model, "_E/maxentResults.csv")

get.thresholds <- function(x){
  th <- read_csv(x) %>%
    pull("Maximum training sensitivity plus specificity Cloglog threshold")
  th <- th[1:10]
  return(th)
}

th <- map(paths, get.thresholds) %>%
  unlist() %>%
  mean()

mean1.th <- read_stars("./Final_model_rasters/cal_area_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                       z < th ~ 0)) %>%
  write_stars("./Final_model_rasters/cal_area_mean_thresh_MSS.tif")

mean2.th <- read_stars("./Final_model_rasters/proj_area_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                        z < th ~ 0)) %>%
  write_stars("./Final_model_rasters/proj_area_mean_thresh_MSS.tif")

# Mosaicing and saving as ASCII and GTiff

cal <- raster("./Final_model_rasters/cal_area_mean_thresh_MSS.tif") 
proj <- raster("./Final_model_rasters/proj_area_mean_thresh_MSS.tif")

m <- mosaic(cal, proj, fun = "max")  # Change mean to max!!!
plot(m)

writeRaster(m, filename = "./Final_model_rasters/Thresh_mosaic_MSS", format = "ascii", overwrite = TRUE)
writeRaster(m, filename = "./Final_model_rasters/Thresh_mosaic_MSS", format = "GTiff", overwrite = TRUE)

```
