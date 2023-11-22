library(maptools)
library(rgdal)
library(sp)

options(digits=20)

# inputs
root = "D:/temp/root"
Project_name = "MockProject"
Flight_name = "flight1"
ROI_name = "ROI1"
downscale = 0

set_name = "set1"

###################  start  ######################
ROI_dir = file.path(root, Project_name, Flight_name, ROI_name)
set_dir = file.path(ROI_dir, set_name)


#data
marker_coor_list = read.table(file.path(set_dir, "plot_summary.csv"), sep=",")



plot <- c("a","b","c","b","c")
lat <- c(30.30440392267365, 30.304401062720935, 30.30439826607997, 30.304401404746564, 30.30440087177137)
long <- c(120.07415632250671, 120.07415684293385, 120.07415852928662, 120.07416066979034, 120.07415322441743)
marker_coor_list <- cbind.data.frame(plot, lat, long)



WGScoor = marker_coor_list
coordinates(WGScoor) = ~long+lat
proj4string(WGScoor) <- CRS("+proj=longlat +datum=WGS84")


LLcoor<-spTransform(WGScoor,CRS("+proj=longlat"))
raster::shapefile(LLcoor, file.path(set_dir, "MyShapefile.shp"), overwrite=TRUE)



# # read
# dt = readShapeSpatial("MyShapefile.shp")
