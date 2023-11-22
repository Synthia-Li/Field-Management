### Kevin
### Good Good Study
### Day Day Up

library("jpeg")
library("tiff")
library("magick")

# get input output args
args<-commandArgs(T)
if(length(args)){
    for (i in 1:length(args)){
        print(args[i])
    }
    print("args feedback over!")
}

# User input
H = 1600 #height of cropped image
W = 1600 #width
O = 400 #overlapping

random_pick_image = TRUE
pick_ratio = 3 # pick one third of all images as training data
max_pick = 50


####
# Load data
# load("stored_data.RData")# 是储存路径名的信息  # dataset_dir = file.path(root, dataset_name) 
# dataset_dir = "F:\\Career\\B01-FieldManager\\addin\\code\\FiledLogBook"
dataset_dir = args[1]
source_image_path = args[2]
## setwd(dataset_dir)

raw_image = file.path(dataset_dir, "uncropped")
cropped_dir = file.path(dataset_dir, "cropped")

# setwd(dataset_dir)
# logbook = read.table(file="pic.csv", header=TRUE, sep = ",")
include_image_list <- c(args[3])
## setwd(raw_image)
existing_image_list = Sys.glob(paste("*","tif",sep=""))

to_add_list = include_image_list[which(!include_image_list %in% existing_image_list)]

print(to_add_list)

for(i in 1:length(to_add_list)){
    dir.create(file.path(cropped_dir, to_add_list[i]), showWarnings = F)
    file.copy(file.path(source_image_path, to_add_list[i]),
            file.path(raw_image, to_add_list[i]))
}

logbook = read.csv(file = file.path(dataset_dir, "pic.csv"), header = TRUE, fileEncoding="GBK")


###
## setwd(raw_image)
raw_list = to_add_list

## setwd(cropped_dir)
for (i in 1:length(raw_list)){
  
  to_save_place = file.path(cropped_dir, raw_list[i])
  ## setwd(to_save_place)
  
  image_name = file.path(raw_image, raw_list[i])
  image = image_read(image_name)
  print(paste0("############## NOW dealing with ---- ", raw_list[i], " ##############"))
  
  print("Raw image info:")
  info = image_info(image)
  print(info)

  logbook[nrow(logbook)+1,] = c(raw_list[i],TRUE,"","","","","","","","","","")
  write.csv(logbook,file.path(dataset_dir, "pic.csv"),row.names=FALSE, fileEncoding="GBK")

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
  index = 0
  index_all = cropping_wn*cropping_hn
  x = 0
  name_list = c()
  
  for( j in 1:cropping_wn){
    xx = x + W
    if (xx > info$width) xx = info$width
    y = 0
    for( k in 1:cropping_hn){
      index = index + 1
      yy = y + H
      if (yy > info$height) yy = info$height
      image_to_save = image_crop(image, paste(W,"x",H,"+",xx-W,"+",yy-H,sep="")) #width/height/x/y
      image_to_save_name = paste("CROP(x[", xx-W,"][",xx, "]y[", yy-H, "][", yy, "]_", index, "[", index_all, "]).png", sep = "" )
      #image_write(image_to_save,image_to_save_name,"tif")
      image_write(image_to_save,file.path(to_save_place,image_to_save_name), format = "png")
      y = y - O + H
      print(image_to_save_name)
      name_list = c(name_list, file.path(image_to_save_name))
    }
    x = x - O + W
  }

  print("正在随机采样picked_images，裁切图片还没完成！")
  
  if(random_pick_image){
    
    picked_image_dir = file.path(cropped_dir,paste0(raw_list[i], "_picked_images"))
    dir.create(picked_image_dir, showWarnings = F)

    
    ## setwd(file.path(cropped_dir, raw_list[i]))
    if(index_all/pick_ratio < max_pick){
      to_pick_index = sample(1:length(name_list),index_all/pick_ratio)
    }else{
      to_pick_index = sample(1:length(name_list),max_pick)
    }
    to_pick_index = sort(to_pick_index)
    
    img <- image_draw(image)
    
    for(m in 1:(index_all/pick_ratio)){
      file.copy(file.path(to_save_place,name_list[to_pick_index[m]]), picked_image_dir)
      
      renaming = paste0("P",m,"_",name_list[to_pick_index[m]])
      file.rename(file.path(picked_image_dir, name_list[to_pick_index[m]]),
                  file.path(picked_image_dir, renaming))
      
      
      tem = strsplit(renaming, split = "\\.")[[1]][2]
      tem2 = strsplit(tem, split = "[[:punct:]]")[[1]]
      
      rect(tem2[3], tem2[7], tem2[5], tem2[9], border = "red", lty = "dashed", lwd = 7) #x1, y1, x2, y2
      text((as.numeric(tem2[3])+as.numeric(tem2[5]))/2, (as.numeric(tem2[7])+as.numeric(tem2[9]))/2, 
           paste0("P",m), cex = 20)
      
      # read in tiff
      #img.tif <- readTIFF(name_list[to_pick_index[m]], native=TRUE)
      # write to jpeg
      
      #jpeg_name = file.path(cropped_dir, raw_list[i],"picked_images_jpeg",
      #                      paste0(gsub(".tif", "",name_list[to_pick_index[m]]),".jpeg"))
      #writeJPEG(img.tif, target = jpeg_name, quality = 1)
    }
  }
  dev.off()
  
  ## setwd(picked_image_dir)
  image_write(img, file.path(picked_image_dir,"Reference_image_DO_NOT_LABEL.png"), format = "png")
  logbook[nrow(logbook),3] = TRUE
  write.csv(logbook,file.path(dataset_dir, "pic.csv"),row.names=FALSE, fileEncoding="GBK")
}
#image_to_save = image_crop(image, paste(xx-x,"x",yy-y,"+",x,"+",y,sep=""))

