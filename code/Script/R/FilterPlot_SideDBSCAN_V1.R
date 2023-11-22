library(dbscan)

bbxside_horizontal_vertical = function(input_polygon_list){
  bbox_list = st_sfc()
  horriside_list = c()
  vertside_list = c()
  for(i in 1:length(input_polygon_list)){
    bbx = st_as_sfc(st_bbox(input_polygon_list[i]))
    bbox_list = c(bbox_list, bbx)
    
    bbx_coor = st_coordinates(bbx)
    horriside_list = c(horriside_list, as.numeric(abs(bbx_coor[1,1]-bbx_coor[2,1])))
    vertside_list = c(vertside_list, as.numeric(abs(bbx_coor[2,2]-bbx_coor[3,2])))
  }
  return(list(horriside_list, vertside_list))
}

filter_SideDBSCAN = function(input_polygon_list, input_polygon_list_name, eps){
  side = bbxside_horizontal_vertical(input_polygon_list)
  dt = as.data.frame(cbind(side[[1]], side[[2]]))
  names(dt) = c("horriside_list", "vertside_list")
  
  dbscan_res <- dbscan(dt, eps = eps, minPts = 5)
  
  #plot(dt, col=dbscan_res$cluster+1, main="DBSCAN")
  
  print(paste0("Clusters found: ", length(unique(dbscan_res$cluster))-1))
  
  filtered1_stitched_polygon_list = list()
  filtered1_stitched_polygon_list_name = list()
  for(i in 1:(length(unique(dbscan_res$cluster))-1)){
    
    filtered1_stitched_polygon_list = append(filtered1_stitched_polygon_list, 
                                        list(input_polygon_list[which(dbscan_res$cluster == as.character(i))]) ,after=1)
    
    filtered1_stitched_polygon_list_name = append(filtered1_stitched_polygon_list_name, 
                                                  list(input_polygon_list_name[which(dbscan_res$cluster == i)]) ,after=1)
    
  }
  
  # filtered1_stitched_polygon_list = list(input_polygon_list[which(dbscan_res$cluster == 1)])
  # filtered1_stitched_polygon_list_name = input_polygon_list_name[which(dbscan_res$cluster == 1)]
  # 
  # plot(input_polygon_list)
  # plot(filtered1_stitched_polygon_list)
  return(list(filtered1_stitched_polygon_list, filtered1_stitched_polygon_list_name))
}


















