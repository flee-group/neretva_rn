library(raster)
library(sf)
options(gisBase = "/opt/local/lib/grass80", mc.cores = 4)
library(watershed)
outlet = c(4960487, 2318512)
dem = raster("data/dem.tif")
stream = delineate(dem, threshold = 3e6, outlet = outlet, reach_len = 500)
Tp = pixel_topology(stream)

writeRaster(stream, file="output/neretva.grd", overwrite = TRUE, gdal=c("COMPRESS=DEFLATE"))
