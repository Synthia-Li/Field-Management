suppressWarnings(suppressMessages(library(rjson)))
suppressWarnings(suppressMessages(library(raster)))

####
#### front end inputs

root = "/media/zju/266ad8d3-a2c9-41e5-ba31-fd9fed946336"
Project_name = "project_youcai2023"
Flight_name = "flight1"

CompleteOrthoPath = file.path(root, Project_name, Flight_name, "CompleteOrtho", "CompleteOrtho_downscale0.tif") 

image <- raster(CompleteOrthoPath)
X_resolution = (image@extent@xmax - image@extent@xmin)/image@ncols
Y_resolution = (image@extent@ymax - image@extent@ymin)/image@nrows

downscale0_info = list(IMG_center = list(x = image@ncols/2, y = image@nrows/2),
                       IMG_size = list(w = image@ncols, h = image@nrows),
                       IMG_lon_range = list(xmin = image@extent@xmin, xmax = image@extent@xmax),
                       IMG_lat_range = list(ymin = image@extent@ymin, ymax = image@extent@ymax),
                       IMG_lon_resolution = X_resolution,
                       IMG_lat_resolution = Y_resolution,
                       scale = 1
)

Complete_Orthomosaic_info = list(downscale0 = downscale0_info)

json_list = list(Complete_Orthomosaic_info = Complete_Orthomosaic_info,
                 ROI_list = NA,
                 other = NA)

myfile = toJSON(json_list)
write(myfile, file.path(root, Project_name, Flight_name, "flight_info.json"))



## archive




























