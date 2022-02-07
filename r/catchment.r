library(raster)
library(watershed)

neretva = stack("output/neretva.grd")
Tp = pixel_topology(neretva)

pts = as.data.frame(rasterToPoints(neretva$stream))
pts$ca = NA
nr = nrow(pts)
reaches = unique(pts$stream)
for(r in reaches) {
	i = which(pts$stream == r)
	pts$ca[i] = catchment(neretva, type="points", y = as.matrix(pts[i, 1:2]), area = TRUE, Tp = Tp)
	dn = sum(!is.na(pts$ca))
	cat(paste0(Sys.time(), "  ", dn, "/", nr, " (", round(100 * dn/nr, 0), "%)", "\r"))
}
ca = rasterFromXYZ(pts[, c('x', 'y', 'ca')])
writeRaster(ca, "output/catchment.tif", overwrite = TRUE, gdal=c("COMPRESS=DEFLATE"))
