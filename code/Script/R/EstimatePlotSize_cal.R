library(rjson)
library(sf)

source(file.path(code_dir, "JsonCleanSort_V1.R"))

# root = "D:/temp/root"
# Project_name = "MockProject"
# Flight_name = "flight1"
# ROI_name = "ROI1"

PlotSizeCalculation = function(result_image_dir){

  scale_list = list.dirs(result_image_dir, recursive = F)
  scale_list = gsub(paste0(result_image_dir, "/"), "", scale_list)
  
  W_list = c()
  H_list = c()
  poly_list = st_sfc()
  instance_number_record = as.data.frame(matrix(nrow = 0, ncol = 2))
  for(i in 1:length(scale_list)){
    this_scale_dir = file.path(result_image_dir, scale_list[i])
    json_path = file.path(this_scale_dir, "predict.json")
    
    # not performing pixel upscale here
    output = JsonCleanSort(json_readin = json_path, pixel_upscale = 1, stitch_coordinates = FALSE) 
    if(length(output) == 0) next
    
    raw_polygon_list = output[[1]]
    raw_polygon_list_name = output[[2]]
    
    instance_count = 0
    for(j in 1:length(raw_polygon_list)){
      
      poly_coor = st_coordinates(raw_polygon_list[j])[, 1:2]
      
      x = poly_coor[, 1]
      y = poly_coor[, 2]
      if(any(x < 1) | any(x >1023) | any(y < 1) | any(y >1023)) next
      
      poly_coor = poly_coor * as.numeric(scale_list[i]) / 1024
      
      W = max(poly_coor[, 1]) - min(poly_coor[, 1])
      H = max(poly_coor[, 2]) - min(poly_coor[, 2])
      
      W_list = c(W_list, W)
      H_list = c(H_list, H)
      
      instance_count = instance_count + 1
      
      # top = paste(head(poly_coor, 1)[1], head(poly_coor, 1)[2], sep = "_")
      # bottom = paste(tail(poly_coor, 1)[1], tail(poly_coor, 1)[2], sep = "_")
      # 
      # if(top != bottom){
      #   poly_coor = rbind(poly_coor, poly_coor[1, ])
      # }
      # pol = st_polygon(list(poly_coor))
      # pol = st_sfc(pol)
      # poly_list = c(poly_list, pol)
      
    }
    instance_number_record = rbind(instance_number_record, c(as.numeric(scale_list[i]), instance_count))
    
  }
  
  # estimate plot size
  W_hist = hist(W_list, breaks = 200)
  H_hist = hist(H_list, breaks = 200)
  
  est_W = W_hist$breaks[which(W_hist$density == max(W_hist$density))]
  est_H = H_hist$breaks[which(H_hist$density == max(H_hist$density))]
  long_side = max(est_W, est_H)
  
  # evaluate instance number for each scale
  names(instance_number_record) = c("scale", "count")
  instance_number_record$standardized_count = instance_number_record$count * 1024 / instance_number_record$scale
  instance_number_record = instance_number_record[order(instance_number_record$standardized_count, decreasing = TRUE), ]
  instance_number_record = instance_number_record[1:((nrow(instance_number_record))/3), ]
  
  
  candidate_side = instance_number_record$scale
  diff = abs(candidate_side - long_side * 2)
  est_crop_side = candidate_side[which(diff == min(diff))]
  
  print(paste0("Estimated crop size: ", est_crop_side))
  return(est_crop_side)
}















