######### Author: Kevin Xie              #########
######### Project: DEEP-S                #########
######### Date: 2022.8                   #########
######### Good Good Study. Day Day Up.   #########

#output: 
# stomata length and width in um; 
# stomata and pavement cell areas in um2;
# stomata and pavement cell locations info in pixel;
# stomata and pavement cell densities in mm-2

library(splancs)
library(imager)
#library(MyEllipsefit)
library(magick)
library(mclust)
library(spatstat)
library(tiff)
library(purrr)
library(sp)
library(rgdal)
library(deldir)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(maptools)
library(stringr)
library(gpclib)
library(rjson)
library(sf)
library(raster)
library(randomcoloR)
library(outliers)
library(progress)
library(ClusterR)
library(cluster)
library(autoimage)


options(digits=20)

source("D:/ZJU/FieldLogBook/JsonCleanSort_V1.R")
source("D:/ZJU/FieldLogBook/ImageStitch_V2.R")
source("D:/ZJU/FieldLogBook/DrawImage_V1.R")
source("D:/ZJU/FieldLogBook/FilterPlot_SideDBSCAN_V1.R")
source("D:/ZJU/FieldLogBook/Plotmatch_grid_V1.R")
source("D:/ZJU/FieldLogBook/Pixel2latlon_V1.R")



#
# inputs
root = "D:/temp/root"
Project_name = "MockProject"
Flight_name = "flight1"
ROI_name = "ROI1"


ROI_dir = file.path(root, Project_name, Flight_name, ROI_name)
#print_instance_index = F

H = 1600 #height of cropped image
W = 1600 #width
O = 400 #overlapping
random_color = T
debug = FALSE


##################################################
#### Labeling individual images ####
if( debug == TRUE ){
  dir.create(file.path(ROI_dir, "detected_cropped"), showWarnings = FALSE)
  # data cleaning 
  (json_path = file.path(ROI_dir, "detected_cropped", "predict.json"))
  output = JsonCleanSort(json_readin = json_path, stitch_coordinates = FALSE)
  raw_polygon_list = output[[1]]
  raw_polygon_list_name = output[[2]]
  
  # draw
  Draw_Polygon_On_Individual_Images(draw_poly_list = raw_polygon_list,
                                    draw_poly_name_list = raw_polygon_list_name,
                                    cropped_image_dir = file.path(ROI_dir, "cropped"),
                                    output_dir = file.path(ROI_dir, "detected_cropped"))
  #### end ####
  
}

#### Labeling stitched image with unstitched predictions ####
if( debug == TRUE ){
  dir.create(file.path(ROI_dir, "detected_stitched"), showWarnings = FALSE)
  # data cleaning 
  (json_path = file.path(ROI_dir, "detected_cropped", "predict.json"))
  output = JsonCleanSort(json_readin = json_path, stitch_coordinates = TRUE)
  raw_polygon_list = output[[1]]
  raw_polygon_list_name = output[[2]]
  
  # draw
  Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name, ".tif")),
                                poly_draw_list = raw_polygon_list,
                                poly_name_list = raw_polygon_list_name, 
                                write_path = file.path(ROI_dir, "detected_stitched",
                                                       paste0("1_Unstitched_", ROI_name, ".png",sep="")))
  #### end ####
}



#### Labeling stitched image with stitched predictions ####
dir.create(file.path(ROI_dir, "detected_stitched"), showWarnings = FALSE)
# data cleaning 
json_path = file.path(ROI_dir, "detected_cropped", "predict.json")
output = JsonCleanSort(json_readin = json_path, stitch_coordinates = TRUE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# stitch predictions
output = PolygonStitching(raw_image_dir = file.path(ROI_dir, "cropped"), 
                          raw_polygon_list = raw_polygon_list, 
                          raw_polygon_list_name = raw_polygon_list_name)
stitched_polygon_list = output[[1]]
stitched_polygon_list_name = output[[2]]

if( debug == TRUE ){
  # draw
  Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name, ".tif")),
                                poly_draw_list = stitched_polygon_list,
                                poly_name_list = stitched_polygon_list_name, 
                                write_path = file.path(ROI_dir, "detected_stitched",
                                                       paste0("2_Stitched_", ROI_name, ".png",sep="")))
}

#### Filter plots ####
output = filter_SideDBSCAN(input_polygon_list = stitched_polygon_list,
                           input_polygon_list_name = stitched_polygon_list_name)
filtered_stitched_polygon_list = output[[1]]
filtered_stitched_polygon_list_name = output[[2]]

# draw
Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name, ".tif")),
                              poly_draw_list = filtered_stitched_polygon_list,
                              poly_name_list = filtered_stitched_polygon_list_name, 
                              write_path = file.path(ROI_dir, "detected_stitched",
                                                     paste0("3_Filtered_", ROI_name, ".png",sep="")))
#### end ####

### match plots
plot_dt = read.csv(file.path(root, Project_name, Flight_name, ROI_name, "plot_structure.csv"),
                   header = FALSE, na.strings=c(""))
plot_pixel_coor = plotmatch_grid(filtered_stitched_polygon_list, plot_dt)

### convert to latlon coordinates
for(i in 1:nrow(plot_pixel_coor)){
  coor_out = ROI_pixel_latlon(plot_pixel_coor$X[i], plot_pixel_coor$Y[i], Project_name, Flight_name, ROI_name)

  
  
  coor_out[[1]]
  coor_out[[2]]
  
  
}












































