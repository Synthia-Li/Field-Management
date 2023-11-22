

## crop image
center_based_crop = function(read_in_table, read_in_image, crop_w, crop_h, ortho_name, short_name, to_save_dir){
  
# read in table example
  #   column row plot_name                x_coor                 y_coor   note
  # 1      1   1     V1-R1 1416.8743407532158471  878.71965401408033358       
  # 2      1   2     HD001 1269.9008666963409269 2087.86153805870344513       
  # 3      1   3     V3-R1 1320.6219547409530151 3338.69268529917144406       
  # 4      1   4     HD002 1353.1064611388842422 4544.58291915985773812 filled
  # 5      1   5     HD003 1343.3643708794686518 5818.90103229654869210 filled
  # 6      1   6     HD004 1333.6484316445246350 7089.79844994879567821 filled
  
  
  image = image_read(read_in_image)
  print(paste0("############## NOW cropping  ---- ", image_name, " ##############"))
  
  print("Raw image info:")
  info = image_info(image)
  print(info)
  
  for(i in 1:nrow(read_in_table)){
    
    xx = read_in_table$x_coor[i]
    yy = read_in_table$y_coor[i]
    image_to_save = image_crop(image, paste(crop_w,"x",crop_h,"+",xx-crop_w/2,"+",yy-crop_h/2,sep="")) #width/height/x/y
    image_to_save_name = paste("[", gsub("_", "", short_name), "_", i, "]", "_",
                               "[", gsub(".tif", "", ortho_name), "]", "_",
                               "[", "col", read_in_table$column[i], 
                               "row", read_in_table$row[i], "]", "_",
                               "[", read_in_table$plot_name[i], "]", 
                               ".png", sep = "" )
    
    image_write(image_to_save, file.path(to_save_dir, image_to_save_name), format = "png")
    
  }
  
}



