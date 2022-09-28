### Model thresholding
----------
 
#### Atlantic Forest histogram

```r
af <- st_read("D:/Trabajo/Analisis/MNE_jabali/Vectors/Hotspots/Atlantic_Forest.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

mosaic <- raster("D:/Trabajo/Analisis/MNE_jabali/Modelling/Final_model_rasters/Mosaic_all.tif")

mosaic_masked <- crop(mosaic, af) %>% mask(af)
plot(mosaic_masked)
full_pts <- rasterToPoints(mosaic_masked, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
af <- na.omit(full_df$Mosaic_all)
af_df <- as.data.frame(af)
newdata <- af_df[order(af_df$af),]

mean(newdata)
sd(newdata)
mean(newdata)-sd(newdata)
mean(newdata)+sd(newdata)

atl_forest <- ggplot(af_df, aes(x = af)) + 
geom_histogram(color="#1A5276", size = 0.1, fill="white", binwidth = 0.05) +
geom_vline(xintercept = 0.70602, color = "blue", linetype = "longdash", size = 0.4) +
geom_vline(xintercept = c(0.5638553,0.8481885), col = "red", size = 0.4) +
labs(x = "Suitability", y = "Frequency") + 
theme(axis.title.y = element_text(margin = margin(t = 0, r = 8, b = 0, l = 0), size = 6), 
axis.title.x = element_text(margin = margin(t = 8, r = 0, b = 0, l = 0), size = 6),  
axis.text.x = element_text(colour = "black", size = 4),
axis.text.y = element_text(colour = "black", size = 4)) +
theme(axis.ticks = element_line(size = 0.2)) +
annotate(geom = "text", x=0.1, y=2000, label="A", size = 3, color="black") +
theme(plot.margin = unit(c(0.2,0.2,0.4,0.4), "cm"))

atl_forest

ggsave(filename = "D:/Trabajo/Analisis/MNE_jabali/Modelling/Plots/Graphics/Atlantic_Forest_histo.jpg", plot = atl_forest, device = "jpeg", path = NULL, scale = 1, dpi = 300, limitsize = TRUE)
```
