library(sf)
library(watershed)
library(raster)
options(mc.cores = 4)

stream = stack("output/neretva.grd")
Tp = pixel_topology(stream)
vv = vectorise_stream(stream$stream, Tp)
st_write(vv, "output/neretva.gpkg", append = FALSE)
