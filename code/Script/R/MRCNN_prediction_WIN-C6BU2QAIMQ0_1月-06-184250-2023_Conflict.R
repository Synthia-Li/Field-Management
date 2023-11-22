library(reticulate)


# InputPath = "D:/temp/root/MockProject/flight1/ROI1/plot_size_estimation/raw_images"
# OutputPath = "D:/temp/root/MockProject/flight1/ROI1/plot_size_estimation"
WeightPath = "C:/Users/Administrator/Desktop/MRCNN_code/detectron2-main/output/model_final.pth"
code_path = "C:/Users/Administrator/Desktop/MRCNN_code/detectron2-main/my_predict_function.py"
use_condaenv("pytorch_test", required = TRUE)

setwd("C:/Users/Administrator/Desktop/MRCNN_code/detectron2-main")
source_python(code_path)

MRCNN_predict = function(InputPath, 
                         OutputPath, 
                         WeightPath = WeightPath,
                         code_path = code_path){
  
  #conda_list()
  #use_condaenv("pytorch_test", required = TRUE)
  #setwd("C:/Users/Administrator/Desktop/MRCNNÒÆÖ²/detectron2-main")
  #py_run_file("C:\\Users\\Administrator\\Desktop\\MRCNNÒÆÖ²\\detectron2-main\\my_predict_function.py")
  #source_python(code_path)
  
  Predict(InputPath = InputPath,
          OutputPath = OutputPath, 
          WeightPath = WeightPath)
  
}