### optimized algorism to get x_pre and y_pre


library(ClusterR)
library(smatr)
library(dbscan)


plotmatch_VerCrossHori = function(filtered_stitched_polygon_list, filtered_stitched_polygon_list_name, plot_dt ){
  
  row_n = dim(plot_dt)[1]
  col_n = dim(plot_dt)[2]
  
  centroid = st_centroid(filtered_stitched_polygon_list)
  
  ### fine tune angle
  angle_list = c()
  for(i in 1:length(centroid)){
    dis_list = st_distance(centroid[i], centroid)
    p1 = st_coordinates(centroid[i])
    p2 = st_coordinates(centroid[order(dis_list)[2]])
    ang = atan((p1[2]-p2[2])/(p1[1]-p2[1]))*180/pi
    angle_list = c(angle_list, ang)
    
  }
  
  hist_vec = hist(angle_list, breaks=length(angle_list)/2, plot = FALSE)
  frequency = hist_vec$counts
  
  hist_vec$breaks[frequency == max(frequency)]
  
  
  angle_list_m = c(angle_list[which(angle_list < 0)] + 180, angle_list[which(angle_list > 0)])
  hist_vec = hist(angle_list_m, breaks=180, plot = FALSE)
  frequency = hist_vec$counts 
  
  max_frequency_index = which(frequency == max(frequency))[1]
  to_include_index = c()
  
  this_index = max_frequency_index
  while( frequency[this_index] > 0   ){
    to_include_index = c(to_include_index, this_index)
    this_index = this_index - 1
  }
  this_index = max_frequency_index + 1
  while( frequency[this_index] > 0   ){
    to_include_index = c(to_include_index, this_index)
    this_index = this_index + 1
  }
  
  angle_list_m[]
  
  pick1 = hist_vec$mids[min(to_include_index)-1] < angle_list_m
  pick2 = angle_list_m < hist_vec$mids[max(to_include_index)+1] 
  
  pick = pick1 & pick2
  ang_r = median(angle_list_m[pick]) - 90
  
  print(paste0("fine tuning rotation angle: ", ang_r))

  
  ### rotate centroid and polys
  c_df = as.data.frame(st_coordinates(centroid))
  coords <- as.matrix(c_df)
  rcoords <- rotate(coords, -ang_r/180*pi)  # 2 is the rotation angle
  #plot(rcoords)
  rcoords = as.data.frame(rcoords)
  names(rcoords) = c("X", "Y")
  points = st_as_sf(rcoords, coords = c('X', 'Y'))
  
  ### calculate plot size median
  plot_w_r_list = c()
  plot_h_r_list = c()
  for(j in 1:length(filtered_stitched_polygon_list)){
    poly_boundary_coor = st_coordinates(filtered_stitched_polygon_list[j])[,1:2]
    poly_boundary_coor_r = rotate(poly_boundary_coor, -ang_r/180*pi)
    plot_w = max(poly_boundary_coor_r[,1]) - min(poly_boundary_coor_r[,1])
    plot_h = max(poly_boundary_coor_r[,2]) - min(poly_boundary_coor_r[,2])
    plot_w_r_list = c(plot_w_r_list, plot_w)
    plot_h_r_list = c(plot_h_r_list, plot_h)
  }
  
  median_plot_w_r = median(plot_w_r_list)
  median_plot_h_r = median(plot_h_r_list)
  
  
  ### cluster X and Y value into nrow or ncol classes
  #x
  output = get_seq(rcoords$X, col_n)
  x_seq = output[[1]]
  x_mean_list = output[[2]]
  
  #y
  output = get_seq(rcoords$Y, row_n)
  y_seq = output[[1]]
  y_mean_list = output[[2]]
  

  # plot(x_seq, y_seq)
  # text(x_seq, y_seq, rownames(rcoords))

  
  x_y_tag = paste(x_seq, y_seq, sep = "_")
  plot_grid_output = as.data.frame(matrix(ncol = 6, nrow = 0))
  poly_filled_list = st_sfc()
  poly_filled_list_name = c()
  
  h_waiting_list = c()
  v_waiting_list = c()
  h_coefficient_list = c()
  v_coefficient_list = c()
  
  for(n in 1:col_n){
    for(m in 1:row_n){

      if(is.na(plot_dt[m, n])) next
      if(paste(n, m, sep="_") %in% x_y_tag){
        
        ### add coordinates
        index = which(x_y_tag == paste(n, m, sep="_"))
        to_add = c(n, m, plot_dt[m, n], rcoords$X[index], rcoords$Y[index], "")
        plot_grid_output = rbind(plot_grid_output, to_add)
        
        ### add poly
        # pol = filtered_stitched_polygon_list[index]
        # poly_filled_list = c(poly_filled_list, pol)
        
        
        corner_p_r = rbind(c(rcoords$X[index] - median_plot_w_r/2, rcoords$Y[index] + median_plot_h_r/2),  
                           c(rcoords$X[index] + median_plot_w_r/2, rcoords$Y[index] + median_plot_h_r/2), 
                           c(rcoords$X[index] + median_plot_w_r/2, rcoords$Y[index] - median_plot_h_r/2),
                           c(rcoords$X[index] - median_plot_w_r/2, rcoords$Y[index] - median_plot_h_r/2),
                           c(rcoords$X[index] - median_plot_w_r/2, rcoords$Y[index] + median_plot_h_r/2))
        corner_p <- rotate(corner_p_r, ang_r/180*pi)
        pol = st_polygon(list(corner_p))
        pol = st_sfc(pol)
        poly_filled_list = c(poly_filled_list, pol)
        poly_filled_list_name = c(poly_filled_list_name, filtered_stitched_polygon_list_name[index])
        
      }else{
        
        #print(paste(n, m, sep="_"))
        
        h_line = rcoords[which(y_seq == m), ]
        v_line = rcoords[which(x_seq == n), ]
        
        if(nrow(h_line) < 3){
          h_waiting_list = c(h_waiting_list, m)
          next
        } 
        
        if(nrow(v_line) < 3){
          v_waiting_list = c(v_waiting_list, n)
          next
        } 
        
        
        
        # tolerance
        dbscan_res <- dbscan(matrix(h_line$Y, ncol = 1), eps = median_plot_h_r/3, minPts = nrow(h_line)/2)
        #plot(h_line, col=dbscan_res$cluster+1, main="DBSCAN")
        if(any(dbscan_res$cluster==0)) h_line = h_line[-which(dbscan_res$cluster==0), ]
        
        dbscan_res <- dbscan(matrix(v_line$X, ncol = 1), eps = median_plot_w_r/3, minPts = nrow(v_line)/2)
        #plot(v_line, col=dbscan_res$cluster+1, main="DBSCAN")
        if(any(dbscan_res$cluster==0)) v_line = v_line[-which(dbscan_res$cluster==0), ]

        
        ###
        h_model <- sma(Y ~ X, data=h_line)
        plot(h_line$X, h_line$Y, xlim=c(0,10000), ylim=c(0,16000))
        #abline(h_model$coef[[1]]$`coef(SMA)`[1], h_model$coef[[1]]$`coef(SMA)`[2]  )
        
        a1 = h_model$coef[[1]]$`coef(SMA)`[2]
        b1 = h_model$coef[[1]]$`coef(SMA)`[1]
        
        h_coefficient_list = c(h_coefficient_list, a1)
        
        ###
        v_model <- sma(Y ~ X, data=v_line)
        plot(v_line$X, v_line$Y, xlim=c(0,10000), ylim=c(0,16000))
        #abline(-178820.07794638501946, 258.98122571960311689   )
        
        a2 = v_model$coef[[1]]$`coef(SMA)`[2]
        b2 = v_model$coef[[1]]$`coef(SMA)`[1]
        
        v_coefficient_list = c(v_coefficient_list, a2)
        
        # sovle for point coordinate
        lf = matrix(c(-a1/b1, 1/b1,
                      -a2/b2, 1/b2), nrow=2, byrow=TRUE)
        rf = matrix(c(1,1), nrow=2)
        result<-solve(lf,rf)
        x_pre = as.numeric(result[1])
        y_pre = as.numeric(result[2])
        

        ### add coordinates
        to_add = c(n, m, plot_dt[m, n], x_pre, y_pre, "filled")
        plot_grid_output = rbind(plot_grid_output, to_add)
        
        ### add poly
        corner_p_r = rbind(c(x_pre - median_plot_w_r/2, y_pre + median_plot_h_r/2),  
                           c(x_pre + median_plot_w_r/2, y_pre + median_plot_h_r/2), 
                           c(x_pre + median_plot_w_r/2, y_pre - median_plot_h_r/2),
                           c(x_pre - median_plot_w_r/2, y_pre - median_plot_h_r/2),
                           c(x_pre - median_plot_w_r/2, y_pre + median_plot_h_r/2))
        corner_p <- rotate(corner_p_r, ang_r/180*pi)
        pol = st_polygon(list(corner_p))
        pol = st_sfc(pol)
        poly_filled_list = c(poly_filled_list, pol)
        poly_filled_list_name = c(poly_filled_list_name, paste("f", paste0("col",n,"row",m), sep = "_"))
        
        
      }
    }
    #plot(poly_filled_list)
    #var = readline()
    
  }
  names(plot_grid_output) = c("column", "row", "plot_name", "x_coor", "y_coor", "note")
  
  plot_grid_output$column = as.numeric(plot_grid_output$column)
  plot_grid_output$row = as.numeric(plot_grid_output$row)
  plot_grid_output$x_coor = as.numeric(plot_grid_output$x_coor)
  plot_grid_output$y_coor = as.numeric(plot_grid_output$y_coor)
  
  ### rotate coordinaes back
  xy_coor <- as.matrix(plot_grid_output[,c("x_coor", "y_coor")])
  xy_coor_r <- rotate(xy_coor, ang_r/180*pi)
  plot_grid_output$x_coor = xy_coor_r[,1]
  plot_grid_output$y_coor = xy_coor_r[,2]
  
  return(list(plot_grid_output, poly_filled_list, poly_filled_list_name))

  
  # draw_sf = st_sfc()
  # draw_sf = c(draw_sf, poly_filled_list)
  # centroid_filled = st_centroid(poly_filled_list)
  # draw_sf = c(draw_sf, centroid_filled)
  # plot(draw_sf)
  
}




get_seq = function(input_coor, n_cluster){
  model <- dist(input_coor, method = "euclidean")
  fit <- hclust(model, method="ward.D")
  groups <- cutree(fit, k=n_cluster)
  # plot(y_fit)
  # rect.hclust(y_fit, k=row_n, border="red")
  group_list = unique(groups)
  mean_list = c()
  for(g in 1:length(group_list)){
    mean_list = c(mean_list, mean(input_coor[which(groups == group_list[g])]))
    #print(group_list[g])
  }

  order_group = rank(mean_list)
  mean_list = mean_list[order(mean_list)]
  
  

  groups_reorder = rep(0, length(groups))
  for(tem in 1:length(group_list)){
    groups_reorder[which(groups == tem)] = order_group[tem]
  }
  
  seq = c()
  for(i in 1:length(input_coor)){
    seq = c(seq, order_group[which(groups[i] == group_list)])
  }
  
  return(list(seq, mean_list))
}
# 
# 
# library(ggplot2)
# 

# input_coor = rcoords$Y
# n_cluster = row_n
# 
# temtem = as.data.frame(cbind(rcoords$X, rcoords$Y))
# groups_f= as.factor(seq)
# ggplot(temtem, aes(x = temtem[,1], y = temtem[,2], color = groups_f)) + geom_point()
# # 

















