library(WatershedTools)
library(raster)
library(sf)

dem = raster("data/dem.tif")
stream = stack("output/neretva.grd")
catch_area = raster("output/catchment.tif")
vv = st_read("output/neretva.gpkg")
dem = crop(dem, catch_area)
stream = crop(stream, catch_area)
ol = stream$id
ol = stack(ol)
names(ol) = "pixel_id"

ner_ws = Watershed(stream$stream, stream$drainage, dem, stream$accum, catch_area, 
	otherLayers = ol)

# distance to outlet for all pixels
out_dist = wsDistance(ner_ws, outlets(ner_ws)$id) / -1000
ner_ws$data$dist = out_dist

 
# st_order = rep(as.integer(NA), max(ner_ws$data$reachID))
# Tr = Matrix::t(ner_ws$reach_adjacency)
# hws = unique(headwaters(ner_ws)$reachID)
# st_order[hws] = 1
# stuck = FALSE
# while(!stuck & any(is.na(st_order))) {
# 	reaches = which(is.na(st_order))
# 	st_new = sapply(reaches, \(i) {
# 		ord = st_order[watershed:::.upstream(Tr, i)]
# 		if(any(is.na(ord))) {
# 			NA
# 		} else if(length(ord) == 1) {
# 			ord
# 		} else if(all(ord == max(ord))) {
# 			max(ord) + 1
# 		} else {
# 			max(ord)
# 		}
# 	})
# 	if(all(is.na(st_new)))
# 		stuck = TRUE
# 	st_order[reaches] = st_new
# }

st_order = watershed::strahler(Matrix::t(ner_ws$reach_adjacency))
vv = cbind(order = st_order, vv)

# png("~/Desktop/neretva.png", width = 1000, height = 1000)
# plot(st_geometry(vv), lwd = vv$order*0.5, col = 'blue')
# dev.off()
# ggplot() + geom_sf(data = vv, size = 0.3*vv$order, color = "blue", lineend = "square") + theme_minimal()
# 
st_write(vv, "output/neretva.gpkg", append = FALSE)
saveRDS(ner_ws, "output/neretva_ws.rds")
