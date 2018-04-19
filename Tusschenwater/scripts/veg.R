setwd("/home/merijn/Documents/Nijmegen_Stu_As/Project_Vegetation_Proxy/R/Tusschenwater")

require(rgdal)
require(rgeos)

twater <- readOGR("source/Tusschenwater_boundaries","Tusschenwater_boundaries")
vegmap <- readOGR("source/veg_map_twater","veg_map_tusschenwater")

veg_type <- c('vochtig hooiland','pitrus','rietmoeras')
GWPpot <- c('31.5','14.5','6.5')

GWPtable <- data.frame(veg_type, GWPpot)

vegmap <- merge(vegmap,GWPtable,by ="veg_type", all.x=TRUE)

vegmap$area <- gArea(vegmap, byid = T)/10000

vegmap$GWPtot <- as.character(vegmap$GWPpot) * vegmap$area

writeOGR(vegmap,dsn = "inter/shapes/veg", layer = "vegmapwithGWP", driver="ESRI Shapefile", overwrite_layer = TRUE)