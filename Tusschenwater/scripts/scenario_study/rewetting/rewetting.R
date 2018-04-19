setwd("/home/merijn/Documents/Nijmegen_Stu_As/git/CO2_Proxy/Tusschenwater/scripts/scenario_study/rewetting")

require(rgdal)
require(rgeos)
require(raster)

source("functie_co2_emissies_vernatting.R")
source("functie_co2_emissies.R")
source("functie_co2_som_per_interval.R")
source("functie_veendikte.R")

setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

peatthick <- raster("inter/peatthick_mask.tif")
glg <- raster("inter/gvgfuture_mask.tif")

## calculate co2 emissies per cell

co2endraster <- peatthick
co2endraster[!is.na(co2endraster)][] <- 1
co2sumraster <- co2endraster
co2sumraster <- co2sumraster *30 

for (i in 1:length(peatthick)) {
  if(!is.na(peatthick[i]) & !is.na(glg[i])){
  tabel <- co2_emissies_vernatting(glg[i],peatthick[i])
  co2end <- tabel[1,2]
  co2endraster[i] <- co2end
  co2sum <- tabel[2,2]
  co2sumraster[i] <- co2sum
  }}


## Bereken gemiddelden

co2som <- cellStats(co2sumraster, stat='mean', na.rm=TRUE)
co2eind <- cellStats(co2endraster, stat='mean', na.rm=TRUE)
