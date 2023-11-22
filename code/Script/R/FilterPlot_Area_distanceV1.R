

FilterPlots = function(input_polygon_list, input_polygon_list_name){
  
  remove_poly_name_list = c()
  # filter based on size
  filtered1_stitched_polygon_list = input_polygon_list
  filtered1_stitched_polygon_list_name = input_polygon_list_name
  
  area_list = st_area(filtered1_stitched_polygon_list)
  if(length(area_list) > 1){
    out_flag = TRUE
    while(out_flag == TRUE){
      out_flag = FALSE
      test = grubbs.test(area_list)
      if(test$p.value < 0.05){
        out_flag = TRUE
        remove_index = which(area_list == max(area_list))
        remove_poly_name_list = c(remove_poly_name_list,  filtered1_stitched_polygon_list_name[remove_index])
        print(paste0("Filter SIZE: remove polygon ", filtered1_stitched_polygon_list_name[remove_index]))
        filtered1_stitched_polygon_list = filtered1_stitched_polygon_list[-remove_index]
        filtered1_stitched_polygon_list_name = filtered1_stitched_polygon_list_name[-remove_index]
        area_list = st_area(filtered1_stitched_polygon_list)
        next
      }
      test = grubbs.test(area_list, opposite = TRUE)
      if(test$p.value < 0.05){
        out_flag = TRUE
        remove_index = which(area_list == min(area_list))
        remove_poly_name_list = c(remove_poly_name_list,  filtered1_stitched_polygon_list_name[remove_index])
        print(paste0("Filter SIZE: remove polygon ", filtered1_stitched_polygon_list_name[remove_index]))
        filtered1_stitched_polygon_list = filtered1_stitched_polygon_list[-remove_index]
        filtered1_stitched_polygon_list_name = filtered1_stitched_polygon_list_name[-remove_index]
        area_list = st_area(filtered1_stitched_polygon_list)
        next
      }
    }
  }
  
  
  # filter based on distance distribution
  filtered2_stitched_polygon_list = filtered1_stitched_polygon_list
  filtered2_stitched_polygon_list_name = filtered1_stitched_polygon_list_name
  
  dis_dt = as.data.frame(st_distance(filtered2_stitched_polygon_list, filtered2_stitched_polygon_list))
  dis_p_value = c()
  for(i in 1:length(filtered2_stitched_polygon_list)){
    dis = dis_dt[, i][-i]
    test = shapiro.test(dis)
    dis_p_value = c(dis_p_value, test$p.value)
  }
  
  # i = 469
  # hist(dis_dt[, i][-i])
  # shapiro.test(dis_dt[, i][-i])$p.value
  
  remove_index = which(dis_p_value > 0.05) # tune this value
  remove_poly_name_list = c(remove_poly_name_list,  filtered2_stitched_polygon_list_name[remove_index])
  print(paste0("Filter Distance Distribution: remove polygon ", filtered2_stitched_polygon_list_name[remove_index]))
  
  if( length(remove_index) != 0 ){
    filtered2_stitched_polygon_list = filtered2_stitched_polygon_list[-remove_index]
    filtered2_stitched_polygon_list_name = filtered2_stitched_polygon_list_name[-remove_index]
  }
  
  
  # filter out polys with far away centroid
  
  filtered3_stitched_polygon_list = filtered2_stitched_polygon_list
  filtered3_stitched_polygon_list_name = filtered2_stitched_polygon_list_name
  
  point_dis_dt = as.data.frame(st_distance(st_centroid(filtered3_stitched_polygon_list), st_centroid(filtered3_stitched_polygon_list)))
  head5mean = c()
  for(i in 1:length(filtered3_stitched_polygon_list)){
    point_dis = sort(point_dis_dt[, i][-i])
    head5mean = c(head5mean, mean(head(point_dis)))
  }
  
  if(length(head5mean) > 1){
    out_flag = TRUE
    while(out_flag == TRUE){
      out_flag = FALSE
      test = grubbs.test(head5mean)
      if(test$p.value < 0.05){
        out_flag = TRUE
        remove_index = which(head5mean == max(head5mean))
        remove_poly_name_list = c(remove_poly_name_list,  filtered3_stitched_polygon_list_name[remove_index])
        print(paste0("remove polygon ", filtered3_stitched_polygon_list_name[remove_index]))
        head5mean = head5mean[-remove_index]
        filtered3_stitched_polygon_list = filtered3_stitched_polygon_list[-remove_index]
        filtered3_stitched_polygon_list_name = filtered3_stitched_polygon_list_name[-remove_index]
      }
    }
  }
  
  print(paste0("Following polygons were removed: ", remove_poly_name_list))
  
  return(list(filtered3_stitched_polygon_list, filtered3_stitched_polygon_list_name))
}

















