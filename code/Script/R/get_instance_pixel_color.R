


library(sf)

setwd("C:/Users/Cen'sLab/Desktop")
dt = read.csv("second.csv", fileEncoding = "utf-8")

dt$X[1:5]

i=1


pol = st_sfc()
for(i in 1:5){
  p = st_polygon(list(cbind(
    dt$X[(5*(i-1)+1):(5*(i-1)+5)], #X
    dt$Y[(5*(i-1)+1):(5*(i-1)+5)] #Y 
  )))
  p = st_sfc(p)
  
  pol = c(pol, p)
}


name_list = unique(dt$index)


summary = as.data.frame(matrix(ncol = 5, nrow = 0))
for( i in 1:5){
  
  to_pick_instance = st_contains(pol[i], stitched_polygon_list)
  
  this_instance_list = stitched_polygon_list[to_pick_instance[[1]]]
  this_instance_list_name = stitched_polygon_list_name[to_pick_instance[[1]]]
  
  print("working on ")
  print(i)
  
  for( j in 1:length(this_instance_list)){
    
    print(j)
    
    instance_bbox = st_bbox(this_instance_list[j])
    xmin = as.numeric(instance_bbox[1])
    xmax = as.numeric(instance_bbox[3])
    ymin = as.numeric(instance_bbox[2])
    ymax = as.numeric(instance_bbox[4])
    
    image_to_save = image_crop(image, paste( (xmax-xmin+1),"x", (ymax-ymin+1),"+",xmin,"+",ymin,sep="")) #width/height/x/y
    cimg = magick2cimg(image_to_save)
    r = as.data.frame(R(cimg))
    g = as.data.frame(G(cimg))
    b = as.data.frame(B(cimg))
    
    rgb = r
    names(rgb)[3] = "r"
    rgb$x = rgb$x + xmin
    rgb$y = rgb$y + ymin
    rgb$g = g$value
    rgb$b = b$value
    rgb$tag = paste(rgb$x, rgb$y, sep = "_")

    tag_within = c()
    for(m in 1:(ymax-ymin+1)){
      for(n in 1:(xmax-xmin+1)){
        to_add = st_point(c(xmin+n, ymin+m ))
        
        if( length(st_contains(this_instance_list[j], to_add)[[1]]) != 0 ){
          tag_within = c(tag_within, paste(xmin+n, ymin+m, sep = "_"))
          
        }
      }
    }
    
    rgb_keep = rgb[which( rgb$tag %in% tag_within), ]
    r_mean = mean(rgb_keep$r)
    g_mean = mean(rgb_keep$g)
    b_mean = mean(rgb_keep$b)
    
    summary = rbind(summary, c(i, this_instance_list_name[j], r_mean, g_mean, b_mean))
    
  }
}

  
  
write.csv(summary, "summary.csv")






























