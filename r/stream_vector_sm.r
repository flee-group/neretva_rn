library(sf)
library(watershed)
library(raster)
options(mc.cores = 4)
dem = raster("data/dem_lg.tif")
stream = delineate(dem, threshold = 8e7, reach_len = 7000)
Tp = pixel_topology(stream)
neretva = vectorise_stream(stream$stream, Tp)
st_write(neretva, "output/neretva_sm.gpkg", append = FALSE)

