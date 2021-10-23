#-----------------------------------------------------------------------
# Model thresholds are created using user-built functions 
#-----------------------------------------------------------------------

rm(list=ls(all=TRUE))

library(raster)
library(rgdal)
library(sp)

cal_mean <- raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_models/cal_area_mean.tif")

proj_mean <- raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_models/proj_area_mean.tif")

x <- list(cal_mean, proj_mean)

names(x) <- c("x", "y")
x$filename <- "test.tif"
x$overwrite <- TRUE
m <- do.call(merge, x)
plot(m)

m_mask <- mask(m, M)
plot(m_mask)

writeRaster(m_mask, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling LFLS/Output maps/Final_model_mean", format = "ascii", overwrite = TRUE)

#----------------------------------------------------------------------------
# Load study region 
#----------------------------------------------------------------------------

M <- readOGR("C:/Users/User/Documents/Analyses/Wild boar ENM/Shapefiles","Study region")

#----------------------------------------------------------------------------
# Load wild boar occurrences 
#----------------------------------------------------------------------------

occs <- read.csv("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Boars_SWD_joint.csv")
length(occs$sp)

#----------------------------------------------------------------------------
# Initial plot
#----------------------------------------------------------------------------

plot(m)
points(occs[,2:3], pch = 19, cex = 0.5)

#----------------------------------------------------------------------------
# Extract the SDM predictions at all occurrence points and threshold function 
#----------------------------------------------------------------------------

rm(list=ls(all=TRUE))

occPredVals <- raster::extract(m, occs[,2:3])
head(occPredVals)

# The function

sdm_threshold <- function(sdm, occs, type = "mtp", binary = FALSE){
    occPredVals <- raster::extract(sdm, occs)
    if(type == "mtp"){
        thresh <- min(na.omit(occPredVals))
    } else if(type == "p10"){
        if(length(occPredVals) < 10){
            p20 <- floor(length(occPredVals) * 0.9)
        } else {
            p10 <- ceiling(length(occPredVals) * 0.9)
        }
        thresh <- rev(sort(occPredVals))[p10]
    }
    sdm_thresh <- sdm
    sdm_thresh[sdm_thresh < thresh] <- NA
    if(binary){
        sdm_thresh[sdm_thresh >= thresh] <- 1
    }
    return(sdm_thresh)
}

#-----------------------------------------------------------------------
# Generalization to threshold any raster by a given value
#-----------------------------------------------------------------------

raster_threshold <- function(input_raster, points = NULL, type = NULL, threshold = NULL, binary = FALSE) {
    if (!is.null(points)) {
        pointVals <- raster::extract(wb_final, wb_occs[,2:3])
        if (type == "mtp") {
            threshold <- min(na.omit(pointVals))
        } else if (type == "p20") {
            if (length(pointVals) < 10) {
                p20 <- floor(length(pointVals) * 0.8)
            } else {
                p20 <- ceiling(length(pointVals) * 0.8)
            }
            threshold <- rev(sort(pointVals))[p20]
        }
    }
    raster_thresh <- input_raster
    raster_thresh[raster_thresh < threshold] <- NA
    if (binary) {
        raster_thresh[raster_thresh >= threshold] <- 1
    }
    return(raster_thresh)
}


#-----------------------------------------------------------------------------------------------
# Apply MTP threshold
#-----------------------------------------------------------------------------------------------

# Load raster

mtp_continuous <- sdm_threshold(wb_raster, occs[,2:3], "mtp")
plot(mtp_continuous)
writeRaster(mtp_continuous, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling LFLS/Output maps/mtp_continuous", format = "ascii", overwrite = TRUE)

mtp_bin <- sdm_threshold(wb_raster, occs[,2:3], "mtp", binary = TRUE)
plot(mtp_bin)
mtp_bin_mask <- mask(mtp_bin, M)

writeRaster(mtp_bin_mask, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling LFLS/Output maps/mtp_binary", format = "ascii", overwrite = TRUE)


#-----------------------------------------------------------------------------------------------
# Apply 10th percentile training present (p10) 
#-----------------------------------------------------------------------------------------------

p10_continuous <- sdm_threshold(wb_raster, occs[,2:3], "p10")
plot(p10_continuous)
p10_continuous_mask <- mask(p10_continuous, M)

writeRaster(p10_continuous_mask, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling LFLS/Output maps/p10_continuous", format = "ascii", overwrite = TRUE)


p10_bin <- sdm_threshold(wb_raster, occs[,2:3], "p10", binary = TRUE)
plot(p10_bin)
p10_bin_mask <- mask(p10_bin, M)
writeRaster(p10_bin_mask, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling LFLS/Output maps/p10_bin", format = "ascii", overwrite = TRUE)



wb_p10_new[!is.na(wb_p10_new[])] <- 1  # 1s reemplazan el valor inicial de cada pixel con valor
plot(wb_p10_new)

writeRaster(wb_p10_new, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model_p10_new", format = "ascii", overwrite = TRUE)


#------------------------------------------------------------------------------------------
# Raster classification
# Source: https://www.earthdatascience.org/courses/earth-analytics/lidar-raster-data-r/classify-raster/
#------------------------------------------------------------------------------------------

wb_raster <- raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling LFLS/Output maps/Final_model_mean.asc")

summary = summary(wb_raster)

# Plot histogram of data

hist(wb_raster,
     main = "Distribution of raster cell values",
     xlab = "Suitability", ylab = "Number of Pixels",
     col = "springgreen")


# See how R is breaking up the data

histinfo <- hist(wb_raster)
histinfo$breaks

# Create classification matrix

reclass_df <- c(0, 0.25, 1,
                0.25, 0.5, 2,
                0.5, 0.75, 3,
                0.75, Inf, 4)

# Reshape the object into a matrix with columns and rows

reclass_m <- matrix(reclass_df,
                    ncol = 3,
                    byrow = TRUE)
reclass_m

# Reclassify the raster using the reclass object - reclass_m

wb_raster_classified <- reclassify(wb_raster, reclass_m)
class(wb_raster_classified)

# View reclassified data

barplot(wb_raster_classified, main = "Number of pixels in each class")

# Plot reclassified raster

plot(wb_raster_classified, col = c("#979A9A","#F7DC6F","#45B39D","#DE3163"), legend = FALSE)

legend("topright",
       legend = c("Low","Medium", "High","Very high"),
       fill = c("#979A9A","#F7DC6F","#45B39D","#DE3163"),
       border = FALSE,
       title = "Suitability",
       bty = "n") # turn off legend border 



#------------------------------------------------------------------------------------------
# Apply user defined thresholds to the SDM based on the location of the occurrence points:
#------------------------------------------------------------------------------------------

# Nota: no funciona

wb_p20 <- raster_threshold(input_raster = wb_final, threshold = 10, binary = TRUE)
plot(wb_p20)
