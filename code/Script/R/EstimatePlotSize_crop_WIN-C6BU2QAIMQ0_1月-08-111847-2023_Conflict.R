# library(magick)
# 
# # inputs
# root = "D:/temp/root"
# Project_name = "MockProject"
# Flight_name = "flight1"
# ROI_name = "ROI1"
# downscale = 0
# 
# image_name = file.path(root, Project_name, Flight_name, ROI_name, "uncropped", paste0(ROI_name, "_downscale", downscale,".png"))
# 
# 
# plot_size_estimation_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation")
# dir.create(plot_size_estimation_dir, showWarnings = FALSE)
# output_image_dir = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation", "raw_image")
# dir.create(output_image_dir, showWarnings = FALSE)







image = image_read(image_name)

info = image_info(image)
if(length(info) > 1){
  image = image[1]
}


xrange = as.numeric(image_info(image)[2])
yrange = as.numeric(image_info(image)[3])


# 5 steps with 5 replicates
x_size_list = 1:10 * 1024
y_size_list = 1:10 * 1024 
rep_number = 5

if( xrange<x_size_list[2] | yrange<y_size_list[2] ) warning("Error in Estimate plot size - input Image too small")

xrange_to_pick = xrange > 2 * x_size_list
yrange_to_pick = yrange > 2 * x_size_list

to_pick = xrange_to_pick & yrange_to_pick
x_size_list = x_size_list[to_pick]
y_size_list = y_size_list[to_pick]

x_coor_list = sample((0 + x_size_list[length(x_size_list)]/2):(xrange - x_size_list[length(x_size_list)]/2), rep_number, replace=F)
y_coor_list = sample((0 + y_size_list[length(x_size_list)]/2):(yrange - y_size_list[length(x_size_list)]/2), rep_number, replace=F)


for(i in 1:length(x_size_list)){
  dir.create(file.path(output_image_dir, x_size_list[i]), showWarnings = FALSE)
  print(paste0("cropping resolution: ", x_size_list[i]))
  
  for(j in 1:rep_number){
    
    image_to_save = image_crop(image, paste(x_size_list[i],"x",y_size_list[i],"+",
                                            x_coor_list[j]-x_size_list[i]/2,"+",y_coor_list[j]-y_size_list[i]/2,sep="")) #width/height/x/y
    
    
    image_to_save = image_scale(image_scale(image_to_save,"1024"),"x1024")

    # image_to_save_name = file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation",
    #                                paste0("CROP_x[", x_size_list[i],"]y[",y_size_list[i], "]_[",j, "].png"))
    
    image_to_save_name = paste(ROI_name, 
                               "(x[", x_coor_list[j]-x_size_list[i]/2,"][",x_coor_list[j]+x_size_list[i]/2, 
                               "]y[", y_coor_list[j]-y_size_list[i]/2,"][",y_coor_list[j]+y_size_list[i]/2, 
                               "]i[", (i-1)*rep_number+j, "][", rep_number*length(x_size_list), "]).png", sep = "" )
    
    image_write(image_to_save, 
                file.path(root, Project_name, Flight_name, ROI_name, "plot_size_estimation", "raw_image", x_size_list[i], image_to_save_name), 
                format = "png")
    
  }
}









