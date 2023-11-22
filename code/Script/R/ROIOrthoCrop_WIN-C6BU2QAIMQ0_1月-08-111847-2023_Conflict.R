library(jpeg)
library(tiff)
library(magick)
library(splancs)
library(imager)
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


root = "D:/temp/root"
Project_name = "MockProject"
Flight_name = "flight1"
ROI_name = "ROI1"
downscale = 0


# User input
H = 2048 #height of cropped image
W = 2048 #width
O = 2048/4 #overlapping


random_pick_image = TRUE
pick_ratio = 3 # pick one third of all images as training data
max_pick = 50



# START here
uncropped_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "uncropped")
to_save_dir = file.path(root, Project_name, Flight_name, ROI_name, "cropped")
dir.create(to_save_dir, showWarnings = FALSE)

image_name = paste0(ROI_name, "_downscale", downscale, ".png")
image = image_read(file.path(uncropped_image_dir, image_name))
print(paste0("############## NOW cropping  ---- ", image_name, " ##############"))

print("Raw image info:")
info = image_info(image)
print(info)

if(length(image) > 1){
  image = image[as.numeric(1)]
  print("Pick first image. Manual check if it is what you want!")
}
# if(length(image) > 1){
#   image
#   print(raw_list[i])
#   print("file has more than one frame")
#   frame.pick <- readline(prompt="Enter frame: ")
#   image_backup = image
#   image = image[as.numeric(frame.pick)]
# }

print("Now:")
info = image_info(image)
print(info)

print("inspect if color space is sRGB and if matte = False")
# test_sample = image_crop(image, paste(512,"x",512,"+",0,"+",0,sep=""))
# print(test_sample)

# if(info$width > 512) stop("image width outside 512")
#if(info$height < H) stop("image height smaller than H")
cropping_wn = ceiling((info$width - W)/(W-O)) + 1
cropping_hn = ceiling((info$height - H)/(H-O)) + 1
index_all = cropping_wn*cropping_hn

x = 0
name_list = c()
index = 0
for( j in 1:cropping_wn){
  xx = x + W
  if (xx > info$width) xx = info$width
  y = 0
  for( k in 1:cropping_hn){
    index = index + 1
    yy = y + H
    if (yy > info$height) yy = info$height
    image_to_save = image_crop(image, paste(W,"x",H,"+",xx-W,"+",yy-H,sep="")) #width/height/x/y
    
    image_to_save = image_scale(image_scale(image_to_save,"1024"),"x1024")
    
    image_to_save_name = paste(ROI_name, "(x[", xx-W,"][",xx, "]y[", yy-H, "][", yy, "]i[", index, "][", index_all, "]).png", sep = "" )
    #image_to_save_name = paste(ROI_name, "CROP(x[", xx-W,"][",xx, "]y[", yy-H, "][", yy, "]_", index, "[", index_all, "]).png", sep = "" )
    #image_write(image_to_save,image_to_save_name,"tif")
    image_write(image_to_save, file.path(to_save_dir, image_to_save_name), format = "png")
    y = y - O + H
    print(image_to_save_name)
    name_list = c(name_list, image_to_save_name)
  }
  x = x - O + W
}




if(random_pick_image){
  
  picked_image_dir = file.path(to_save_dir, paste0(ROI_name, "_picked_images"))
  
  dir.create(picked_image_dir, showWarnings = F)
  
  
  #setwd(file.path(cropped_dir, raw_list[i]))
  if(index_all/pick_ratio < max_pick){
    to_pick_index = sample(1:length(name_list),index_all/pick_ratio)
  }else{
    to_pick_index = sample(1:length(name_list),max_pick)
  }
  to_pick_index = sort(to_pick_index)
  
  img <- image_draw(image)
  size_tem = min(as.numeric(as.data.frame(image_info(image))[2]), as.numeric(as.data.frame(image_info(image))[3]))
  
  for(m in 1:length(to_pick_index)){
    print(paste0(m, "th image"))
    file.copy(file.path(to_save_dir, name_list[to_pick_index[m]]), picked_image_dir)
    renaming = paste0("P",m,"_",name_list[to_pick_index[m]])
    file.rename(file.path(picked_image_dir, name_list[to_pick_index[m]]),
                file.path(picked_image_dir, renaming))

    tem = strsplit(renaming, split = "\\.")[[1]]
    tem = tem[length(tem)-1]
    
    tem2 = regmatches(tem, gregexpr("(?<=\\().*?(?=\\))", tem, perl=T))[[1]]
    tem2 = tem2[length(tem2)]
    
    tem3 = strsplit(tem2, split = "[[:punct:]]")[[1]]
    
    
    rect(tem3[2], tem3[6], tem3[4], tem3[8], border = "red", lty = "dashed", lwd = size_tem/1000) #x1, y1, x2, y2
    text((as.numeric(tem3[2])+as.numeric(tem3[4]))/2, (as.numeric(tem3[6])+as.numeric(tem3[8]))/2, 
         paste0("P",m), cex = size_tem/500)
    
    # read in tiff
    #img.tif <- readTIFF(name_list[to_pick_index[m]], native=TRUE)
    # write to jpeg
    
    #jpeg_name = file.path(cropped_dir, raw_list[i],"picked_images_jpeg",
    #                      paste0(gsub(".tif", "",name_list[to_pick_index[m]]),".jpeg"))
    #writeJPEG(img.tif, target = jpeg_name, quality = 1)
  }
  dev.off()
  image_write(img, file.path(picked_image_dir, "Reference_image_DO_NOT_LABEL.png"), format = "png")
  
}








