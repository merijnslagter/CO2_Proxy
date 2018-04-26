
setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

require(rgdal)
require(rgeos)
require(raster)

rewet <- raster("final/co2_twater_rewetting_30years_phase_01.tif")
bau <-  raster("final/co2_twater_bau_30years_phase_01.tif")

rewet[is.na(rewet)][] <- 0
bau[is.na(bau)][] <- 0

reduction <- bau - rewet

reduction[reduction <= 0][] <- NA

writeRaster(reduction,"final/co2_twater_reduction_30years_phase_01.tif", datatype='FLT4S', overwrite=TRUE)
