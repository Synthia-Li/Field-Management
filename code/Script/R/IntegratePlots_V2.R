######### Author: Kevin Xie              #########
######### Project: FieldLogBook               #########
######### Date: 2022.8                   #########
######### Good Good Study. Day Day Up.   #########


suppressWarnings(suppressMessages(library(jpeg)))
suppressWarnings(suppressMessages(library(tiff)))
suppressWarnings(suppressMessages(library(magick)))
suppressWarnings(suppressMessages(library(splancs)))
suppressWarnings(suppressMessages(library(imager)))
suppressWarnings(suppressMessages(library(magick)))
suppressWarnings(suppressMessages(library(mclust)))
suppressWarnings(suppressMessages(library(spatstat)))
suppressWarnings(suppressMessages(library(tiff)))
suppressWarnings(suppressMessages(library(purrr)))
suppressWarnings(suppressMessages(library(sp)))
suppressWarnings(suppressMessages(library(rgdal)))
suppressWarnings(suppressMessages(library(deldir)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(ggplot2)))
suppressWarnings(suppressMessages(library(ggthemes)))
suppressWarnings(suppressMessages(library(maptools)))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(gpclib)))
suppressWarnings(suppressMessages(library(rjson)))
suppressWarnings(suppressMessages(library(sf)))
suppressWarnings(suppressMessages(library(raster)))
suppressWarnings(suppressMessages(library(randomcoloR)))
suppressWarnings(suppressMessages(library(outliers)))
suppressWarnings(suppressMessages(library(progress)))
suppressWarnings(suppressMessages(library(ClusterR)))
suppressWarnings(suppressMessages(library(cluster)))
suppressWarnings(suppressMessages(library(autoimage)))


options(digits=20)

source(file.path(code_dir, "JsonCleanSort_V1.R"))
source(file.path(code_dir, "DrawImage_V1.R"))



#### front end inputs

# root = "D:/temp/root"
# Project_name = "MockProject"
# Flight_name = "flight1"
# ROI_name = "ROI1"
# downscale = 0

random_color = T
debug = FALSE


###################  start  ######################
ROI_dir = file.path(root, Project_name, Flight_name, ROI_name)
#print_instance_index = F


# pick from stored info  ??
# ROI_info = fromJSON(file = file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))
# W = ROI_info$used_crop_size
# H = ROI_info$used_crop_size
# O = W / 4

H = est_crop_side
W = est_crop_side
O = est_crop_side/4


pixel_upscale = W / 1024



#### MRCNN prediction ####
dir.create(file.path(ROI_dir, "detected_cropped"), showWarnings = FALSE)
raw_image_dir = file.path(ROI_dir, "cropped")
result_image_dir = file.path(ROI_dir, "detected_cropped")

setwd("/home/zju/code/detectron2-main")
source(file.path(code_dir, "MRCNN_prediction.R"))
MRCNN_predict(InputPath = raw_image_dir,
              OutputPath = result_image_dir)
setwd(root)

ROI_info = fromJSON(file = file.path(ROI_dir, "ROI_info.json"))
ROI_info$progress_bar$detection = "done"
myfile = toJSON(ROI_info)
write(myfile, file.path(ROI_dir, "ROI_info.json"))





#### Labeling individual images and unstitched predictions ####
if( debug == TRUE ){
  source(file.path(code_dir, "IntegratePlots_debug.R"))
}


#### Labeling stitched image with stitched predictions ####
dir.create(file.path(ROI_dir, "detected_stitched"), showWarnings = FALSE)
# data cleaning 
json_path = file.path(ROI_dir, "detected_cropped", "predict.json")
output = JsonCleanSort(json_readin = json_path, 
                       pixel_upscale = pixel_upscale, 
                       stitch_coordinates = TRUE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# stitch predictions
#source(file.path(code_dir, "ImageStitch_V2.R"))
source(file.path(code_dir, "ImageStitch_V3.R"))
output = PolygonStitching(raw_image_dir = file.path(ROI_dir, "cropped"), 
                          raw_polygon_list = raw_polygon_list, 
                          raw_polygon_list_name = raw_polygon_list_name,
                          overlap_percentage = 0.8)
stitched_polygon_list = output[[1]]
stitched_polygon_list_name = output[[2]]


if( debug == TRUE ){
  plot(stitched_polygon_list)
  # draw
  Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name,"_downscale",downscale, ".png")),
                                poly_draw_list = stitched_polygon_list,
                                poly_name_list = stitched_polygon_list_name, 
                                write_path = file.path(ROI_dir, "detected_stitched",
                                                       paste0("2_Stitched_", ROI_name, ".png",sep="")))
}


ROI_info = fromJSON(file = file.path(ROI_dir, "ROI_info.json"))
ROI_info$progress_bar$stitched = "done"
myfile = toJSON(ROI_info)
write(myfile, file.path(ROI_dir, "ROI_info.json"))



# filter plots
source(file.path(code_dir, "FilterPlot_V1.R"))
output = FilterPlots(stitched_polygon_list, stitched_polygon_list_name,
                     draw = TRUE, dbscan_eps = 20)
filtered_stitched_polygon_list = output[[1]]
filtered_stitched_polygon_list_name = output[[2]]





































