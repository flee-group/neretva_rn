library(terra)
library(sf)
dem = rast("data/dem.tif")
riv = st_read("output/neretva.gpkg")
neretva = rast("output/neretva.grd")
dem = crop(dem, neretva)

# pts = data.frame(name = c("dam", "ds_sample", "source"), 
# 	x = c(17.762885, 17.962372, 18.552181), y = c(43.655467, 43.651676, 43.283714))
# pts = st_transform(st_as_sf(pts, coords = c('x', 'y'), crs = 4326), crs = 3035)
# pts = rbind(pts, st_as_sf(data.frame(name = "outlet", x = 4945013, y = 2308310), 
# 	coords = c('x', 'y'), crs = 3035))
sl = terrain(dem, unit = "radians")
as = terrain(dem, "aspect", unit = "radians")
hs = shade(sl, as)

ptcol = "#ffcc66"
rivcol = "#0099ff"

jpeg(width=2000, height = 2000, file = "output/neretva.jpg")
## catch a weird R-internal error that pops up sometimes
tryCatch(
	plot(hs, col=grey(0:100/100), alpha = 1, legend = FALSE, axes = FALSE),
	error = function(e) print(e))
plot(dem, add = TRUE, alpha = 0.6, col = terrain.colors(100),
	axes = FALSE, legend=FALSE)
plot(neretva$catchment, add = TRUE, alpha = 0.5, col = "#c3e4e3", axes = FALSE, legend = FALSE)
plot(st_geometry(riv), col=rivcol, lwd=riv$order, add = TRUE)
# plot(st_geometry(pts), col=ptcol, pch=16, add = TRUE, cex=2)
# text(st_coordinates(pts)[,1], st_coordinates(pts)[,2], pts$name, pos=4, col = ptcol, cex=1.5)
dev.off()


