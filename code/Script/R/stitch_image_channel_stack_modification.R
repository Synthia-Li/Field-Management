raw_list = Sys.glob(paste("*","tif",sep=""))
raw_list


image_name = raw_list[i]
image <- image_read(image_name)
info = image_info(image)



dim(info)
length(image)




image_channel(image)


setwd("D:/ningxia_maize/train")
raw_list = Sys.glob(paste("*","tif",sep=""))
raw_list[1]
band1 <- file.path(raw_list[1])
band2 <- file.path(raw_list[1])
band3 <- file.path(raw_list[1])
rgbRaster <- stack(band1,band2,band3)
orderRGBstack <- stack(rgbRaster[[1]], rgbRaster[[4]], rgbRaster[[7]])
image_to_save_name = file.path(paste("tem", ".tif", sep = ""))
options=c("PROFILE=BASELINE")
writeRaster(orderRGBstack, image_to_save_name, "GTiff", overwrite=TRUE ,datatype="INT1U" )
print(i)


View(rgbRaster[[1]])
View(as.data.frame(rgbRaster[[1]]))



setwd("D:/ningxia_maize/train_new")
raw_list = Sys.glob(paste("*","tif",sep=""))
raw_list[i]
ningxia = raster(raw_list[i])
image(ningxia)


setwd("D:/")
raw_list = Sys.glob(paste("*","tif",sep=""))
raw_list[1]
maize = raster(raw_list[1])
image(maize)



setwd("D:/home/a-m/kevinxie/Mask_RCNN/datasets/old")
raw_list = Sys.glob(paste("*","tif",sep=""))

for(i in 1:length(raw_list)){
  
  ningxia = raster(raw_list[i])
  
  if (ningxia@file@nbands == 2){
    band1 <- raster(raw_list[i], band = 1)
    band2 <- raster(raw_list[i], band = 2)
    band3 <- raster(raw_list[i], band = 2)
    
    rgbRaster <- stack(band1,band2,band3)
    #orderRGBstack <- stack(rgbRaster[[1]], rgbRaster[[4]], rgbRaster[[7]])
    image_to_save_name = file.path(paste("../raw_processed/",raw_list[i], sep = ""))
    options=c("PROFILE=BASELINE")
    #writeRaster(orderRGBstack, image_to_save_name, "GTiff", overwrite=TRUE ,datatype="INT1U" )
    writeRaster(rgbRaster, image_to_save_name, "GTiff", overwrite=TRUE ,datatype="INT1U" )
  }else if(ningxia@file@nbands == 4){
    band1 <- raster(raw_list[i], band = 1)
    band2 <- raster(raw_list[i], band = 2)
    band3 <- raster(raw_list[i], band = 3)
    
    rgbRaster <- stack(band1,band2,band3)
    #orderRGBstack <- stack(rgbRaster[[1]], rgbRaster[[4]], rgbRaster[[7]])
    image_to_save_name = file.path(paste("../raw_processed/",raw_list[i], sep = ""))
    options=c("PROFILE=BASELINE")
    #writeRaster(orderRGBstack, image_to_save_name, "GTiff", overwrite=TRUE ,datatype="INT1U" )
    writeRaster(rgbRaster, image_to_save_name, "GTiff", overwrite=TRUE ,datatype="INT1U" )
  }else{
    print(paste("check bands of", raw_list[i]))
  }

}





















