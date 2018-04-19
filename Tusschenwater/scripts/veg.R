setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

require(rgdal)
require(rgeos)
require(raster)

## Load files

twater <- readOGR("source/Tusschenwater_boundaries","Tusschenwater_boundaries")
vegmap <- readOGR("source/veg_map_twater","veg_map_tusschenwater")
peatthick <- raster("source/veenraster.tif")

## calculate area of vegetation map

vegmap$area <- gArea(vegmap, byid = T)/10000

## crop and mask peat thickness for area

peatthick_crop <- crop(peatthick, twater, snap = 'out')
peatthick_mask <- mask(peatthick_crop, twater, snap = 'out')
peatthick <- peatthick_mask

## rasterize vegmap

vege_raster <- rasterize(vegmap["GWP"],peatthick_mask, field = "GWP")

## Remove peat shallower than 30 cm
for(i in 1:length(peatthick)) {
  if (!is.na(peatthick[i])) {
    if (peatthick[i] < 30) {vege_raster[i] <- NA}
  }
}

zonal.stats(twater, vege_raster, sat = 'mean')

vegmap$GWPtot <- as.character(vegmap$GWPpot) * vegmap$area

writeOGR(vegmap,dsn = "inter/shapes/veg", layer = "vegmapwithGWP", driver="ESRI Shapefile", overwrite_layer = TRUE)