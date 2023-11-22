suppressWarnings(suppressMessages(library(magick)))
suppressWarnings(suppressMessages(library(rjson)))

#### front end inputs

# root = "/media/zju/266ad8d3-a2c9-41e5-ba31-fd9fed946336"
# Project_name = "project_youcai2023"
# Flight_name = "flight1"
# ROI_name = "ROI1"



# initialize
ortho_path = file.path(root, Project_name, Flight_name, "CompleteOrtho") 
read_path = file.path(ortho_path, "CompleteOrtho_downscale0.tif")


#### crop IMG ####
print("Reading image")
IM = image_read(read_path)
if(nrow(image_info(IM))>1){
  print("Image has more than one layers. Default using first layer.")
  IM = IM[1]
}

width = as.numeric(image_info(IM)[2])
height = as.numeric(image_info(IM)[3])

if(width > height){
  side = "width"
  layer_n = floor(log2(width))
} 
if(width <= height){
  side = "height"
  layer_n = floor(log2(height))
} 

downscale = 1
while(2^(layer_n-downscale) >= 1024){
  print(paste("working on downsacle", downscale, sep = ": "))
  
  if(side == "width"){
    IM1 = image_scale(IM, geometry = paste(2^(layer_n-downscale+1)))
    scale_factor = width / (2^(layer_n-downscale+1))
  }
  if(side == "height"){
    IM1 = image_scale(IM, geometry = paste0("x", 2^(layer_n-downscale+1)))
    scale_factor = height / (2^(layer_n-downscale+1))
  }
  image_write(IM1, file.path(ortho_path, paste0("CompleteOrtho_downscale", downscale, ".tif")), format = "tif")
  

  
  ### update flight info
  flight_info = fromJSON(file = file.path(root, Project_name, Flight_name, "flight_info.json"))
  edit_node = flight_info[["Complete_Orthomosaic_info"]]
  
  downscale0info = edit_node[["downscale0"]]
  IMG_lat_range = downscale0info$IMG_lat_range
  IMG_lon_range = downscale0info$IMG_lon_range
  this_x_resolution = downscale0info$IMG_lat_resolution * scale_factor
  this_y_resolution = downscale0info$IMG_lon_resolution * scale_factor

  to_add = list(IMG_center = list(x = as.numeric(image_info(IM1)[2])/2, y = as.numeric(image_info(IM1)[3])/2),
                IMG_size = list(w = as.numeric(image_info(IM1)[2]), h = as.numeric(image_info(IM1)[3])),
                IMG_lat_range = IMG_lat_range,
                IMG_lon_range = IMG_lon_range,
                IMG_lat_resolution = this_x_resolution,
                IMG_lon_resolution = this_y_resolution,
                scale = scale_factor)
                  
  edit_node[length(edit_node)+1] = list(new = to_add)
  names(edit_node)[length(edit_node)] = paste0("downscale", downscale)
  
  flight_info[["Complete_Orthomosaic_info"]] = edit_node
  myfile = toJSON(flight_info)
  write(myfile, file.path(root, Project_name, Flight_name, "flight_info.json"))
  
  
  downscale = downscale + 1
}

  






































