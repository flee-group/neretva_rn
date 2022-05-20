library(raster)
library(watershed)
library(Matrix)
library(sf)
library(WatershedTools)

ca = raster("output/catchment.tif")
neretva = stack("output/neretva.grd")
ner_ws = readRDS("output/neretva_ws.rds")
neretva = crop(neretva, ca)
neretva = addLayer(neretva, ca)
Tp = pixel_topology(neretva)
Tp = as(Tp, "dgTMatrix")
Tp_df = data.frame(us = Tp@i+ 1, ds = Tp@j + 1, length_m = Tp@x)

ner_pts = rasterToPoints(neretva)
ner_pts = as.data.frame(ner_pts)
ner_pts = ner_pts[complete.cases(ner_pts),]
ner_pts = merge(ner_pts, Tp_df, by.x = "id", by.y = "us", all.x = TRUE)

i = which(is.na(ner_pts$ds))
# distance across a pixel in a cardinal direction
straight = min(ner_pts$length_m, na.rm=TRUE)
# distance across a pixel diagonally
diagon = max(ner_pts$length_m, na.rm=TRUE)

out_direction = ner_pts[i,"drainage"]
# even number drainages are straight, odd diagonal
# divide by two because only half a pixel for the outlet
ner_pts$length_m[i] = ifelse(out_direction %% 2, diagon, straight)/2

# drop and rename columns
cols = c("id", 'stream', 'x', 'y', 'accum', 'drainage', 'catchment.2', 'length_m', 'ds')
ner_pts = ner_pts[, cols]
colnames(ner_pts)[c(2, 7, 9)] = c("reach_id", "catch_area_km2", "downstream_id")
ner_pts$catch_area_km2 = ner_pts$catch_area_km2 / (1000^2)

# merge with reaches
vv = st_read("output/neretva.gpkg")
vvtab = vv[,1:21]
st_geometry(vvtab) = NULL

ner_pts = merge(ner_pts, vvtab, by = "reach_id", all.x = TRUE)

wsdat = as.data.frame(ner_ws$data)[, c("pixel_id", "elevation", "dist")]
colnames(wsdat) = c("id", "elevation_m", "outlet_distance_km")

ner_pts = merge(ner_pts, wsdat, by = "id")

saveRDS(ner_pts, "output/neretva_pixels.rds")




