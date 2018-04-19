
setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

require(rgdal)
require(rgeos)
require(raster)

twater <- readOGR("source/Tusschenwater_boundaries","Tusschenwater_boundaries")
peatthick <- raster("source/veenraster.tif")
gvgnow <- raster("source/gvghuidig.tif")
gvgfuture <- raster("source/gvgplan.tif")

gvgnow_crop <- crop(gvgnow, twater)
gvgnow_mask <- mask(gvgnow, twater)

gvgfuture_crop <- crop(gvgfuture, twater)
gvgfuture_mask <- mask(gvgfuture, twater)

peatthick_crop <- crop(peatthick, twater)
peatthick_mask <- mask(peatthick, twater)


writeRaster(gvgnow_mask,"inter/gvgnow_mask.tif", datatype='FLT4S', overwrite=TRUE)
writeRaster(gvgfuture_mask,"inter/gvgfuture_mask.tif", datatype='FLT4S', overwrite=TRUE)
writeRaster(peatthick_mask,"inter/peatthick_mask.tif", datatype='FLT4S', overwrite=TRUE)
#me