#### Labeling individual images ####
dir.create(file.path(ROI_dir, "detected_cropped"), showWarnings = FALSE)
# data cleaning 
(json_path = file.path(ROI_dir, "detected_cropped", "predict.json"))
output = JsonCleanSort(json_readin = json_path, 
                       pixel_upscale = pixel_upscale,
                       stitch_coordinates = FALSE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]
# draw
Draw_Polygon_On_Individual_Images(draw_poly_list = raw_polygon_list,
                                  draw_poly_name_list = raw_polygon_list_name,
                                  cropped_image_dir = file.path(ROI_dir, "cropped"),
                                  output_dir = file.path(ROI_dir, "detected_cropped"))


#### Labeling stitched image with unstitched predictions ####
dir.create(file.path(ROI_dir, "detected_stitched"), showWarnings = FALSE)
# data cleaning 
(json_path = file.path(ROI_dir, "detected_cropped", "predict.json"))
output = JsonCleanSort(json_readin = json_path, 
                       pixel_upscale = pixel_upscale,
                       stitch_coordinates = TRUE)
raw_polygon_list = output[[1]]
raw_polygon_list_name = output[[2]]
# draw
Draw_Polygon_On_Stiched_Image(image_name = file.path(ROI_dir, "uncropped", paste0(ROI_name,"_downscale",downscale, ".png")),
                              poly_draw_list = raw_polygon_list,
                              poly_name_list = raw_polygon_list_name, 
                              write_path = file.path(ROI_dir, "detected_stitched",
                                                     paste0("1_Unstitched_", ROI_name, ".png",sep="")))