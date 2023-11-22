

PolygonStitching = function(raw_image_dir, raw_polygon_list, raw_polygon_list_name, overlap_percentage = 0.8){
  
  # get overlapping crosses
  sub_image_list = Sys.glob(file.path(raw_image_dir, paste("*","png",sep="")))
  sub_image_list = gsub(paste0(raw_image_dir,"/"), "", sub_image_list)
  
  edge_matrix = as.data.frame(matrix(ncol = 5, nrow = 0))
  for (i in 1:length(sub_image_list)){
    #tem = as.numeric(gsub("\\[|\\]", "", regmatches(sub_image_list[i], gregexpr("\\[.*?\\]", sub_image_list[i]))[[1]]))
    
    tem = strsplit(sub_image_list[i], split = "\\.")[[1]]
    tem = tem[length(tem)-1]
    
    tem2 = regmatches(tem, gregexpr("(?<=\\().*?(?=\\))", tem, perl=T))[[1]]
    tem2 = tem2[length(tem2)]
    
    tem3 = strsplit(tem2, split = "[[:punct:]]")[[1]]
    
    edge_matrix = rbind(edge_matrix, c(as.numeric(tem3[2]), as.numeric(tem3[4]), 
                                       as.numeric(tem3[6]), as.numeric(tem3[8]), as.numeric(tem3[10])))
    names(edge_matrix) = c("x0", "x1", "y0", "y1", "n")
  }
  
  x_pair = unique(edge_matrix[, c(1,2)])
  y_pair = unique(edge_matrix[, c(3,4)])
  x_pair = x_pair[order(x_pair[,1]),]
  y_pair = y_pair[order(y_pair[,1]),]
  
  
  cross_list = st_sfc()
  for(i in 1:(nrow(x_pair)-1)){
    for(j in 1:(nrow(y_pair)-1)){
      pol = st_polygon(list(cbind(
        c(x_pair[i, 1], x_pair[i+1, 1], x_pair[i+1, 1], x_pair[i, 2], x_pair[i, 2], x_pair[i+1, 2], 
          x_pair[i+1, 2], x_pair[i, 2], x_pair[i, 2], x_pair[i+1, 1], x_pair[i+1, 1], x_pair[i, 1], x_pair[i, 1]),#X
        
        c(y_pair[j+1, 1], y_pair[j+1, 1], y_pair[j, 1], y_pair[j, 1], y_pair[j+1, 1], y_pair[j+1, 1]
          , y_pair[j, 2], y_pair[j, 2], y_pair[j+1, 2], y_pair[j+1, 2], y_pair[j, 2], y_pair[j, 2], y_pair[j+1, 1]) #Y 
      )))
      pol = st_sfc(pol)
      cross_list = c(cross_list, pol)
    }
  }
  print(paste0("Find ", length(cross_list), " Crosses"))
  
  
  # find polygons overlapping to each cross
  poly_intersection_matrix = as.data.frame(matrix(ncol = 0, nrow = length(cross_list) ))
  
  for(i in 1:length(raw_polygon_list)){
    add_col = st_intersects(cross_list, raw_polygon_list[i], sparse = FALSE)
    poly_intersection_matrix = cbind(poly_intersection_matrix, add_col)
    names(poly_intersection_matrix)[ncol(poly_intersection_matrix)] = raw_polygon_list_name[i]
  }
  dim(poly_intersection_matrix)
  length(raw_polygon_list)
  raw_polygon_list_name = names(poly_intersection_matrix)
  print(paste0("Find ", length(raw_polygon_list_name), " Polygons Overlapping with Crosses"))
  
  
  
  
  pb <- progress_bar$new(format = " #### Merging Polygons In Same Cross ####  [:bar] :percent   ETA: :eta",
                         total = length(cross_list),
                         complete = "=",   # Completion bar character
                         incomplete = "-", # Incomplete bar character
                         current = ">",    # Current bar character
                         clear = FALSE,    # If TRUE, clears the bar when finish
                         width = 100)      # Width of the progress bar
  
  
  
  poly_merge_list = list()
  for(i in 1:length(cross_list)){
    
    pb$tick()
    
    # get poly list that intersects with cross
    cross_poly_index = names(poly_intersection_matrix)[which(poly_intersection_matrix[i,]==TRUE)]
    if(length(cross_poly_index)==0) next
    
    cross_poly_list = raw_polygon_list[which(raw_polygon_list_name %in% cross_poly_index)]
    length(cross_poly_index)
    length(cross_poly_list)
    
    # get poly intersect area with cross
    cross_poly_intersection_list = st_sfc()
    for(k in 1:length(cross_poly_index)){
      cross_poly_intersection_list = c(cross_poly_intersection_list, st_intersection(cross_poly_list[k], cross_list[i]))
    }
    length(cross_poly_intersection_list)
    if(length(cross_poly_intersection_list) < 2) next
    
    # get overlapping poly-intersect-area pairs
    tem = st_intersects(cross_poly_intersection_list, cross_poly_intersection_list, sparse = FALSE)
    p_list = c()
    q_list = c()
    for(p in 1:(nrow(tem)-1)){
      for(q in (p+1):ncol(tem)){
        if(tem[p, q]){
          p_list = c(p_list, p)
          q_list = c(q_list, q)
        }
      }
    }
    if(length(p_list) == 0) next
    
    # get merge polygon pairs if poly-intersect-area pair has high overlapping
    for(l in 1:length(p_list)){
      p_index = p_list[l]
      q_index = q_list[l]
      
      p_name = cross_poly_index[p_index]
      q_name = cross_poly_index[q_index]
      
      pq_inter_area = st_area(st_intersection(cross_poly_intersection_list[p_index], cross_poly_intersection_list[q_index]))
      pq_inter_area_p_percent = pq_inter_area/st_area(cross_poly_intersection_list)[p_index]
      pq_inter_area_q_percent = pq_inter_area/st_area(cross_poly_intersection_list)[q_index]
      
      if(is.na(pq_inter_area_q_percent) | is.na(pq_inter_area_p_percent)) next
      
      if(pq_inter_area_p_percent > overlap_percentage | pq_inter_area_q_percent > overlap_percentage){  # tune hyperparameter 0.6 
        add_tag = 1
        if(length(poly_merge_list)>0){
          for(m in 1:length(poly_merge_list)){
            if(p_name %in% poly_merge_list[[m]]){
              poly_merge_list[[m]] = c(poly_merge_list[[m]], q_name)
              poly_merge_list[[m]] = unique(poly_merge_list[[m]])
              add_tag = 0
            } 
            if(q_name %in% poly_merge_list[[m]]){
              poly_merge_list[[m]] = c(poly_merge_list[[m]], p_name)
              poly_merge_list[[m]] = unique(poly_merge_list[[m]])
              add_tag = 0
            } 
          }
        }
        if(add_tag == 1){
          poly_merge_list = c(poly_merge_list, list(c(p_name, q_name )))
        }
      }
    }
    
    #print(paste0("polygons touching ", i, "th cross recorded"))
  }
  length(poly_merge_list)
  
  
  if(length(poly_merge_list) > 1){
    # merge merge list to be tested
    fresh = TRUE
    while(fresh == TRUE){
      fresh = FALSE
      for(m in 1:(length(poly_merge_list)-1)){
        for(n in (m+1):length(poly_merge_list)){
          tem = intersect(poly_merge_list[[m]], poly_merge_list[[n]])
          if(length(tem) > 0){
            fresh = TRUE
            break
          }
        }
        if(fresh == TRUE) break
      }
      
      if(fresh == TRUE){
        merge_merge_list = unique(c(poly_merge_list[[m]], poly_merge_list[[n]]))
        poly_merge_list = poly_merge_list[-c(m, n)]
        poly_merge_list = c(poly_merge_list, list(merge_merge_list))
      }
    }
  }

  
  # merge polygons
  remove_poly_name= c()
  merged_poly_to_add = st_sfc()
  for(i in 1:length(poly_merge_list)){
    
    merging_polys = st_sfc()
    for(j in 1:length(poly_merge_list[[i]])){
      merging_polys = c(merging_polys, raw_polygon_list[which(raw_polygon_list_name == poly_merge_list[[i]][j])])
      remove_poly_name = c(remove_poly_name, poly_merge_list[[i]][j])
    }
    
    merging_polys = st_union(merging_polys)
    merged_poly_to_add = c(merged_poly_to_add, merging_polys)
  }
  merged_poly_to_add_name = paste("m", 1:length(merged_poly_to_add), sep="_")
  
  print(paste0("Ready to remove ", length(remove_poly_name), " merging polygons"))
  print(paste0("Ready to add ", length(merged_poly_to_add), " merged polygons"))
  
  
  # remove merged polys from big list and add merging polys
  all_poly_list_removed = raw_polygon_list[-which(raw_polygon_list_name %in% remove_poly_name)]
  all_poly_list_name_removed = raw_polygon_list_name[-which(raw_polygon_list_name %in% remove_poly_name)]
  all_poly_list_added = c(all_poly_list_removed, merged_poly_to_add)
  all_poly_list_name_added = c(all_poly_list_name_removed, merged_poly_to_add_name)
  
  if(! length(all_poly_list_added) == length(all_poly_list_name_added)) stop("ERROR")
  print(paste0("After processing ", length(all_poly_list_added), " polygon instances exist"))
  
  
  return(list(all_poly_list_added, all_poly_list_name_added))
}
 





























