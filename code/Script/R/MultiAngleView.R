library(maptools)
library(rgdal)
library(sp)

options(digits=20)

#data
plot <- c("a","b","c","b","c")
lat <- c(30.30440392267365, 30.304401062720935, 30.30439826607997, 30.304401404746564, 30.30440087177137)
long <- c(120.07415632250671, 120.07415684293385, 120.07415852928662, 120.07416066979034, 120.07415322441743)
marker_coor_list <- cbind.data.frame(plot, lat, long)



WGScoor = marker_coor_list
coordinates(WGScoor) = ~long+lat
proj4string(WGScoor) <- CRS("+proj=longlat +datum=WGS84")


LLcoor<-spTransform(WGScoor,CRS("+proj=longlat"))
raster::shapefile(LLcoor, "MyShapefile.shp", overwrite=TRUE)



# # read
# dt = readShapeSpatial("MyShapefile.shp")






#############################################
## read xml marker location and draw image
#############################################
library(magick)

source_folder = "F:/MAP杯数据存档/无人机数据/原始图片/2_展示田倾斜摄影"
output_folder = "E:/temp/draw"



# read marker info
dt = readOGR("E:/ZJU/FieldLogBook/test/MyShapefile.shp")
marker_coor_list = as.data.frame(coordinates(dt))
names(marker_coor_list) = c("long", "lat")
marker_plot_name = dt$plot


# read metashape output
library(XML)
data <- xmlParse("D:/ZJU/FieldLogBook/test/maker_summary.xml")
xml_data <- xmlToList(data)


# get camera list
camera_id = c()
camera_name = c()
for(i in 1:(length(xml_data[["chunk"]][["cameras"]])-1)){
  id = as.numeric(xml_data[["chunk"]][["cameras"]][[i]]$.attrs[1])
  label = as.character(xml_data[["chunk"]][["cameras"]][[i]]$.attrs[4])
  camera_id = c(camera_id, id)
  camera_name = c(camera_name, label)
}
stopifnot(length(camera_id) == length(camera_name))

# get frame list
frame_dt = xml_data[["chunk"]][["frames"]][["frame"]][["markers"]]
frame_marker_id = c()
for(i in 1:length(frame_dt)){
  frame_marker_id = c(frame_marker_id, as.character(frame_dt[[i]]$.attrs))
}
stopifnot(length(frame_marker_id) == nrow(marker_coor_list))


# get marker list
for(i in 1:(length(xml_data[["chunk"]][["markers"]])-1)){
  
  xml_long = as.numeric(xml_data[["chunk"]][["markers"]][[i]]$reference["x"])
  xml_lat = as.numeric(xml_data[["chunk"]][["markers"]][[i]]$reference["y"])
  
  # assert if the sequence of marker is same as in marker_coor_list
  if(marker_coor_list[i,]$long != xml_long | marker_coor_list[i,]$lat != xml_lat){
    stop(paste0("STOP! Check marker ", i))
  }
  
  # find out the correct marker_frame to use
  this_marker_id = xml_data[["chunk"]][["markers"]][[i]]$.attrs[["id"]]
  if(length(which(frame_marker_id == this_marker_id)) == 0) next
  marker_frame = frame_dt[which(frame_marker_id == this_marker_id)][["marker"]]
  
  print(paste0("there are ", length(marker_frame), " images includes marker ", this_marker_id))
  
  # label all images JUST TESTING
  for(k in 1:(length(marker_frame)-1)){
    pick_camera_id = as.numeric(marker_frame[k]$location[["camera_id"]])
    draw_point_x = as.numeric(marker_frame[k]$location[["x"]])
    draw_point_y = as.numeric(marker_frame[k]$location[["y"]])
    
    # get camera name
    pick_camera_name = paste0(camera_name[which(camera_id == pick_camera_id)], ".jpg")
    
    
    image = image_read(file.path(source_folder, pick_camera_name))
    w = as.numeric(image_info(image)["width"])
    h = as.numeric(image_info(image)["height"])
    

    if(w/4 < draw_point_x  &&  draw_point_x < 3*w/4 && h/4 < draw_point_y  &&  draw_point_y < 3*h/4){
      
      print(k)
      
      img <- image_draw(image)
      points(draw_point_x, draw_point_y, pch = 25, cex = 30, col = "red", bg = "red")
      
      dev.off()
      
      to_save_name = file.path(output_folder, paste0(pick_camera_name, ".png"))
      image_write(img, to_save_name, format = "png")
    }
    
    rm(image)
    gc()
  }
  
}




xml_data[["chunk"]][["frames"]][["frame"]][["markers"]]

View(xml_data[["chunk"]][["frames"]][["frame"]][["markers"]])

#


frame_dt = xml_data[["chunk"]][["frames"]][["frame"]][["markers"]]


marker_id = as.numeric(frame_dt[[i]]$.attrs)









T = chunk.transform.matrix
ptSrcT = T.inv().mulp(chunk.crs.unproject(ptSrc))
ptDstT = T.inv().mulp(chunk.crs.unproject(ptDst))
pT = chunk.model.pickPoint(ptSrcT, ptDstT)

m = chunk.addMarker(pT)








chunk = PhotoScan.app.document.chunk
camera = chunk.cameras[0]
point2D = PhotoScan.Vector([imgX,imgY]) # coordinates of the point on the given photo
sensor = camera.sensor
calibration = sensor.calibration
x = chunk.point_cloud.pickPoint(camera.center, camera.transform.mulp(sensor.calibration.unproject(point2D)))
chunk.addMarker(point = x)





