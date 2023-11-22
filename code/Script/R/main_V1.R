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

# source("E:/ZJU/FieldLogBook/JsonCleanSort_V1.R")
# source("E:/ZJU/FieldLogBook/ImageStitch_V2.R")
# source("E:/ZJU/FieldLogBook/DrawImage_V1.R")
# source("E:/ZJU/FieldLogBook/FilterPlot_V1.R")
setwd("./Script/R")
source("./JsonCleanSort_V1.R")
source("./ImageStitch_V2.R")
source("./DrawImage_V1.R")
source("./FilterPlot_V1.R")
source("./poly_coor_output.R")


pixel_to_lonlat = function(input, source_image) {
  X_target_pixel = input$X
  Y_target_pixel = input$Y

  image <- raster(source_image)
  X_resolution = (image@extent@xmax - image@extent@xmin) / image@ncols
  Y_resolution = (image@extent@ymax - image@extent@ymin) / image@nrows

  X_target_lonlat = X_target_pixel * X_resolution + image@extent@xmin
  Y_target_lonlat = Y_target_pixel * Y_resolution + image@extent@ymax
  output = cbind(X_target_lonlat, Y_target_lonlat)
  return(output)
}


#
# root_dir = "E:/ZJU/FieldLogBook/datasets"
# project_name = "2022_Fuyang_rice_new"
args<-commandArgs(T)
if(length(args)){
    for (i in 1:length(args)){
        print(args[i])
    }
    print("args feedback over!")
}
root_dir = args[1]      # root_dir = "E:/FiledLogBook/datasets"
project_name = args[2]  # project_name = "2022_Fuyang_rice"
farm_name = args[2]
code_dir = "./"
project_dir = file.path(root_dir)
# project_dir = file.path(root_dir, project_name)
#print_instance_index = F

H = 1600 #height of cropped image
W = 1600 #width
O = 400 #overlapping
random_color = T


# pick image
# TD_image = c("20220728_P1_25m_E1E2.tif")
TD_image = c(farm_name)

# raw image dir
raw_image_dir = file.path(project_dir, "cropped", TD_image)


#### Labeling individual images ####
# data cleaning 
(json_path = file.path(project_dir,"detected_cropped", TD_image, "predict.json"))
output = JsonCleanSort(json_readin = json_path, stitch_coordinates = FALSE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# draw
dir.create(file.path(project_dir, "detected_uncropped", TD_image), showWarnings = T)
dir.create(file.path(project_dir, "detected_uncropped", TD_image, "cropped"), showWarnings = T)
Draw_Polygon_On_Individual_Images(draw_poly_list = raw_polygon_list,
                                  draw_poly_name_list = raw_polygon_list_name,
                                  cropped_image_dir = raw_image_dir,
                                  output_dir = file.path(project_dir, "detected_uncropped", TD_image))
#### end ####



#### Labeling stitched image with unstitched predictions ####
# data cleaning 
(json_path = file.path(project_dir,"detected_cropped", TD_image, "predict.json"))
output = JsonCleanSort(json_readin = json_path, stitch_coordinates = TRUE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]

# draw
dir.create(file.path(project_dir, "detected_uncropped", TD_image, "stitched_ortho"), showWarnings = T)
Draw_Polygon_On_Stiched_Image(image_name = file.path(project_dir, "uncropped", TD_image),
                              poly_draw_list = raw_polygon_list,
                              poly_name_list = raw_polygon_list_name, 
                              write_path = file.path(project_dir, "detected_uncropped", TD_image, 
                                                     paste0("1_Unstitched_", TD_image, ".png",sep="")))
#### end ####




#### Labeling stitched image with stitched predictions ####
# data cleaning 
(json_path = file.path(project_dir,"detected_cropped", TD_image, "predict.json"))
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
Draw_Polygon_On_Stiched_Image(image_name = file.path(project_dir, "uncropped", TD_image),
                              poly_draw_list = stitched_polygon_list,
                              poly_name_list = stitched_polygon_list_name, 
                              write_path = file.path(project_dir, "detected_uncropped", TD_image, 
                                                     paste0("2_Stitched_", TD_image, ".png",sep="")))
#### end ####




#### Filter plots ####
output = FilterPlots(input_polygon_list = stitched_polygon_list,
                     input_polygon_list_name = stitched_polygon_list_name)
filtered_stitched_polygon_list = output[[1]]
filtered_stitched_polygon_list_name = output[[2]]

# draw
Draw_Polygon_On_Stiched_Image(image_name = file.path(project_dir, "uncropped", TD_image),
                              poly_draw_list = filtered_stitched_polygon_list,
                              poly_name_list = filtered_stitched_polygon_list_name, 
                              write_path = file.path(project_dir, "detected_uncropped", TD_image, 
                                                     paste0("3Filtered_", TD_image, ".png",sep="")))

#### end ####



# output poly list coordinates
poly_coor_output(filtered_stitched_polygon_list, file.path(project_dir, "detected_uncropped", TD_image))








#pick histogram peak as "standard" plot area
area_list = st_area(filtered_stitched_polygon_list)
a = hist(area_list, breaks = "Freedman-Diaconis")
bound_low = a$breaks[which(a$counts == max(a$counts))-2]
bound_high = a$breaks[which(a$counts == max(a$counts))+2]
area_similar_polys = filtered_stitched_polygon_list[which(area_list < bound_high & area_list > bound_low)]
area_similar_polys_name = filtered_stitched_polygon_list_name[which(area_list < bound_high & area_list > bound_low)]



# filter out instances with similar area but difference side length
bbox_list = st_sfc()
longerside_list = c()
for(i in 1:length(area_similar_polys)){
  bbx = st_as_sfc(st_bbox(area_similar_polys[i]))
  bbox_list = c(bbox_list, bbx)
  
  bbx_coor = st_coordinates(bbx)
  longerside_list = c(longerside_list, max(abs(bbx_coor[1,1]-bbx_coor[2,1]), abs(bbx_coor[2,2]-bbx_coor[3,2]) )) 
  
}

remove_poly_name_list = c()
if(length(longerside_list) > 1){
  out_flag = TRUE
  while(out_flag == TRUE){
    out_flag = FALSE
    test = grubbs.test(longerside_list)
    if(test$p.value < 0.01){
      out_flag = TRUE
      
      if(length(grep("lowest", test$alternative)) == 1){
        remove_index = which(longerside_list == min(longerside_list))
      }
      if(length(grep("highest", test$alternative)) == 1){
        remove_index = which(longerside_list == max(longerside_list))
      }
      
      remove_poly_name_list = c(remove_poly_name_list,  area_similar_polys_name[remove_index])
      print(paste0("Filter SIZE: remove polygon ", area_similar_polys_name[remove_index]))
      area_similar_polys = area_similar_polys[-remove_index]
      area_similar_polys_name = area_similar_polys_name[-remove_index]
      longerside_list = longerside_list[-remove_index]
      next
    }
  }
}


# grouping 2 clusters
c_df = as.data.frame(st_coordinates(st_centroid(area_similar_polys)))
distance_mat <- dist(c_df, method = 'euclidean')
Hierar_cl <- hclust(distance_mat, method = "average")
fit <- cutree(Hierar_cl, k = 2 )

plot(c_df)
plot(c_df[which(fit == 1),])

area_similar_polys_g1 = area_similar_polys[which(fit == 1)]
area_similar_polys_g1_name = area_similar_polys_name[which(fit == 1)]

area_similar_polys_g2 = area_similar_polys[which(fit == 2)]
area_similar_polys_g2_name = area_similar_polys_name[which(fit == 2)]



# to be continued -- some polys have type of multipolygon. I forced them to be polygon here
for(i in 1:length(area_similar_polys_g2)){
  print(i)
  if(class(area_similar_polys_g2[i])[1] ==  "sfc_MULTIPOLYGON"){
    area_similar_polys_g2[i] = st_cast(area_similar_polys_g2[i], "POLYGON")
  }
}
area_similar_polys_g2[180]





# c_df_group2 = as.data.frame(st_coordinates(st_centroid(area_similar_polys_g2)))
c_df_group2 = as.data.frame(st_coordinates(area_similar_polys_g2))[,c(1,2)]
plot(c_df_group2, xlim = c(15000, 30000), ylim = c(5000, 25000))
plot(c_df_group2)


coords <- as.matrix(c_df_group2)
rcoords <- rotate(coords, 2/160*pi)  # 2 is the rotation angle
plot(rcoords)

rcoords = as.data.frame(rcoords)
names(rcoords) = c("X", "Y")
points = st_as_sf(rcoords, coords = c('X', 'Y'))

# visualization
par(mfrow = c(1, 1))
plot(points)
plot(st_make_grid(points, n = c(12, 23), what = "centers"), axes = TRUE, add = TRUE)




plot_pixel_coor = st_coordinates(st_make_grid(points, n = c(12, 23),, what = "centers"))[, c(1,2)]
plot_pixel_coor_r = as.data.frame(rotate(plot_pixel_coor, -2/160*pi))
names(plot_pixel_coor_r) = c("X", "Y")

tem = rbind(c_df_group2, plot_pixel_coor_r)


plot(tem)




source_image = file.path(project_dir, "uncropped", TD_image)
plot_lonlat_coor = as.data.frame(pixel_to_lonlat(plot_pixel_coor_r, source_image))

# ggplot(plot_lonlat_coor, aes(X_target_lonlat, Y_target_lonlat, label = rownames(plot_lonlat_coor)))+ geom_text()
  # geom_point() + geom_text()


write.csv(plot_lonlat_coor, file.path(project_dir,"detected_uncropped", TD_image, "plot_lonlat_coor.csv"))


##

# c = cross_list[which(poly_intersection_matrix[, 1839])]
# ggplot() + geom_sf(data = c, size = 2, color = "black", fill=NA) + geom_sf(data = d, size = 2, color = "black", fill = "cyan1") 


# d = raw_polygon_list[1839]
# ggplot() + geom_sf(data = area_similar_polys_g2[180], size = 2, color = "black", fill = "cyan1") 


logbook = read.csv(file = file.path(root_dir, "pic.csv"), header = TRUE, fileEncoding="GBK")
logbook[which(logbook$image_name==farm_name),5]=TRUE
write.csv(logbook,file.path(root_dir, "pic.csv"),row.names=FALSE, fileEncoding="GBK")



# read in large image file
# uncropped_image <- raster(file.path(whole_image_dir, tif_file))
# uncropped_image
# xmax = uncropped_image@ncols
# ymax = uncropped_image@nrows

# X_resolution = (uncropped_image@extent@xmax - uncropped_image@extent@xmin)/uncropped_image@ncols
# Y_resolution = (uncropped_image@extent@ymax - uncropped_image@extent@ymin)/uncropped_image@nrows












#draft
# points = st_centroid(all_poly_list_added)
# plot(points)
# plot(st_make_grid(points), axes = TRUE, add = TRUE)





# # plotting
# ggplot() + geom_sf(data = all_poly_list_added, size = 1, color = "black", fill = "cyan") + coord_sf()



















