
source("D:/ZJU/FieldLogBook/Plotmatch_VerCrossHori_V1.R")
source("D:/ZJU/FieldLogBook/Pixel2latlon_V1.R")

# inputs
root = "D:/temp/root"
Project_name = "MockProject"
Flight_name = "flight1"
ROI_name = "ROI1"
downscale = 0


###################  start  ######################
ROI_dir = file.path(root, Project_name, Flight_name, ROI_name)





#### Match plots #### 
plot_dt = read.csv(file.path(root, Project_name, Flight_name, ROI_name, "plot_structure.csv"),
                   header = FALSE, na.strings=c(""))
output = plotmatch_VerCrossHori(filtered_stitched_polygon_list, plot_dt)

plot_grid_output = output[[1]]
poly_list_filled = output[[2]]


# to be tested
write.csv(plot_grid_output, file.path(ROI_dir, "detected_stitched", "plot_grid_output.csv"))

source("D:/ZJU/FieldLogBook/poly_coor_output.R")
poly_coor_output(poly_list = poly_list_filled,
                 output_path = file.path(ROI_dir, "detected_stitched"))






### convert to latlon coordinates
coor = as.data.frame(matrix(
  c(723,567,1435,559,2211, 575,3019,567,3835, 559,4587, 535,
    5395, 559,6179,559,6963,559,7835,559,8531,543,9331,559), nrow = 12, byrow = TRUE))
names(coor) = c("x", "y")
X = coor$x
Y = coor$y

flight_info_path = file.path(root, Project_name, Flight_name, "flight_info.json")

source("D:/KC_file/Pixel2latlon_V1.R")

output = ROI_pixel_latlon(X, Y, flight_info_path, ROI_name, downscale)
X_prior_rotation_lonlat = output[[1]]
Y_prior_rotation_lonlat = output[[2]]

label = paste0("plot", 1:length(X_prior_rotation_lonlat))
alt = rep(23,length(X_prior_rotation_lonlat))
output = as.data.frame(cbind(label, X_prior_rotation_lonlat, Y_prior_rotation_lonlat, alt))

write.table(output, "C:/Users/Administrator/Desktop/test.txt",
            row.names = F,  col.names = F,
            sep=",", quote = FALSE)





for(i in 1:nrow(plot_pixel_coor)){
  coor_out = ROI_pixel_latlon(plot_grid_output$x_coor[i], plot_grid_output$Y_coor[i], Project_name, Flight_name, ROI_name)
  
  coor_out[[1]]
  coor_out[[2]]
  
  
}

