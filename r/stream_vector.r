library(sf)
library(watershed)
library(raster)
library(data.table)

dem = raster("data/dem.tif")
stream = stack("output/neretva.grd")
corine = st_read("data/neretva_lc.gpkg")
geo = st_read("data/neretva_geology.gpkg")
geo = st_transform(geo, st_crs(corine))

Tp = pixel_topology(stream)
neretva_rn = vectorise_stream(stream, Tp)
neretva_rn$slope = river_slope(neretva_rn, dem)



neretva_lc = w_intersect(neretva_rn, areas = corine, 
            area_id = "code_18", drainage = stream$drainage)

neretva_geo = w_intersect(neretva_rn, areas = geo, 
            area_id = "xx", drainage = stream$drainage)

neretva_lc = neretva_lc[method == "catchment"]
neretva_geo = neretva_geo[method == "catchment"]
neretva_lc[, layer := "lc"]
neretva_geo[, layer := "geo"]
neretva_stats = rbind(neretva_lc, neretva_geo)
neretva_stats$method = NULL
neretva_stats$area = NULL
neretva_stats = neretva_stats[, .(reach_id = reachID, category = paste(layer, category, sep = "_"), proportion = proportion)]


neretva_stats_w = dcast(neretva_stats, reach_id ~ category, fill = 0, value.var = "proportion")
c_area_reach = catchment(stream, type = 'reach', Tp = Tp)

neretva_rn = merge(neretva_rn, neretva_stats_w, by = 'reach_id')
neretva_rn$catchment_area = c_area_reach

st_write(neretva_rn, "output/neretva.gpkg", append = FALSE)
