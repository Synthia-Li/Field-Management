# output polygon boundary coordinates
library(rjson)

poly_coor_output = function(poly_list, output_path){
  
  poly_coor_output_list <- vector(mode="list", length=length(poly_list))
  
  for(i in 1:length(poly_list)){
    dt = as.data.frame(st_coordinates(poly_list[i]))
    poly_coor_output_list[[i]] = paste(dt$X, dt$Y, sep = "-")
  }
  
  jsonData = toJSON(poly_coor_output_list)
  
  to_save_path = file.path(output_path, "output.json")
  write(jsonData, to_save_path)
  
}



