library(progress)

JsonCleanSort = function(json_readin, pixel_upscale=1.0, stitch_coordinates){
  

  # read in detection results and draw image
  detect_result = fromJSON(file = json_readin)
  zero_instance_image = detect_result$images_with_no_detections
  image_result = detect_result$detections
  
  if(length(image_result) == 0) return(NULL)
  
  image_detection_list = names(image_result)
  image_result_adjusted = image_result
  
  raw_polygon_list = st_sfc()
  raw_polygon_list_name = c()
  
  
  
  pb <- progress_bar$new(format = " #### Cleaning Individual Image ####  [:bar] :percent   ETA: :eta",
                         total = length(image_detection_list),
                         complete = "=",   # Completion bar character
                         incomplete = "-", # Incomplete bar character
                         current = ">",    # Current bar character
                         clear = FALSE,    # If TRUE, clears the bar when finish
                         width = 100)      # Width of the progress bar
  
  
  for(i in 1:length(image_detection_list)){
    
    #pb$tick()
    
    tem = strsplit(image_detection_list[i], split = "\\.")[[1]]
    tem = tem[length(tem)-1]
    
    tem2 = regmatches(tem, gregexpr("(?<=\\().*?(?=\\))", tem, perl=T))[[1]]
    tem2 = tem2[length(tem2)]
    
    tem3 = strsplit(tem2, split = "[[:punct:]]")[[1]]
    
    x0 = as.numeric(tem3[2])
    y0 = as.numeric(tem3[6])
    
    image_index = as.numeric(tem3[10])
    
    
    image_raw_polygon_list = st_sfc()
    image_raw_polygon_list_name = c()
    for(j in 1:length(image_result_adjusted[[i]])){
      if( !length(image_result_adjusted[[i]][[j]]$x) == length(image_result_adjusted[[i]][[j]]$y)) stop("ERROR - polygon length unequal")
      
      # skip instances with confidence smaller than 0.1
      if(image_result_adjusted[[i]][[j]]$confidence < 0.1) next
      
      if( length(image_result_adjusted[[i]][[j]]$x) > 2 ) {
        if(stitch_coordinates){
          image_result_adjusted[[i]][[j]]$x = image_result_adjusted[[i]][[j]]$x * pixel_upscale + x0
          image_result_adjusted[[i]][[j]]$y = image_result_adjusted[[i]][[j]]$y * pixel_upscale + y0
        }
        
        #check if polygons are closed
        last_item = length(image_result_adjusted[[i]][[j]]$x)
        if( !( (image_result_adjusted[[i]][[j]]$x[1] == image_result_adjusted[[i]][[j]]$x[last_item]) &
               (image_result_adjusted[[i]][[j]]$y[1] == image_result_adjusted[[i]][[j]]$y[last_item]) ) ){
          image_result_adjusted[[i]][[j]]$x = c(image_result_adjusted[[i]][[j]]$x, image_result_adjusted[[i]][[j]]$x[1])
          image_result_adjusted[[i]][[j]]$y = c(image_result_adjusted[[i]][[j]]$y, image_result_adjusted[[i]][[j]]$y[1])
        }
        
        pol = st_polygon(list(cbind(image_result_adjusted[[i]][[j]]$x, image_result_adjusted[[i]][[j]]$y)))
        pol = st_make_valid(st_sfc(pol))
        
        image_raw_polygon_list = c(image_raw_polygon_list, pol)
        image_raw_polygon_list_name = c(image_raw_polygon_list_name, paste(image_index, j, sep = "_"))
        # raw_polygon_list = c(raw_polygon_list, pol)
        # raw_polygon_list_name = c(raw_polygon_list_name, names(image_result_adjusted)[i])
        # 
      }
    }
    
    
    
    if(length(image_raw_polygon_list) > 1){
      
      # merge overlapping polygons if any
      overlapping_list = list()
      for (p in 2:length(image_raw_polygon_list)){
        for (q in (1):(p-1)){
          if(length(st_intersection(image_raw_polygon_list[p], 
                                    image_raw_polygon_list[q])) == 0) next
          
          inter_area = st_area(st_intersection(image_raw_polygon_list[p], image_raw_polygon_list[q]))
          
          inter_p_percent = inter_area/st_area(image_raw_polygon_list[p])
          inter_q_percent = inter_area/st_area(image_raw_polygon_list[q])
          
          #print(paste0(inter_p_percent, "/",inter_q_percent))
          
          
          if(inter_p_percent > 0.9 | inter_q_percent > 0.9){  # tune hyperparameter 0.9 
            add_tag = 1
            if(length(overlapping_list)>0){
              for(m in 1:length(overlapping_list)){
                if(p %in% overlapping_list[[m]]){
                  overlapping_list[[m]] = c(overlapping_list[[m]], q)
                  overlapping_list[[m]] = unique(overlapping_list[[m]])
                  add_tag = 0
                } 
                if(q %in% overlapping_list[[m]]){
                  overlapping_list[[m]] = c(overlapping_list[[m]], p)
                  overlapping_list[[m]] = unique(overlapping_list[[m]])
                  add_tag = 0
                } 
              }
            }
            if(add_tag == 1){
              overlapping_list = c(overlapping_list, list(c(p, q )))
            }
          }
        }
      }
      
      
      # merge overlapping list to be tested
      fresh = TRUE
      while(fresh == TRUE & (length(overlapping_list) > 1)){
        fresh = FALSE
        for(m in 1:(length(overlapping_list)-1)){
          for(n in (m+1):length(overlapping_list)){
            tem = intersect(overlapping_list[[m]], overlapping_list[[n]])
            if(length(tem) > 0){
              fresh = TRUE
              break
            }
          }
          if(fresh == TRUE) break
        }
        
        if(fresh == TRUE){
          merge_merge_list = unique(c(overlapping_list[[m]], overlapping_list[[n]]))
          overlapping_list = overlapping_list[-c(m, n)]
          overlapping_list = c(overlapping_list, list(merge_merge_list))
        }
      }
      
      
      if(length(overlapping_list) != 0){
        #print(paste0(image_detection_list[i], " overlapping"))
        #print(overlapping_list)
        
        remove_poly_name= c()
        merged_poly_to_add = st_sfc()
        merged_poly_name_to_add = c()
        for(m in 1:length(overlapping_list)){
          merging_polys = st_sfc()
          for(n in 1:length(overlapping_list[[m]])){
            merging_polys = c(merging_polys, image_raw_polygon_list[overlapping_list[[m]][n]])
            remove_poly_name = c(remove_poly_name, overlapping_list[[m]][n])
          }
          
          merging_polys = st_union(merging_polys)
          merged_poly_to_add = c(merged_poly_to_add, merging_polys)
          merged_poly_name_to_add = c(merged_poly_name_to_add, paste(image_index, m , "o",  sep = "_"))
        }
        image_raw_polygon_list = image_raw_polygon_list[-remove_poly_name]
        image_raw_polygon_list = c(image_raw_polygon_list, merged_poly_to_add)
        
        image_raw_polygon_list_name = image_raw_polygon_list_name[-remove_poly_name]
        image_raw_polygon_list_name = c(image_raw_polygon_list_name, merged_poly_name_to_add)
      }
    }
    
    raw_polygon_list = c(raw_polygon_list, image_raw_polygon_list)
    raw_polygon_list_name = c(raw_polygon_list_name, image_raw_polygon_list_name )
    
    
    # remove wield detections
    for(check_valid_index in 1:length(raw_polygon_list)){
      if(! st_is_valid(raw_polygon_list[check_valid_index])){
        print(check_valid_index)
        raw_polygon_list = raw_polygon_list[-check_valid_index]
        raw_polygon_list_name = raw_polygon_list_name[-check_valid_index]
      }
    }
    
    # remove wield detections
    for(check_valid_index in 1:length(raw_polygon_list)){
      if(  st_geometry_type(raw_polygon_list[check_valid_index]) != "POLYGON" ){
        #print(check_valid_index)
        raw_polygon_list = raw_polygon_list[-check_valid_index]
        raw_polygon_list_name = raw_polygon_list_name[-check_valid_index]
      }
    }
    
    
    
  }
  print(paste0("Raw polygon instance predictions had ", length(raw_polygon_list), " polygons"))
  return(list(raw_polygon_list, raw_polygon_list_name))
}
