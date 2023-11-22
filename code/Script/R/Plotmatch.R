
source(file.path(code_dir, "Plotmatch_VerCrossHori_V4.R"))
source(file.path(code_dir, "Pixel2latlon_V1.R"))
source(file.path(code_dir, "DrawImage_V1.R"))

#### front end inputs

# root = "D:/temp/root"
# Project_name = "MockProject"
# Flight_name = "flight1"
# ROI_name = "ROI1"
# downscale = 0


###################  start  ######################
ROI_dir = file.path(root, Project_name, Flight_name, ROI_name)


#### Match plots #### 
plot_dt = read.csv(file.path(root, Project_name, Flight_name, ROI_name, "user_upload", "plot_structure.csv"),
                   header = FALSE, na.strings=c(""))
output = plotmatch_VerCrossHori(filtered_stitched_polygon_list, filtered_stitched_polygon_list_name, plot_dt)

plot_grid_output = output[[1]]
poly_list_filled = output[[2]]
poly_list_filled_name = output[[3]]


# draw
plot(poly_list_filled)
Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name,"_downscale",downscale, ".png")),
                              poly_draw_list = poly_list_filled,
                              poly_name_list = filtered_stitched_polygon_list_name, 
                              write_path = file.path(ROI_dir, "detected_stitched",
                                                     paste0("3_Filtered_", ROI_name, "_new.png",sep="")))








####################
# to be tested
write.csv(plot_grid_output, file.path(ROI_dir, "detected_stitched", "plot_grid_output.csv"))

source("D:/ZJU/FieldLogBook/poly_coor_output.R")
poly_coor_output(poly_list = poly_list_filled,
                 output_path = file.path(ROI_dir, "detected_stitched"))





### convert to latlon coordinates test dataset
coor = as.data.frame(matrix(
  c(723,567,1435,559,2211, 575,3019,567,3835, 559,4587, 535,
    5395, 559,6179,559,6963,559,7835,559,8531,543,9331,559), nrow = 12, byrow = TRUE))
names(coor) = c("x", "y")
X = coor$x
Y = coor$y

flight_info_path = file.path(root, Project_name, Flight_name, "flight_info.json")

source("D:/KC_file/Pixel2latlon_V1.R")

position_latlon = ROI_pixel_latlon(X, Y, flight_info_path, ROI_name, downscale)
X_prior_rotation_lonlat = position_latlon[[1]]
Y_prior_rotation_lonlat = position_latlon[[2]]


label = as.vector(t(plot_dt)[, 1])
nrow = rep(1, length(X_prior_rotation_lonlat))
ncol = 1:length(X_prior_rotation_lonlat)
alt = rep(23, length(X_prior_rotation_lonlat))
output = as.data.frame(cbind(label, nrow, ncol, X_prior_rotation_lonlat, Y_prior_rotation_lonlat, alt))
output$tag = paste(output$nrow, output$ncol, sep = "_")

write.table(output, file.path(ROI_dir, "plot_summary.csv"),
            row.names = F,  col.names = F,
            sep=",", quote = FALSE)

