rm(list=ls(all=TRUE))

library(raster)
library(sp)

wb_final <- raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model.asc") 
wb_occs <- read.csv("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Boars_SWD_joint_threshold.csv")

# Extract the SDM predictions at all occurrence points

occPredVals <- raster::extract(wb_final, wb_occs[,2:3])
head(occPredVals)

sdm_threshold <- function(sdm, occs, type = "mtp", binary = FALSE){
    occPredVals <- raster::extract(sdm, occs)
    if(type == "mtp"){
        thresh <- min(na.omit(occPredVals))
    } else if(type == "p20"){
        if(length(occPredVals) < 10){
            p20 <- floor(length(occPredVals) * 0.8)
        } else {
            p20 <- ceiling(length(occPredVals) * 0.8)
        }
        thresh <- rev(sort(occPredVals))[p20]
    }
    sdm_thresh <- sdm
    sdm_thresh[sdm_thresh < thresh] <- NA
    if(binary){
        sdm_thresh[sdm_thresh >= thresh] <- 1
    }
    return(sdm_thresh)
}

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



#-----------------------------------------------------------------------

wb_sdm_cal <- raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_models/M_0.1_F_l_Set_1_E/Boar_Scenario_cal_avg.asc")
class(wb_sdm_cal)

wb_sdm_proj <- raster("C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_models/M_0.1_F_l_Set_1_E/Boar_Scenario_proj_avg.asc")
class(wb_sdm_proj)

x <- list(wb_sdm_cal, wb_sdm_proj)

names(x) <- c("x", "y")
x$filename <- "test.tif"
x$overwrite <- TRUE
m <- do.call(merge, x)

plot(m)
class(m)

writeRaster(m, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model", format = "ascii", overwrite = TRUE)

#----------------------------------------------------------------------------

plot(wb_final)
points(wb_occs[,2:3], pch = 19, cex = 0.5)

#----------------------------------------------------------------------------

# Apply MTP and P10 thresholds to the SDM based on the location of the occurrence points:
    
wb_mtp <- sdm_threshold(wb_final, wb_occs[,2:3], "mtp", binary = TRUE)
plot(wb_mtp)

writeRaster(wb_mtp, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model_mtp", format = "ascii", overwrite = TRUE)

# Apply P10 thresholds to the SDM based on the location of the occurrence points:

wb_p10 <- sdm_threshold(wb_final, wb_occs[,2:3], "p10", binary = TRUE)
plot(wb_p10)
writeRaster(wb_p10, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model_p10", format = "ascii", overwrite = TRUE)

wb_p20 <- sdm_threshold(wb_final, wb_occs[,2:3], "p20", binary = TRUE)
plot(wb_p20)
writeRaster(wb_p20, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model_p20", format = "ascii", overwrite = TRUE)

M <- readOGR("C:/Users/User/Documents/Analyses/Wild boar ENM/Shapefiles","Study region")

wb_p10_new <- mask(wb_p10, M)
plot(wb_p10_new)

wb_p10_new[!is.na(wb_p10_new[])] <- 1  # 1s reemplazan el valor inicial de cada pixel con valor
plot(wb_p10_new)

writeRaster(wb_p10_new, filename = "C:/Users/User/Documents/Analyses/Wild boar ENM/Modeling Julian_final/Final_model_p10_new", format = "ascii", overwrite = TRUE)

#------------------------------------------------------------------------------------------
# Apply user defined thresholds to the SDM based on the location of the occurrence points:
#------------------------------------------------------------------------------------------

# Nota: no funciona

wb_p20 <- raster_threshold(input_raster = wb_final, threshold = 10, binary = TRUE)
plot(wb_p20)
