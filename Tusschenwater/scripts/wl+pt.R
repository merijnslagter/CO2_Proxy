
setwd("D:/vegetation_emission")

require(rgdal)
require(rgeos)
require(raster)
require(spatialEco)

#define function
vegetation_proxy <- function (wl = 30, peatthick = 10) {
  ifelse(wl < peatthick, peat<- wl, peat <- peatthick)
  emission <- 0.5 * peat
  if (emission < 1) {emission <- 1}
  if (emission > 50) {emission <- 50}
  return(emission)
}

#load source data
twater <- readOGR("source/Tusschenwater/boundaries","Tusschenwater_boundaries")
wl <- raster("source/Tusschenwater/gvgfuture_mask.tif")
peatthick <- raster("source/Tusschenwater/Tusschenwater_veendikte/Tusschenwater_veendikte.tif")

#exclude peat less than 30cm thick
for(i in 1:length(peatthick)) {
  if (!is.na(peatthick[i])) {
    if (peatthick[i] < 30) {peatthick[i] <- NA}
  }
}

#pair wl & peatthick
crs(wl) <- crs(peatthick)
wl <- resample(wl, peatthick)
for(i in 1:length(wl)) {wl[i] <- wl[i] * 100}

#calculate emissions
emission <- peatthick
for (i in 1:length(peatthick)) {
  if (!is.na(peatthick[i]) & !is.na(wl[i])) {
    emission[i] <- vegetation_proxy(wl[i], peatthick[i])}
  else {emission[i] <- NA}
}
writeRaster(emission,"inter/emission_twater_futurewl.tif", datatype='FLT4S', overwrite=TRUE)

#mean and sum emissions for each vegetation type
emission_vegmean <- zonal.stats(vege, emission, stat = mean)
vege_area <- gArea(vege,byid = TRUE) / 10000
vege_area <- as.numeric(vege_area)
emission_vegsum <- vege_area * emission_vegmean