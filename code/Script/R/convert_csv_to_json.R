
library(rjson)

root_dir = "E:/ZJU/FiledLogBook/datasets"
dataset_name = "ningxia"

#
project_name = paste("archive", dataset_name, sep = "_")

csv_folder_dir = file.path(root_dir, project_name, "csv_output")
setwd(csv_folder_dir)


sub_image_list = Sys.glob(paste("*",sep=""))

json_list = list()
zero_instance_image = c()
for(i in 1:length(sub_image_list)){
  sub_image_name = sub_image_list[i]
  
  setwd(file.path(csv_folder_dir, sub_image_name))
  csv_list = Sys.glob(paste("*.","csv" ,sep=""))
  
  if(length(csv_list)==0){
    zero_instance_image = c(zero_instance_image, sub_image_name)
  }
  else{
    instance_list = list()
    for(j in 1:length(csv_list)){
      dt = read.csv(csv_list[j], header = FALSE)
      y_coor = dt[,1]
      x_coor = dt[,2]
      conf = dt[1,4]
      
      add_list = list(x = x_coor, y = y_coor, confidence = conf)
      
      instance_list = append(instance_list, list(add_list))
      names(instance_list)[length(instance_list)] = paste0("instance", j)
      
    }
    json_list = append(json_list, list(instance_list))
    names(json_list)[length(json_list)] = sub_image_name
  }
  print(i)
}

setwd(file.path(root_dir, project_name, "detection_result"))

output_list = list( images_with_no_detections = zero_instance_image,
                    detections = json_list)

output_json = toJSON(output_list)
write(output_json, "detection_results.json")




















