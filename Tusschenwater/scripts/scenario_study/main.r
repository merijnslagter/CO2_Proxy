
## data preparation ##

setwd("D:/vegetation_emission")

require(rgdal)
require(rgeos)
require(raster)
require(spatialEco)

#load source data
twater <- readOGR("source/Tusschenwater/boundaries","Tusschenwater_boundaries")
wl0 <- raster("source/Tusschenwater/gvgfuture_mask.tif")
peatthick0 <- raster("source/Tusschenwater/Tusschenwater_veendikte/Tusschenwater_veendikte.tif")

#crop and mask peat thickness for area
peatthick_crop <- crop(peatthick0, twater, snap = 'out')
peatthick_mask <- mask(peatthick_crop, twater, snap = 'out')
peatthick0 <- peatthick_mask

#pair wl & peatthick, changing unit
crs(wl0) <- crs(peatthick0)
wl0 <- resample(wl0, peatthick0)
for(i in 1:length(wl0)) {wl0[i] <- wl0[i] * 100}

## define functions ##

#CO2 emission
co2_emission <- function (wl = 30, peatthick = 10, emission_factor = 0.5, emission_min = 1, emission_max = 50) {
  ifelse(wl < peatthick, peat<- wl, peat <- peatthick)
  emission <- emission_factor * peat
  if (emission < emission_min) {emission <- emission_min}
  if (emission > emission_max) {emission <- emission_max}
  return(emission)
}

#peat loss
peat_loss <- function(wl = 30, peatthick = 10, interval_length = 1, peat_loss_factor = 0.9974) {
  ifelse(wl < peatthick, peat<- wl, peat <- peatthick)
  peatthick <- peatthick - (1-peat_loss_factor^interval_length) * peat
  return(peatthick)
}

## iterative calculation of CO2 emission for a given period ##

#define staring parameters
interval_length <- 5   ### enter length of time interval (yrs)
interval_num <- 6   ### enter number of iteration
emission_mean <- c(1:interval_num)
emission_total <- c(1:interval_num)
peat_area <- c(1:interval_num)
peatthick <- peatthick0
wl <- wl0
i <- 0

#start iteration
while (i < interval_num){
  i <- i + 1
  
  #exclude peat less than 30cm
  for (p in 1:length(peatthick)) {
    if (!is.na(peatthick[p])) {
      if (peatthick[p] < 30) {peatthick[p] <- NA}
    }
  }
  
  #calculate emission rate
  emission <- peatthick
  for(e in 1:length(peatthick)) {
    if (!is.na(peatthick[e]) & !is.na(wl[e])) {
      emission[e] <- co2_emission(wl[e], peatthick[e], emission_factor = 0.5, emission_min = 1, emission_max = 50)}
    else {emission[e] <- NA}
  }
  
  #sum total emission
  emission_mean[i] <- cellStats(emission, stat='mean', na.rm=TRUE)
  statshape <- rasterToPolygons(peatthick, dissolve = T)
  peat_area[i] <- gArea(statshape) / 10000
  emission_total[i] <- emission_mean[i] * peat_area[i] * interval_length
  
  #calculate peat loss
  for(l in 1:length(peatthick)) {
    if (!is.na(peatthick[l]) & wl[l] > 0) {
      peatthick[l] <- peat_loss(wl[l], peatthick[l], interval_length, peat_loss_factor = 0.9974)
      }
  }
  
}

## results ##

print(peat_area)
print(emission_mean)
print(emission_total)
print(sum(emission_total))
