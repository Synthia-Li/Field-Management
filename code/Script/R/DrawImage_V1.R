
# read in detection results and draw image

Draw_Polygon_On_Individual_Images <- function(draw_poly_list, draw_poly_name_list, cropped_image_dir, output_dir, annotation = FALSE) {
  
  #setwd(cropped_image_dir)
  cropped_image_list = Sys.glob(file.path(cropped_image_dir, paste("*","png",sep="")))
  cropped_image_list = gsub(paste0(cropped_image_dir,"/"), "", cropped_image_list)
  
  image_index_list = c()
  tem = str_split(draw_poly_name_list, "_")
  for(i in 1:length(tem)){
    image_index_list = c(image_index_list, as.numeric(tem[[i]][1]))
  }
  
  
  pb <- progress_bar$new(format = " #### Drawing on Individual Images ####  [:bar] :percent   ETA: :eta",
                         total = length(cropped_image_list),
                         complete = "=",   # Completion bar character
                         incomplete = "-", # Incomplete bar character
                         current = ">",    # Current bar character
                         clear = FALSE,    # If TRUE, clears the bar when finish
                         width = 100)      # Width of the progress bar
  
  
  
  for(a in 1:length(cropped_image_list)){
    
    pb$tick()
    
    tem = strsplit(cropped_image_list[a], split = "\\.")[[1]]
    tem = tem[length(tem)-1]
    
    tem2 = regmatches(tem, gregexpr("(?<=\\().*?(?=\\))", tem, perl=T))[[1]]
    tem2 = tem2[length(tem2)]
    
    tem3 = strsplit(tem2, split = "[[:punct:]]")[[1]]
    
    this_image_index = as.numeric(tem3[10])
    
    if(this_image_index %in% image_index_list){
      pick = which(image_index_list %in% this_image_index )
      to_draw = draw_poly_list[pick]
      
      color_list = randomColor(length(to_draw), luminosity="light")
      #image_name = file.path(whole_image_dir, tif_file)
      image = image_read(file.path(cropped_image_dir,cropped_image_list[a]))
      img <- image_draw(image)
      
      for(i in 1:length(to_draw)){
        x_draw = st_coordinates(to_draw[i])[,1]
        y_draw = st_coordinates(to_draw[i])[,2]
        
        if(length(x_draw) < 4) stop(i)
        
        polygon(x_draw, y_draw, col=NA, border=color_list[i], lwd = 5)
        
        centroid_x = st_coordinates(st_centroid(to_draw[i]))[1]
        centroid_y = st_coordinates(st_centroid(to_draw[i]))[2]
        
        if(annotation == TRUE) text(centroid_x, centroid_y, draw_poly_name_list[pick[i]], col="red", cex=5)
      }
      dev.off()
      write_path = file.path(output_dir, cropped_image_list[a])
      image_write(img, write_path, format = "png")
    }
    #print(paste0("Finish drawing ", cropped_image_list[a], "-----", a, "/", length(cropped_image_list)))
  }
}



## draw image
Draw_Polygon_On_Stiched_Image <- function(image_name, poly_draw_list, poly_name_list, write_path, annotation = FALSE) {
  #image_name = file.path(whole_image_dir, tif_file)
  print("Reading Image")
  
  image = image_read(image_name)
  image = image[as.numeric(1)]
  img <- image_draw(image)
  
  
  pb <- progress_bar$new(format = " #### Drawing on Stitched Image ####  [:bar] :percent   ETA: :eta",
                         total = length(poly_draw_list),
                         complete = "=",   # Completion bar character
                         incomplete = "-", # Incomplete bar character
                         current = ">",    # Current bar character
                         clear = FALSE,    # If TRUE, clears the bar when finish
                         width = 100)      # Width of the progress bar
  
  
  for(i in 1:length(poly_draw_list)){
    
    pb$tick()
    
    x_draw = st_coordinates(poly_draw_list[i])[,1]
    y_draw = st_coordinates(poly_draw_list[i])[,2]
    polygon(x_draw, y_draw, col=NA, border=randomColor(luminosity="light"), lwd = 10)
    
    centroid_x = st_coordinates(st_centroid(poly_draw_list[i]))[1]
    centroid_y = st_coordinates(st_centroid(poly_draw_list[i]))[2]
    if(annotation == TRUE) text(centroid_x, centroid_y, poly_name_list[i], col="red", cex=10)
    
    #print(paste0(i, "th image drawn"))
  }
  dev.off()
  
  print("Writing Image")
  image_write(img, write_path, format = "png")
  
}





















