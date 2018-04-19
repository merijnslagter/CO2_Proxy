
setwd("D:/vegetation_emission")

require(rgdal)
require(rgeos)
require(raster)
require(spatialEco)

#define function
vegetation_proxy <- function (wl = 30, peatthick = 10) {
  ifelse(wl < peatthick, peat<- wl, peat <- peatthick)
  if (peat < 20) {peat <- 20}
  emission <- 0.5 * peat
  if (emission > 50) {emission <- 50}
  return(emission)
}

#load source data
twater <- readOGR("source/Tusschenwater/boundaries","Tusschenwater_boundaries")
vege <- readOGR("source/Tusschenwater/veg_map_twater","vege_map")
peatthick <- raster("source/Tusschenwater/Tusschenwater_veendikte/Tusschenwater_veendikte.tif")

#get water level out of vegetation
vege_raster <- rasterize(vege,peatthick)
wl <- vege_raster
for (i in 1:length(vege_raster)) {
  if (!is.na(vege_raster[i]) & !is.na(wl[i])) {
  if (vege_raster[i] == 1) {wl[i] <- 120}
  if (vege_raster[i] == 2) {wl[i] <- 70}
  if (vege_raster[i] == 3) {wl[i] <- 35}
  }
}

#exclude peat less than 30cm thick
for(i in 1:length(peatthick)) {
  if (!is.na(peatthick[i])) {
    if (peatthick[i] < 30) {peatthick[i] <- NA}
  }
}

#calculate emissions
emission <- peatthick
for (i in 1:length(peatthick)) {
  if (!is.na(peatthick[i]) & !is.na(wl[i])) {
    emission[i] <- vegetation_proxy(wl[i], peatthick[i])}
  else {emission[i] <- NA}
}
writeRaster(emission,"inter/emission_twater.tif", datatype='FLT4S', overwrite=TRUE)

#mean and sum emissions for each vegetation type
emission_vegmean <- zonal.stats(vege, emission, stat = mean)
vege_area <- gArea(vege,byid = TRUE) / 10000
vege_area <- as.numeric(vege_area)
emission_vegsum <- vege_area * emission_vegmean
