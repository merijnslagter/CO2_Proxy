setwd("D:/vegetation_emission")

require(rgdal)
require(rgeos)
require(raster)

## Load files

twater <- readOGR("source/Tusschenwater/boundaries","Tusschenwater_boundaries")
vegmap <- readOGR("source/Tusschenwater/veg_map_gwp","veg_map_tusschenwater")
peatthick <- raster("source/Tusschenwater/Tusschenwater_veendikte/Tusschenwater_veendikte.tif")

## crop and mask peat thickness for area

peatthick_crop <- crop(peatthick, twater, snap = 'out')
peatthick_mask <- mask(peatthick_crop, twater, snap = 'out')
peatthick <- peatthick_mask

## rasterize vegmap

vege_emission <- rasterize(vegmap,peatthick_mask, field = "CO2")

## Remove peat shallower than 30 cm
for(i in 1:length(peatthick)) {
  if (!is.na(peatthick[i])) {
    if (peatthick[i] < 30) {
      peatthick[i] <- NA
      vege_emission[i] <- NA}
  }
}
writeRaster(vege_emission,"inter/emission_twater_veg_co2.tif", datatype='FLT4S', overwrite=TRUE)

#calculate stats
co2mean <- cellStats(vege_emission, stat='mean', na.rm=TRUE)
statshape <- rasterToPolygons(peatthick, dissolve = T)
statshape_area <- gArea(statshape) / 10000
co2sum <- co2mean * statshape_area
