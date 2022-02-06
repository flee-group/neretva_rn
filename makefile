network: output/neretva.grd
vector: output/neretva.gpkg
map: ouput/neretva.jpg
ca: output/catchment.tif
all: network vector map ca

## TODO
# pixel-based data frame format
# coarse-scale vector map for the overview

output/neretva.grd: r/delineate.r data/dem.tif
	Rscript r/delineate.r

output/neretva.gpkg: r/stream_vector.r output/neretva.grd
	Rscript r/stream_vector.r

ouput/neretva.jpg: r/map.r output/neretva.gpkg data/dem.tif
	Rscript r/map.r

output/catchment.tif: r/catchment.r output/neretva.grd
	Rscript r/catchment.r
