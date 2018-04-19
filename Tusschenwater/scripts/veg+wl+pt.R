
setwd("D:/vegetation_emission")

require(rgdal)
require(rgeos)
require(raster)

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
vege_raster <- rasterize(vege,peatthick,field="id", fun="last")
wl <- vege_raster
for (i in 1:length(vege_raster)) {
  if (!is.na(vege_raster[i]) & !is.na(wl[i])) {
  if (vege_raster[i] == 1) {wl[i] <- 120}
  if (vege_raster[i] == 2) {wl[i] <- 70}
  if (vege_raster[i] == 3) {wl[i] <- 35}
  }
}


#calculate emissions
emission <- peatthick_pair
for (i in 1:length(peatthick_pair)) {
  if (!is.na(peatthick[i]) & !is.na(wl[i])) {
    emission[i] <- vegetation_proxy(wl[i], peatthick[i])}
}




