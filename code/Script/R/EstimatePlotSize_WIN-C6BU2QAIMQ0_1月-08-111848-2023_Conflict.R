library(magick)

# inputs
root = "D:/temp/root"
Project_name = "MockProject"
Flight_name = "flight1"
ROI_name = "ROI1"
downscale = 0

image_name = file.path(root, Project_name, Flight_name, ROI_name, "uncropped", paste0(ROI_name, "_downscale", downscale,".png"))

plot_size_estimation_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation")
dir.create(plot_size_estimation_dir, showWarnings = FALSE)
output_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation", "raw_image")
dir.create(output_image_dir, showWarnings = FALSE)



### Crop image
source("D:/KC_file/EstimatePlotSize_crop.R")


### Predict image
result_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation", "result")
dir.create(result_image_dir, showWarnings = FALSE)

dir_list = list.dirs(output_image_dir, recursive = FALSE) 
dir_list = gsub(paste0(output_image_dir, "/"), "", dir_list)

source("D:/KC_file/MRCNN_prediction.R")
for(i in 1:length(dir_list)){
  
  this_result_image_dir = file.path(result_image_dir, dir_list[i])
  dir.create(this_result_image_dir, showWarnings = FALSE)
  
  this_detect_dir = file.path(output_image_dir, dir_list[i])
  
  MRCNN_predict(InputPath = this_detect_dir,
                OutputPath = this_result_image_dir)
}


### Calculate estimated crop size
source("D:/KC_file/EstimatePlotSize_cal.R")
print(est_crop_side)



### Delete folder
unlink(plot_size_estimation_dir, recursive = TRUE)







