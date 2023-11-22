###
### 功能：对于一组完整拼接正射影像大图进行裁切。
### 准备工作：
### 找到root，将所有图片放置于root/complete_ortho_list
### 准备ROI_BBX边界坐标点表格放置于同一路径
###

root = "D:/Fuyang_LXQ/15mFuyangPingjieDatu"
code_dir = "D:/KC_file"

dir_complete_ortho_list = file.path(root, "user_upload")
complete_ortho_list = list.files(dir_complete_ortho_list)

Project_name = "Project_image_crop"
Project_dir = file.path(root, Project_name)
dir.create(Project_dir, showWarnings = FALSE)

output_dir = file.path(root, "Outputs")
dir.create(output_dir, showWarnings = FALSE)

# read in ROI table
ROI_bbx = read.csv(file.path(root, "user_upload", "ROI_BBX.csv"))

for(i in 1:length(ROI_bbx$image_name)){
  
  ### initialize
  this_ortho = ROI_bbx$image_name[i]
  short_name = ROI_bbx$short_name[i]
  
  Flight_name = this_ortho
  Flight_dir = file.path(root, Project_name, Flight_name)
  dir.create(Flight_dir, showWarnings = FALSE)
  
  CompleteOrthoPath = file.path(root, Project_name, Flight_name, "CompleteOrtho") 
  dir.create(CompleteOrthoPath, showWarnings = FALSE)
  
  file.copy(file.path(dir_complete_ortho_list, this_ortho), CompleteOrthoPath)
  file.rename(file.path(CompleteOrthoPath, this_ortho), 
              file.path(CompleteOrthoPath, "CompleteOrtho_downscale0.tif"))
  
  
  ### initilize
  source(file.path(code_dir,"InitialCompleteOrtho.R"))
  
  ### downscale
  source(file.path(code_dir,"OrthoDownScale_V1.R"))
  
  ### assuming one ROI in each image
  ROI_name = "ROI1"
  ROI_path = file.path(root, Project_name, Flight_name, ROI_name)
  dir.create(ROI_path, showWarnings = FALSE)
  
  ### read in OrthoCrop coordinates
  if(! this_ortho %in% ROI_bbx$image_name) stop("Error: Image ROI crop coordinates missing")
  index = which(ROI_bbx$image_name == this_ortho)
  measured_p1 = c(ROI_bbx$x_upperleft[index], ROI_bbx$y_upperleft[index]) # 左上角
  measured_p2 = c(ROI_bbx$x_upperright[index], ROI_bbx$y_upperright[index]) # 右上角
  measured_p3 = c(ROI_bbx$x_lowerleft[index], ROI_bbx$y_lowerleft[index]) # 左下角
  
  ### determine resolution
  downscale = 0
  source(file.path(code_dir,"CompleteOrthoCrop.R"))
  
  ### determine image size to crop
  source(file.path(code_dir,"EstimatePlotSize.R"))
  print(est_crop_side)
  est_crop_side = 3096
  
  ### crop ROI
  source(file.path(code_dir,"ROIOrthoCrop.R"))
  
  ### predict plots in ROI
  source(file.path(code_dir,"IntegratePlots_V2.R"))
  plot(stitched_polygon_list)
  
  ### filter plots in ROI
  source(file.path(code_dir,"FilterPlot_V1.R"))
  output = FilterPlots(stitched_polygon_list, stitched_polygon_list_name, draw = FALSE, dbscan_eps = 25)
  picked_filtered_stitched_polygon_list = output[[1]]
  picked_filtered_stitched_polygon_list_name = output[[2]]
  plot(picked_filtered_stitched_polygon_list)
  
  #### Match plots #### 
  source(file.path(code_dir, "Plotmatch_VerCrossHori_V3.R"))
  plot_dt = read.csv(file.path(root, "user_upload", "plot_structure.csv"), header = FALSE, na.strings=c(""))
  output = plotmatch_VerCrossHori(picked_filtered_stitched_polygon_list, 
                                  picked_filtered_stitched_polygon_list_name, 
                                  plot_dt)
  plot_grid_output = output[[1]]
  poly_list_filled = output[[2]]
  poly_list_filled_name = output[[3]]
  
  plot(poly_list_filled)
  
  # draw
  Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name,"_downscale",downscale, ".png")),
                                poly_draw_list = poly_list_filled,
                                poly_name_list = filtered_stitched_polygon_list_name, 
                                write_path = file.path(ROI_dir, "detected_stitched",
                                                       paste0("3_Filtered_", ROI_name, "_new.png",sep="")))
  
  
  #cropping
  this_ortho_output_dir = file.path(output_dir, this_ortho)
  dir.create(this_ortho_output_dir, showWarnings = FALSE)
  
  source(file.path(code_dir, "Center_based_crop_V1.R"))
  center_based_crop(read_in_table = plot_grid_output,
                    read_in_image = file.path(uncropped_image_dir, paste0(ROI_name, "_downscale", downscale, ".png")),
                    crop_w = 700,
                    crop_h = 700,
                    ortho_name = this_ortho,
                    short_name = short_name, 
                    to_save_dir = this_ortho_output_dir)
  
  
  
}




































