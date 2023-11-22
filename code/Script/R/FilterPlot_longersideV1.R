
bbxside = function(input_polygon_list){
  bbox_list = st_sfc()
  longerside_list = c()
  shorterside_list = c()
  for(i in 1:length(input_polygon_list)){
    bbx = st_as_sfc(st_bbox(input_polygon_list[i]))
    bbox_list = c(bbox_list, bbx)
    
    bbx_coor = st_coordinates(bbx)
    longerside_list = c(longerside_list, max(abs(bbx_coor[1,1]-bbx_coor[2,1]), abs(bbx_coor[2,2]-bbx_coor[3,2]) )) 
    shorterside_list = c(shorterside_list, min(abs(bbx_coor[1,1]-bbx_coor[2,1]), abs(bbx_coor[2,2]-bbx_coor[3,2]) ))
  }
  return(list(longerside_list, shorterside_list))
}




FilterPlots = function(input_polygon_list, input_polygon_list_name){
  
  # filter based on longer side length
  remove_poly_name_list = c()
  filtered1_stitched_polygon_list = input_polygon_list
  filtered1_stitched_polygon_list_name = input_polygon_list_name
  
  longerside_list = bbxside(filtered1_stitched_polygon_list)[[1]]
  if(length(longerside_list) > 1){
    out_flag = TRUE
    while(out_flag == TRUE){
      out_flag = FALSE
      test = grubbs.test(longerside_list, opposite = FALSE, two.sided = FALSE)
      if(test$p.value < 0.01){
        out_flag = TRUE
        
        if(length(grep("highest", test$alternative)) > 0){
          remove_index = which(longerside_list == max(longerside_list))
        } 
        if(length(grep("lowest", test$alternative)) > 0){
          remove_index = which(longerside_list == min(longerside_list))
        } 
        
        remove_poly_name_list = c(remove_poly_name_list,  filtered1_stitched_polygon_list_name[remove_index])
        print(paste0("Filter SIZE: remove polygon ", filtered1_stitched_polygon_list_name[remove_index]))
        filtered1_stitched_polygon_list = filtered1_stitched_polygon_list[-remove_index]
        filtered1_stitched_polygon_list_name = filtered1_stitched_polygon_list_name[-remove_index]
        longerside_list = bbxside(filtered1_stitched_polygon_list)[[1]]
      }
    }
  }
  
  
  side = bbxside(filtered1_stitched_polygon_list)
  
  
  
  
  
  
  dt = as.data.frame(cbind(side[[1]], side[[2]]))
  names(dt) = c("longerside_list", "shorterside_list")
  dt = dt[order(dt$), ]
  
  dt = dt[1:(nrow(dt)-6), ]
  
  

  plot(dt$shorterside_list, dt$longerside_list)

  

  
  
  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  










