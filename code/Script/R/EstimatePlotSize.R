library(magick)

#### front end inputs
# code_dir = "/home/zju/R_pipeline_JX/R_code"
# root = "/media/zju/266ad8d3-a2c9-41e5-ba31-fd9fed946336"
# Project_name = project_youcai2023"
# Flight_name = "flight1"
# ROI_name = "ROI1"
# downscale = 0

image_name = file.path(root, Project_name, Flight_name, ROI_name, "uncropped", paste0(ROI_name, "_downscale", downscale,".png"))

plot_size_estimation_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation")
dir.create(plot_size_estimation_dir, showWarnings = FALSE)
output_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation", "raw_image")
dir.create(output_image_dir, showWarnings = FALSE)

### crop image
source(file.path(code_dir,"EstimatePlotSize_crop.R"))


### predict image
result_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation", "result")
dir.create(result_image_dir, showWarnings = FALSE)

dir_list = list.dirs(output_image_dir, recursive = FALSE) 
dir_list = gsub(paste0(output_image_dir, "/"), "", dir_list)

source(file.path(code_dir, "MRCNN_prediction.R"))
for(i in 1:length(dir_list)){
  
  this_result_image_dir = file.path(result_image_dir, dir_list[i])
  dir.create(this_result_image_dir, showWarnings = FALSE)
  
  this_detect_dir = file.path(output_image_dir, dir_list[i])
  
  setwd("/home/zju/code/detectron2-main")
  MRCNN_predict(InputPath = this_detect_dir,
                OutputPath = this_result_image_dir)
}
setwd(root)


### Calculate estimated crop size
source(file.path(code_dir, "EstimatePlotSize_cal.R"))
est_crop_side = PlotSizeCalculation(result_image_dir)

#est_crop_side = 2048

### add info
ROI_info = fromJSON(file = file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))
ROI_info$progress_bar$plot_size_estimation = "done"

if("estimated_crop_size" %in% names(ROI_info)){
  ROI_info$estimated_crop_size = est_crop_side
}else{
  ROI_info[[length(ROI_info)+1]] = est_crop_side
  names(ROI_info)[[length(ROI_info)]] = "estimated_crop_size"
}

myfile = toJSON(ROI_info)
write(myfile, file.path(root, Project_name, Flight_name, ROI_name, "ROI_info.json"))


### Delete folder
#unlink(plot_size_estimation_dir, recursive = TRUE)

































