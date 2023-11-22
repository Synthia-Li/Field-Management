### Kevin
### Good Good Study
### Day Day Up

# User input
dataset_name = "zhangjiakou_second"
root = "E:\\ZJU\\MAP杯\\data"
source_image_path = "E:\\ZJU\\MAP杯\\data\\正射拼接大图来源"

####
# Make Folders
dataset_dir = file.path(root, dataset_name)
dir.create(dataset_dir , showWarnings = F)
setwd(dataset_dir)
cat(paste0("\n", Sys.time(), "  ---  ", "#### Initiate ####"), file = "log_file.txt")

dir.create(file.path(dataset_dir, "images") , showWarnings = F)
dir.create(file.path(dataset_dir, "images", paste0("cropped_ortho")) , showWarnings = F)
dir.create(file.path(dataset_dir, "images", "uncropped_ortho") , showWarnings = F)
dir.create(file.path(dataset_dir, "detection_results") , showWarnings = F)
dir.create(file.path(dataset_dir, "detection_results", "cropped_ortho") , showWarnings = F)
dir.create(file.path(dataset_dir, "detection_results", "stitched_ortho") , showWarnings = F)
cat(paste0("\n", Sys.time(), "  ---  ", "Folders Made"), 
    file = file.path(dataset_dir, "log_file.txt"), append = TRUE)

# Images in Source Folder
setwd(source_image_path)
image_list = Sys.glob(paste("*","tif",sep=""))

# Initilize table or Add Images 
setwd(dataset_dir)
if(! file.exists("logbook.csv") ){
  # initilize
  dt = as.data.frame(matrix(nrow = length(image_list), ncol = 11))
  names(dt) = c("user_input", "image_name",	"include_in_dataset",	"note",	"attributes",
                "date",	"location",	"field_name",	"camera",	"altitude",	"image_type")
  dt$image_name = image_list
  dt$include_in_dataset = TRUE
  dt$note = paste0("added_", Sys.Date())
  
  # write
  setwd(dataset_dir)
  write.table(dt, "logbook.csv",
              na = "",
              row.names = FALSE,
              col.names = TRUE,
              sep = ",")
  
}else{
  logbook = read.table(file="logbook.csv", header=TRUE, sep = ",")
  current_image_name = logbook$image_name
  new_image_name = image_list[which(! image_list %in% current_image_name )]
  
  
  dt = as.data.frame(matrix(nrow = length(new_image_name), ncol = 11))
  names(dt) = c("user_input", "image_name",	"include_in_dataset",	"note",	"attributes",
                "date",	"location",	"field_name",	"camera",	"altitude",	"image_type")
  dt$image_name = new_image_name
  dt$include_in_dataset = TRUE
  dt$note = paste0("added_", Sys.Date())
  
  output = rbind(logbook, dt)
  setwd(dataset_dir)
  write.table(output, "logbook.csv",
              na = "",
              row.names = FALSE,
              col.names = TRUE,
              sep = ",")
}
cat(paste0("\n", Sys.time(), "  ---  ", "Files generated"), 
    file = file.path(dataset_dir, "log_file.txt"), append = TRUE)

save(root, dataset_name, source_image_path, file = file.path(dataset_dir, "stored_data.RData"))











