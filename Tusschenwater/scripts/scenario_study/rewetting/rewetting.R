setwd("/home/merijn/Documents/Nijmegen_Stu_As/git/CO2_Proxy/Tusschenwater/scripts/scenario_study/rewetting")

require(rgdal)
require(rgeos)
require(raster)

source("functie_co2_emissies_vernatting.R")
source("functie_co2_emissies.R")
source("functie_co2_som_per_interval.R")
source("functie_veendikte.R")

setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

twater <- readOGR("source/Tusschenwater_boundaries","Tusschenwater_boundaries")
peatthick <- raster("source/veendikte.tif")
vegmap <- readOGR("source/veg_map_twater","veg_map_tusschenwater")

## crop and mask peat thickness for area

peatthick_crop <- crop(peatthick, twater, snap = 'out')
peatthick_mask <- mask(peatthick_crop, twater, snap = 'out')
peatthick <- peatthick_mask

co2 <- rasterize(vegmap,peatthick_mask, field = "CO2")

## Remove peat shallower than 30 cm
for(i in 1:length(peatthick)) {
  if (!is.na(peatthick[i])) {
    if (peatthick[i] < 30) {peatthick[i] <- NA}
  }
}

co2sumraster <- peatthick
co2sumraster[!is.na(co2sumraster)][] <- 1
co2sumraster <- co2sumraster * co2 * 30


writeRaster(co2sumraster,"final/co2_twater_rewetting_30years_phase_01.tif", datatype='FLT4S', overwrite=TRUE)

## Calculate average

co2sum <- cellStats(co2sumraster, stat='mean', na.rm=TRUE)

co2sumshape <- rasterToPolygons(co2sumraster, dissolve = T)

co2sumshapearea <- gArea(co2sumshape) / 10000

co2totalbau <- co2sum * co2sumshapearea