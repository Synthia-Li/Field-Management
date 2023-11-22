library(rjson)

# 接在 ComnpleteOrthoCrop 后面
this_ROI_info = list(beta = beta,
                     # IMG_center = list(x = ImgCenter_x, y = ImgCenter_y),
                     # IMG_size = list(w = ImgCenter_x*2, h = ImgCenter_y*2),
                     IMG_center_rotated = list(x = IMGCenter_x_rotated, y = IMGCenter_y_rotated),
                     IMG_cropped_center_on_IMG = list(x = RecCenter_x, y = RecCenter_y),
                     IMG_cropped_size = list(w = Rec_W, h = Rec_H),
                     IMG_cropped_center_on_rotated_IMG = list(x = RecCenter_x_rotated, y = RecCenter_y_rotated))

setwd("D:/temp/root/MockProject/flight1")

ROI_info = fromJSON(file = file.path("D:/temp/root", Project_name, Flight_name, "flight_info.json"))

if(length(ROI_info$ROI_list) == 0){ 
  #initialize first instance
  ROI_info[[length(ROI_info)+1]] = this_ROI_info
  names(ROI_info)[[length(ROI_info)]] = "ROI1"
  ROI_info$ROI_list = "ROI1"
}else{
  index = max(as.numeric(gsub("ROI", "", ROI_info$ROI_list)))
  ROI_name = paste0("ROI", index + 1)
  ROI_info[[length(ROI_info)+1]] = this_ROI_info
  names(ROI_info)[[length(ROI_info)]] = ROI_name
  ROI_info$ROI_list = c(ROI_info$ROI_list, ROI_name)
}


json_list = ROI_info


myfile = toJSON(json_list)
write(myfile, "flight_info.json")








