library(reticulate)


current_path = getwd()
# InputPath = "D:/temp/root/MockProject/flight1/ROI1/plot_size_estimation/raw_images"
# OutputPath = "D:/temp/root/MockProject/flight1/ROI1/plot_size_estimation"
WeightPath = "/home/zju/code/detectron2-main/output/model_final.pth"
code_path = "/home/zju/code/detectron2-main/my_predict_JX.py"

use_condaenv("pytorch_ubuntu", required = TRUE)
# py_config()

setwd("/home/zju/code/detectron2-main")
source_python(code_path)
# setwd(current_path)


MRCNN_predict = function(InputPath_to_predict, 
                         OutputPath_to_predict, 
                         WeightPath_to_predict = WeightPath){
  
  #conda_list()
  #use_condaenv("pytorch_test", required = TRUE)
  #setwd("C:/Users/Administrator/Desktop/MRCNNÒÆÖ²/detectron2-main")
  #py_run_file("C:\\Users\\Administrator\\Desktop\\MRCNNÒÆÖ²\\detectron2-main\\my_predict_function.py")
  #source_python(code_path)
  
  Predict(InputPath = InputPath_to_predict,
          OutputPath = OutputPath_to_predict, 
          WeightPath = WeightPath_to_predict)
  
}















