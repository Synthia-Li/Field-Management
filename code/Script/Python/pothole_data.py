from detectron2.data.datasets import register_coco_instances
register_coco_instances("my_train", {}, "./mydata/data/annotations/instances_train2017.json", "./mydata/data/train2017")
register_coco_instances("my_val", {}, "./mydata/data/annotations/instances_val2017.json", "./mydata/data/val2017")
