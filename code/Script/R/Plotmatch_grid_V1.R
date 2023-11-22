
plotmatch_grid = function(filtered_stitched_polygon_list, plot_dt){
  
  row_n = dim(plot_dt)[1]
  col_n = dim(plot_dt)[2]
  
  centroid = st_centroid(filtered_stitched_polygon_list)
  
  angle_list = c()
  for(i in 1:length(centroid)){
    dis_list = st_distance(centroid[i], centroid)
    p1 = st_coordinates(centroid[i])
    p2 = st_coordinates(centroid[order(dis_list)[2]])
    ang = atan((p1[2]-p2[2])/(p1[1]-p2[1]))*180/pi
    angle_list = c(angle_list, ang)
    
  }
  
  hist_vec = hist(angle_list, breaks=100)
  frequency <- hist_vec$counts 
  
  pick1 = abs(angle_list - hist_vec$breaks[frequency == max(frequency)][1]) < 10
  pick2 = abs(angle_list - hist_vec$breaks[frequency == max(frequency)][2]) < 10
  pick = pick1 | pick2
  angle_pick = angle_list[pick]
  if(median(angle_pick) < -70 | median(angle_pick) > 70){
    a = angle_pick[which(angle_pick>0)]-90
    b = angle_pick[which(angle_pick<0)]+90
    angle_output = c(a, b)
    ang_r = mean(angle_output)
  }else if(median(angle_pick) < 20 | median(angle_pick) > -20){ # to be fixed horizontal
    ang_r = mean(angle_pick)
  }
  
  c_df = as.data.frame(st_coordinates(filtered_stitched_polygon_list))[,c(1,2)]
  coords <- as.matrix(c_df)
  rcoords <- rotate(coords, -ang_r/180*pi)  # 2 is the rotation angle
  #plot(rcoords)
  rcoords = as.data.frame(rcoords)
  names(rcoords) = c("X", "Y")
  points = st_as_sf(rcoords, coords = c('X', 'Y'))
  
  # make grid
  plot_pixel_coor = st_coordinates(st_make_grid(points, n = c(col_n, row_n), what = "centers"))[, c(1,2)]
  col_list = unique(plot_pixel_coor[, 1])
  row_list = unique(plot_pixel_coor[, 2])
  
  plot_name = c()
  for(i in 1:nrow(plot_pixel_coor)){
    this_x = which(col_list == plot_pixel_coor[i, 1])
    this_y = which(row_list == plot_pixel_coor[i, 2])
    this_plot_name = plot_dt[this_y, this_x]
    plot_name = c(plot_name, this_plot_name)
    #print(i)
  }
  
  plot_pixel_coor_r = as.data.frame(rotate(plot_pixel_coor, ang_r/180*pi))
  names(plot_pixel_coor_r) = c("X", "Y")
  
  plot_pixel_coor_r_name = cbind(plot_pixel_coor_r, plot_name)
  
  return(plot_pixel_coor_r_name)
}





























