setwd("/home/merijn/Documents/Nijmegen_Stu_As/git/CO2_Proxy/Tusschenwater/scripts/scenario_study/business_as_usual")

require(rgdal)
require(rgeos)
require(raster)

source("functie_co2_emissies_peilfixatie.R")
source("functie_co2_emissies.R")
source("functie_co2_som_per_interval.R")
source("functie_veendikte.R")

setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

## Laad bestanden

peatthick <- raster("inter/peatthick_mask.tif")
landuse <- readOGR("source/landuse_with_factors","landuse_with_factors")

## Rasterize landuse

co2 <- rasterize(landuse, peatthick, field = "CO2")

## Exclude peat shallower than 30 cm

for(i in 1:length(peatthick)) {
  if (!is.na(peatthick[i])) {
    if (peatthick[i] < 30) {peatthick[i] <- NA}
  }
}

## calculate co2 emissies per cell

co2sumraster <- peatthick
co2sumraster[!is.na(co2sumraster)][] <- 1
co2sumraster <- co2sumraster * co2 * 30

## Calculate average

co2sum <- cellStats(co2sumraster, stat='mean', na.rm=TRUE)

co2sumshape <- rasterToPolygons(co2sumraster, dissolve = T)

co2sumshapearea <- gArea(co2sumshape) / 10000

co2totalbau <- co2sum * co2sumshapearea