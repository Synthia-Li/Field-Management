'''
Author       : LuHeQiu
Date         : 2022-09-16 12:54:38
LastEditTime : 2022-10-23 03:05:38
LastEditors  : LuHeQiu
Description  : 
FilePath     : \Script\Python\my_predict.py
HomePage     : https://www.luheqiu.com
'''
from asyncore import write
import json
from detectron2.utils.visualizer import Visualizer
from detectron2.data.catalog import MetadataCatalog, DatasetCatalog
import cv2
from detectron2.config import get_cfg
import os
from detectron2.engine.defaults import DefaultPredictor
import numpy as np
import time
import sys
import csv

def showMask(outputs,save_path):
    mask = outputs["instances"].to("cpu").get("pred_masks").numpy()
    img = np.zeros((mask.shape[1], mask.shape[2]))
    for i in range(mask.shape[0]):
        img += mask[i]
    np.where(img > 0, 255, 0)
    # cv2.namedWindow("mask", 0)
    cv2.imwrite(save_path,img*255)

DATASET_STR = "./mydata/testdata"
IMAGE_PATH = './mydata/data/inputs'
OUTPUT_STR = "./mydata/data/results"
VIS_STR = "./mydata/data/visulize_results"
pothole_metadata = MetadataCatalog.get(DATASET_STR)
MetadataCatalog.get(DATASET_STR).thing_classes = ["Field block"]

if __name__ == "__main__":

    argc = len(sys.argv)
    
    if (argc-1 < 2) :
        print("参数错误")
        sys.exit(1)

    IMAGE_PATH = sys.argv[1]
    OUTPUT_STR = sys.argv[2]
    DATA_PATH  = sys.argv[3]
    VIS_STR = OUTPUT_STR + str("/VIS")
    
    os.chdir("./Script/Python")

    cfg = get_cfg()
    cfg.merge_from_file(
        "./configs/COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml"
    )
    cfg.MODEL.WEIGHTS = os.path.join(cfg.OUTPUT_DIR, "model_final.pth")
    print('loading from: {}'.format(cfg.MODEL.WEIGHTS))
    cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.8   # set the testing threshold for this model
    cfg.MODEL.ROI_HEADS.NUM_CLASSES = 1
    cfg.DATASETS.TEST = (DATASET_STR, )
    predictor = DefaultPredictor(cfg)
    files = os.listdir(IMAGE_PATH)
    detect_dict = {}
    no_detect_dict = []
    start_time = time.time()

    for file in files:
        IMAGE_STR = IMAGE_PATH + "/" +str(file)
        print("开始处理图像{}".format(IMAGE_STR))
        data_f = IMAGE_STR
        im = cv2.imread(data_f)
        outputs = predictor(im)
        scores = outputs["instances"]._fields["scores"].to("cpu").tolist()
        mask = outputs["instances"].to("cpu").get("pred_masks").numpy()
        pic_dic = {}
        for mask_num in range(mask.shape[0]):
            mask_i = mask[mask_num,:,:]
            mask_i = np.uint8(mask_i)*255
            contours, hierarchy = cv2.findContours(mask_i, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
            for contours_num in range(len(contours)):
                contours[contours_num] = np.array(contours[contours_num]).reshape(-1,2).T
                pic_x=contours[contours_num].tolist()[0]
                pic_y=contours[contours_num].tolist()[1]
                pic_dic["instance{}_{}".format(mask_num,contours_num)] = {"x":pic_x,"y":pic_y,"confidence":scores[mask_num]}
        # dict = {"boxes":boxes,"scores":scores,"classes":classes,"mask":whole_mask}
        if mask.shape[0]==0:
            no_detect_dict.append(file)
        if mask.shape[0]!=0:
            detect_dict["{}".format(file)] = pic_dic
        v = Visualizer(im[:, :, ::-1],
                       metadata=pothole_metadata,
                       #scale=0.8,
                       #instance_mode=ColorMode.IMAGE_BW   # remove the colors of unsegmented pixels
                       )
        v = v.draw_instance_predictions(outputs["instances"].to("cpu"))
        img = v.get_image()[:, :, ::-1]
        # cv2.imshow('mask_rcnn instance segmentation', img)

        if not os.path.exists(OUTPUT_STR):
            os.mkdir(OUTPUT_STR)
        if not os.path.exists(VIS_STR):
            os.mkdir(VIS_STR)

        save_path =  OUTPUT_STR+"/"+str(file)
        cv2.imwrite( VIS_STR+"/"+str(file) ,img)
        showMask(outputs,save_path)

    whole_dict = {"images_with_no_detections":no_detect_dict,"detections":detect_dict}
    with open( str(OUTPUT_STR)+'/predict.json', 'w', encoding='utf-8') as fp:
        json.dump(whole_dict, fp, ensure_ascii=False)

    rows = []
    header = ["image_name","include_in_dataset","cropped","detected","uncropped","date","note","attributes","location","field_name","camera","altitude"]

    with open(str(DATA_PATH)+'./pic.csv','r',encoding='gbk') as logbook:
        reader = csv.DictReader(logbook)
        for row in reader:
            if row['image_name']==IMAGE_PATH.split("/")[-1]:
                row['detected']='TRUE'
            rows.append(row)
            
    with open(str(DATA_PATH)+'./pic.csv','w',encoding='gbk',newline='') as logbook:
        writer = csv.DictWriter(logbook,header)
        writer.writeheader()
        # 将数据写入
        writer.writerows(rows)


    end_time = time.time()
    print("总用时{}s".format(end_time-start_time))
