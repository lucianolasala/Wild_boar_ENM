library(tidyverse)
library(raster)
library(gstat)
library(sf)
library(cowplot)
library(stars)
library(viridis)


pca <- stack("./data/pca/PCA_calibration_area.tif")

# Centroid of sample areas

xs <- c(-69.24903, -67.74524, -61.02240, -66.32991,
        -58.72248, -51.11506, -50.40739, -71.01820)
ys <- c(-42.567181, -36.142495, -36.455894, -28.777612,
        -28.699262, -25.251870, -16.790089, -9.111806)

xs1 <- colFromX(pca, xs)
xs2 <- xs1 + 100
xs1 <- xFromCol(pca, xs1)
xs2 <- xFromCol(pca, xs2)

ys1 <- rowFromY(pca, ys)
ys2 <- ys1 + 100
ys1 <- yFromRow(pca, ys1)
ys2 <- yFromRow(pca, ys2)

for (j in 1:6) {

  pl <- list()

  for (i in 1:8) {

    cr <- crop(pca[[j]], extent(xs1[i], xs2[i],
                                 ys2[i], ys1[i]))
    cr <- raster(as.matrix(cr), xmn = 0, xmx = 100,
                 ymn = 0, ymx = 100)

    set.seed(100)
    sm <- sample(1:ncell(cr), 5000)
    xy <- as_tibble(xyFromCell(cr, sm))
    xy$val <- cr[sm]
    xy <- xy %>%
      drop_na() %>%
      st_as_sf(coords = c("x", "y"), remove = FALSE)

    vg <- variogram(val ~ x + y, data = xy, cutoff = 100)
    vgf <- fit.variogram(vg, vgm(1, "Sph", 20, 1))
    pred <- variogramLine(vgf, maxdist = 100)


    pl1 <- ggplot() +
      geom_stars(data = st_as_stars(cr)) +
      scale_fill_viridis() +
      theme_void() +
      ggtitle(str_c("PCA", j, " Zone ", i))

    pl2 <- ggplot() +
      geom_point(data = vg, aes(x = dist, y = gamma)) +
      geom_line(data = pred, aes(x = dist, y = gamma)) +
      ylim(0, max(vg$gamma)) +
      geom_vline(xintercept = vgf$range[2], color = "red", linetype = "dashed") +
      ggtitle(str_c("PCA", j, " Zone ", i))

   pl[[i]] <- plot_grid(pl1, pl2)


  }

  pls <- plot_grid(pl[[1]], pl[[2]], pl[[3]], pl[[4]],
                  pl[[5]], pl[[6]], pl[[7]], pl[[8]],
                  ncol = 2)
  ggsave(pls, filename = str_c("./plots/pca", j, "_variogram.jpg"), height = 11)

}


## Remove extreme values and reduce resolution

library(tidyverse)
library(stars)


pca <- read_stars("./data/pca/PCA_calibration_area.tif",
                  proxy = FALSE) %>% set_names("z")

for (i in 1:6) {
  qs <- quantile(pca$z[, , i], probs = c(0.001, 0.999), na.rm = TRUE)
  k1 <- which(pca$z[, , i] < qs[1])
  k2 <- which(pca$z[, , i] > qs[2])

  pca$z[, , i][k1] <- NA
  pca$z[, , i][k2] <- NA
}

dims <- st_dimensions(pca)

ng <- st_as_stars(st_bbox(pca),
                  dx = abs(dims$x$delta) * 10,
                  dy = abs(dims$x$delta) * 10)

pca <- st_warp(src = pca,
               dest = ng,
               use_gdal = TRUE,
               method = "average",
               no_data_value = -9999) %>%
  st_set_dimensions(which = "band", values = str_c("PC", 1:6)) %>%
  write_stars("./data/pca/PCA_calibration_area_reduced.tif", chunk_size = c(2000, 2000))


pca <- read_stars("./data/pca/PCA_projection_area.tif", proxy = FALSE) %>%
  set_names("z")

for (i in 1:6) {
  qs <- quantile(pca$z[, , i], probs = c(0.001, 0.999), na.rm = TRUE)
  k1 <- which(pca$z[, , i] < qs[1])
  k2 <- which(pca$z[, , i] > qs[2])

  pca$z[, , i][k1] <- NA
  pca$z[, , i][k2] <- NA

}

dims <- st_dimensions(pca)

ng <- st_as_stars(st_bbox(pca),
                  dx = abs(dims$x$delta) * 10,
                  dy = abs(dims$x$delta) * 10)

pca <- st_warp(src = pca,
               dest = ng,
               use_gdal = TRUE,
               method = "average",
               no_data_value = -9999) %>%
  st_set_dimensions(which = "band", values = str_c("PC", 1:6)) %>%
  write_stars("./data/pca/PCA_projection_area_reduced.tif", chunk_size = c(2000, 2000))

r1 <- read_stars("./data/pca/PCA_calibration_area_reduced.tif") %>%
  set_names("z")

ggplot() +
  geom_stars(data = r1) +
  facet_wrap(vars(band)) +
  coord_sf() +
  theme_void() +
  scale_fill_viridis(, name = "", na.value = "transparent")

ggsave("~/Desktop/calibration.pdf")

r2 <- read_stars("./data/pca/PCA_projection_area_reduced.tif") %>%
  set_names("z")

ggplot() +
  geom_stars(data = r2) +
  facet_wrap(vars(band)) +
  coord_sf() +
  theme_void() +
  scale_fill_viridis(, name = "", na.value = "transparent")

ggsave("~/Desktop/projection.pdf")


