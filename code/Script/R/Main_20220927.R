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

source("E:/ZJU/FieldLogBook/JsonCleanSort_V1.R")
source("E:/ZJU/FieldLogBook/ImageStitch_V2.R")
source("E:/ZJU/FieldLogBook/DrawImage_V1.R")
source("E:/ZJU/FieldLogBook/FilterPlot_V1.R")


#
root_dir = "D:/ZJU/FieldLogBook/datasets"
project_name = "2022_Fuyang_rice_new"

project_dir = file.path(root_dir, project_name)
#print_instance_index = F

H = 1600 #height of cropped image
W = 1600 #width
O = 400 #overlapping
random_color = T


# pick image
TD_image = c("20220728_P1_25m_E1E2.tif")

# raw image dir
raw_image_dir = file.path(project_dir, "data", "cropped", TD_image)


#### Labeling individual images ####
# data cleaning 
(json_path = file.path(project_dir, "data","detected_cropped", TD_image, "predict.json"))
output = JsonCleanSort(json_readin = json_path, stitch_coordinates = FALSE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# draw
Draw_Polygon_On_Individual_Images(draw_poly_list = raw_polygon_list,
                                  draw_poly_name_list = raw_polygon_list_name,
                                  cropped_image_dir = raw_image_dir,
                                  output_dir = file.path(project_dir, "data", "detected_cropped", TD_image))
#### end ####



#### Labeling stitched image with unstitched predictions ####
# data cleaning 
(json_path = file.path(project_dir, "data","detected_cropped", TD_image, "predict.json"))
output = JsonCleanSort(json_readin = json_path, stitch_coordinates = TRUE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# draw
Draw_Polygon_On_Stiched_Image(image_name = file.path(project_dir, "data", "orthomosaic", TD_image),
                              poly_draw_list = raw_polygon_list,
                              poly_name_list = raw_polygon_list_name, 
                              write_path = file.path(project_dir, "data", "detected_stitched", TD_image, 
                                                     paste0("1_Unstitched_", TD_image, ".png",sep="")))
#### end ####




#### Labeling stitched image with stitched predictions ####
# data cleaning 
(json_path = file.path(project_dir, "data","detected_cropped", TD_image, "predict.json"))
output = JsonCleanSort(json_readin = json_path, stitch_coordinates = TRUE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# stitch predictions
output = PolygonStitching(raw_image_dir = raw_image_dir, 
                          raw_polygon_list = raw_polygon_list, 
                          raw_polygon_list_name = raw_polygon_list_name)
stitched_polygon_list = output[[1]]
stitched_polygon_list_name = output[[2]]

# draw
Draw_Polygon_On_Stiched_Image(image_name = file.path(project_dir, "data", "orthomosaic", TD_image),
                              poly_draw_list = stitched_polygon_list,
                              poly_name_list = stitched_polygon_list_name, 
                              write_path = file.path(project_dir, "data", "detected_stitched", TD_image, 
                                                     paste0("2_Stitched_", TD_image, "2.png",sep="")))
#### end ####




#### Filter plots ####
output = FilterPlots(input_polygon_list = stitched_polygon_list,
                     input_polygon_list_name = stitched_polygon_list_name)
filtered_stitched_polygon_list = output[[1]]
filtered_stitched_polygon_list_name = output[[2]]

# draw
Draw_Polygon_On_Stiched_Image(image_name = file.path(project_dir, "images", "orthomosaic", TD_image),
                              poly_draw_list = filtered_stitched_polygon_list,
                              poly_name_list = filtered_stitched_polygon_list_name, 
                              write_path = file.path(project_dir, "data", "detected_stitched", TD_image, 
                                                     paste0("3Filtered_", TD_image, ".png",sep="")))

#### end ####
