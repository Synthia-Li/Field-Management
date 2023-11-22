library(raster)
library(sp)
library(rgdal)
library(rjson)



ROI_pixel_latlon = function(X, Y, flight_info_path, ROI_name, downscale){
  
  # read info
  flight_info = fromJSON(file = flight_info_path)
  this_IMG0 = flight_info$Complete_Orthomosaic_info[[paste0("downscale", downscale)]]
  this_ROI = flight_info[[ROI_name]]
  
  downscale_IMG0_center = this_IMG0$IMG_center
  downscale_IMG0_size = this_IMG0$IMG_size
  downscale_IMG0_lat_range = this_IMG0$IMG_lat_range
  downscale_IMG0_lon_range = this_IMG0$IMG_lon_range
  downscale_IMG0_lat_resolution = this_IMG0$IMG_lat_resolution
  downscale_IMG0_lon_resolution = this_IMG0$IMG_lon_resolution
  
  # downscale0_info = flight_info$Complete_Orthomosaic_info[[paste0("downscale", 0)]]
  # downscale0_IMG0_lat_resolution = downscale0_info$IMG_lat_resolution
  # downscale0_IMG0_lon_resolution = downscale0_info$IMG_lon_resolution
  
  
  beta = this_ROI$beta
  
  IMG_center_on_IMG = this_ROI$IMG_center_on_IMG
  rIMG_center_on_rIMG = this_ROI$rIMG_center_on_rIMG
  ROI_origin = this_ROI$ROI_origin
  ROI_center_on_IMG0 = this_ROI$ROI_center_on_IMG0
  ROI_center_on_rIMG = this_ROI$ROI_center_on_rIMG
  ROI_size = this_ROI$ROI_size
  
  
  X_post_rotation = X + ROI_center_on_rIMG$x - ROI_size$w/2 
  Y_post_rotation = Y + ROI_center_on_rIMG$y - ROI_size$h/2 
  #### plot out
  # IM_tem = image_read(file.path(ROI_path, "uncropped", "magick_after_crop_after_rotate.png") )
  # img = image_draw(IM_tem)
  # points(X_post_rotation, Y_post_rotation, pch = 19, cex = 10, col = "red")
  # dev.off()
  # image_write(img, file.path(ROI_path, "uncropped", 'tem_after_rotate.png'), format = "png")
  
  X_prior_rotation = (X_post_rotation-rIMG_center_on_rIMG$x)*cos(-beta*pi/180)-(Y_post_rotation-rIMG_center_on_rIMG$y)*sin(-beta*pi/180) + IMG_center_on_IMG$x
  Y_prior_rotation = (X_post_rotation-rIMG_center_on_rIMG$x)*sin(-beta*pi/180)+(Y_post_rotation-rIMG_center_on_rIMG$y)*cos(-beta*pi/180) + IMG_center_on_IMG$y
  
  #### plot out
  # IM_tem = image_read(file.path(ROI_path, "uncropped", "magick_after_crop_before_rotate.png") )
  # img = image_draw(IM_tem)
  # points(X_prior_rotation, Y_prior_rotation, pch = 19, cex = 10, col = "red")
  # dev.off()
  # image_write(img, file.path(ROI_path, "uncropped", 'tem_before_rotate.png'), format = "png")
  
  
  X_prior_rotation_lonlat = (ROI_origin$x + X_prior_rotation) * downscale_IMG0_lon_resolution  + IMG_lon_range$xmin
  Y_prior_rotation_lonlat = IMG_lat_range$ymax - (ROI_origin$y + Y_prior_rotation) * downscale_IMG0_lat_resolution # Y coordinate starts from top
  
  
  
  
  return(list(X_prior_rotation_lonlat, Y_prior_rotation_lonlat))
}


# X = coor$x
# Y = coor$y
# 
# 
# label = paste0("plot", 1:length(X_prior_rotation_lonlat))
# alt = rep(23,length(X_prior_rotation_lonlat))
# output = as.data.frame(cbind(label, X_prior_rotation_lonlat, Y_prior_rotation_lonlat, alt))
# 
# 
# 
# write.table(output, "C:/Users/Administrator/Desktop/test.txt", 
#             row.names = F,  col.names = F,
#             sep=",", quote = FALSE)
# 






