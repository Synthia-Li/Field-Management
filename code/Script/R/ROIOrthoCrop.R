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

#### front end inputs

# root = "D:/temp/root"
# Project_name = "MockProject"
# Flight_name = "flight1"
# ROI_name = "ROI1"
# downscale = 0
# H_user = est_crop_side

# User input
# H_user = 1024 #height of cropped image
# H_user = 1024 #width
# H_user = 1024/4 #overlapping


random_pick_image = TRUE
pick_ratio = 3 # pick one third of all images as training data
max_pick = 50


# pick from stored info  ??
# ROI_info = fromJSON(file = file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))
# if(ROI_info$progress_bar$plot_size_estimation == "done"){
#   H = ROI_info$estimated_crop_size
#   W = ROI_info$estimated_crop_size
#   O = ROI_info$estimated_crop_size/4
# }else{
#   H = H_user
#   W = W_user
#   O = O_user
# }

H = est_crop_side
W = est_crop_side
O = est_crop_side/4


# START here
ROI_dir = file.path(root, Project_name, Flight_name, ROI_name)
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

#### add info ####
ROI_info = fromJSON(file = file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))
ROI_info$progress_bar$crop = "done"

if("used_crop_size" %in% names(ROI_info)){
  ROI_info$used_crop_size = W
}else{
  ROI_info[[length(ROI_info)+1]] = W
  names(ROI_info)[[length(ROI_info)]] = "used_crop_size"
}

myfile = toJSON(ROI_info)
write(myfile, file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))


#### pick image for training ####
if(random_pick_image){
  
  picked_image_dir = file.path(ROI_dir, paste0(ROI_name, "_picked_images"))
  
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








