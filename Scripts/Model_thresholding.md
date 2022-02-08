#### Model Thresholding
>The folloging script creates a binary model (suitable/unsuitable) based on the
maximum training sensitivity plus specificity derived in the cloglog threshold

``` r
paths <- str_c("./Final_models/", selected$Model, "_E/maxentResults.csv")

get.thresholds <- function(x){
  th <- read_csv(x) %>%
    pull("Maximum training sensitivity plus specificity Cloglog threshold")
  th <- th[1:10]
  return(th)
}

th <- map(paths, get.thresholds) %>%
  unlist() %>%
  mean()

mean1.th <- read_stars("./Final_models/cal_area_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                       z < th ~ 0)) %>%
  write_stars("./Final_models/cal_area_mean_thresholded.tif")

mean2.th <- read_stars("./Final_models/proj_area_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                        z < th ~ 0)) %>%
  write_stars("./Final_models/proj_area_mean_thresholded.tif")