library(magick)
library(rjson)

#### read in parameters ####
# 大田完整正射影像图路径
root = "D:/temp/root"
Project_name = "MockProject"
Flight_name = "flight1"
ROI_name = "ROI1"

ROI_path = file.path(root, Project_name, Flight_name, ROI_name)

uncropped_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "uncropped")
dir.create(uncropped_image_dir, showWarnings = FALSE)

#目前缺少一步，将小图的坐标转换到downscale0的坐标。



measured_p1 = c(28604, 6447) # 左上角
measured_p2 = c(44450, 5723) # 右上角
measured_p3 = c(29754, 32114) # 左下角

downscale = 2




flight_info = fromJSON(file = file.path(root, Project_name, Flight_name, "flight_info.json"))
scaleinfo = flight_info[["Complete_Orthomosaic_info"]][[paste0("downscale", downscale)]]
scale_factor = scaleinfo$scale


W = sqrt((measured_p1[1]-measured_p2[1])^2+(measured_p1[2]-measured_p2[2])^2) / scale_factor
alpha = (90 - atan((measured_p3[2] - measured_p1[2])/(measured_p3[1] - measured_p1[1])) / pi *180)/180*pi

p1 = measured_p1 / scale_factor
p2 = c(p1[1]+ cos(alpha)* W , p1[2] - sin(alpha)* W)
p3 = measured_p3 / scale_factor
p4 = c(p3[1]+ cos(alpha)* W , p3[2] - sin(alpha)* W)


# initialize
name = paste0("CompleteOrtho_downscale", downscale, ".tif")
read_path = file.path(root, Project_name, Flight_name, "CompleteOrtho", name) 


# mode
debug = FALSE


##################################################
#### code start here ####



#### crop IMG to fit bbx ####
IM0 = image_read(read_path)
image_info(IM0)

bbox_x_min = min(p1[1], p2[1], p3[1], p4[1])
bbox_x_max = max(p1[1], p2[1], p3[1], p4[1])
bbox_y_min = min(p1[2], p2[2], p3[2], p4[2])
bbox_y_max = max(p1[2], p2[2], p3[2], p4[2])

origin_x_new = bbox_x_min
origin_y_new = bbox_y_min
bbox_width_new = bbox_x_max - bbox_x_min
bbox_height_new = bbox_y_max - bbox_y_min


IM1 = image_crop(IM0, paste(bbox_width_new,"x",bbox_height_new,"+",origin_x_new,"+",origin_y_new,sep="")) #width/height/x/y




#### rotate IMG ####
p1_new = p1 - c(origin_x_new, origin_y_new)
p2_new = p2 - c(origin_x_new, origin_y_new)
p3_new = p3 - c(origin_x_new, origin_y_new)
p4_new = p4 - c(origin_x_new, origin_y_new)

# beta是顺时针旋转距离垂直向上的轴的角度
beta = atan((p3_new[2] - p1_new[2] )/(p3_new[1] - p1_new[1])) /pi * 180
beta = 90-beta
# RecCenter_x 田块中心位置
RecCenter_x = mean(c(p2_new[1], p3_new[1])) 
# RecCenter_y 田块中心位置
RecCenter_y = mean(c(p2_new[2], p3_new[2])) 
# W 为水平于屏幕方向的田块长度 
Rec_W = sqrt((p1_new[1]-p2_new[1])^2 + (p1_new[2]-p2_new[2])^2) 
# H 为垂直于屏幕方向的田块长度
Rec_H = sqrt((p1_new[1]-p3_new[1])^2 + (p1_new[2]-p3_new[2])^2) 


ImgCenter_x = as.numeric(image_info(IM1)[2])/2
ImgCenter_y = as.numeric(image_info(IM1)[3])/2


if(debug){
  img = image_draw(IM1)                                                       
  points(RecCenter_x, RecCenter_y, pch = 19, cex = ImgCenter_x/500, col = "red")
  dev.off()
  image_write(img, file.path(ROI_path, "uncropped", 'magick_after_crop_before_rotate.png'), format = "png")
}


IM1_r = image_rotate(IM1, beta)

# image_write(IM1, "tem.png", format = "png")
# M1 = image_read( "tem.png")

image_info(IM1_r)
IMGCenter_x_rotated = as.numeric(image_info(IM1_r)[2])/2
IMGCenter_y_rotated = as.numeric(image_info(IM1_r)[3])/2
RecCenter_x_rotated = (RecCenter_x-ImgCenter_x)*cos(beta*pi/180)-(RecCenter_y-ImgCenter_y)*sin(beta*pi/180) + IMGCenter_x_rotated
RecCenter_y_rotated = (RecCenter_x-ImgCenter_x)*sin(beta*pi/180)+(RecCenter_y-ImgCenter_y)*cos(beta*pi/180) + IMGCenter_y_rotated

if(debug){
  image_info(IM1_r)
  img = image_draw(IM1_r)
  points(RecCenter_x_rotated, RecCenter_y_rotated, pch = 19, cex = ImgCenter_x/300, col = "red")
  dev.off()
  image_write(img, file.path(ROI_path, "uncropped", 'magick_after_crop_after_rotate.png'), format = "png")
}


### crop rotated IMG ###

# adding offsets for odd reasons
x_offset = -(IMGCenter_x_rotated - ImgCenter_x)
y_offset = -(IMGCenter_y_rotated - ImgCenter_y)


IM_crop = image_crop(IM1_r, paste(Rec_W,"x",Rec_H,"+",
                                  RecCenter_x_rotated-Rec_W/2+x_offset,"+",RecCenter_y_rotated-Rec_H/2+y_offset,sep="")) #width/height/x/y
image_write(IM_crop, file.path(ROI_path, "uncropped", paste0(ROI_name, "_downscale", downscale,".png")), format = "png")



if(debug){
  image_info(IM_crop)
  img = image_draw(IM_crop)
  points(Rec_W/2, Rec_H/2, pch = 19, cex = ImgCenter_x/300, col = "red")
  dev.off()
  image_write(img, file.path(ROI_path, "uncropped", 'magick_after_crop_after_rotate_after_rotate.png'), format = "png")
}



#### Add info into flight_info.json ####
this_ROI_info = list(beta = beta,
                     # IMG_center = list(x = ImgCenter_x, y = ImgCenter_y),
                     # IMG_size = list(w = ImgCenter_x*2, h = ImgCenter_y*2),
                     IMG_center_rotated = list(x = IMGCenter_x_rotated, y = IMGCenter_y_rotated),
                     ROI_center_on_IMG = list(x = RecCenter_x + origin_x_new, y = RecCenter_y + origin_y_new),
                     ROI_size = list(w = Rec_W, h = Rec_H),
                     IMG_cropped_center_on_rotated_IMG = list(x = RecCenter_x_rotated, y = RecCenter_y_rotated))

ROI_info = fromJSON(file = file.path(root, Project_name, Flight_name, "flight_info.json"))

if(is.na(ROI_info$ROI_list)){ 
  #initialize first instance
  ROI_info[[length(ROI_info)+1]] = this_ROI_info
  names(ROI_info)[[length(ROI_info)]] = "ROI1"
  ROI_info$ROI_list = "ROI1"
}else{
  index = max(as.numeric(gsub("ROI", "", ROI_info$ROI_list)))
  ROI_name = paste0("ROI", index + 1)
  ROI_info[[length(ROI_info)+1]] = this_ROI_info
  names(ROI_info)[[length(ROI_info)]] = ROI_name
  ROI_info$ROI_list = c(ROI_info$ROI_list, ROI_name)
}


json_list = ROI_info


myfile = toJSON(json_list)
write(myfile, file.path(root, Project_name, Flight_name, "flight_info.json"))



#### create ROI_info.json ####
ROI_progress_bar = list(plot_size_estimation = "none",
                        crop = "none",
                        detection = "none",
                        stitched = "none",
                        filtered = "none",
                        finetuned = "none")

ROI_info = list(progress_bar = ROI_progress_bar)
ROI_myfile = toJSON(ROI_info)
write(ROI_myfile, file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))




## archive
# library(OpenImageR)
# path = file.path("tem_raster.tif")
# im = readImage(path)
# dim(im)
# imageShow(im)
# 
# start_time <- Sys.time()
# r250 = rotateImage(im, 250,  method = "nearest", mode = "full", threads = 8)
# dim(r250)
# end_time <- Sys.time()
# end_time - start_time
# 
# imageShow(r250)
# writeImage(r250, 'OpenImageR_after.png')








