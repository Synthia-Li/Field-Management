library(rjson)
library(sf)
source("D:/KC_file/JsonCleanSort_V1.R")

# root = "D:/temp/root"
# Project_name = "MockProject"
# Flight_name = "flight1"
# ROI_name = "ROI1"


scale_list = list.dirs(result_image_dir, recursive = F)
scale_list = gsub(paste0(result_image_dir, "/"), "", scale_list)

W_list = c()
H_list = c()
poly_list = st_sfc()
for(i in 1:length(scale_list)){
  this_scale_dir = file.path(result_image_dir, scale_list[i])
  json_path = file.path(this_scale_dir, "predict.json")
  
  output = JsonCleanSort(json_readin = json_path, stitch_coordinates = FALSE)
  raw_polygon_list = output[[1]]
  raw_polygon_list_name = output[[2]]
  
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
}

W_hist = hist(W_list, breaks = 200)
H_hist = hist(H_list, breaks = 200)

est_W = W_hist$breaks[which(W_hist$density == max(W_hist$density))]
est_H = H_hist$breaks[which(H_hist$density == max(H_hist$density))]
short_side = min(est_W, est_H)

candidate_side = seq(1, 10, 0.5) * 1024
diff = abs(candidate_side - short_side * 2)
est_crop_side = candidate_side[which(diff == min(diff))]














