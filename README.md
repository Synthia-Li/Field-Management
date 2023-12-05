# Field-Management

My Undergraduate Thesis: 

Development of an image data management system based on UAV remote sensing for crop breeding

Awarded '**Top Ten Excellent Graduation Thesis**' at Zhejiang University

## Technical Description

Tech Stack: C++, QT Creator, MySQL, Computer Vision, Object-Oriented Design
● Based on the object-oriented design, utilized QT for the front end, C++ for the back end, and MySQL for data storage 
● Utilized the Mask RCNN computer vision model to realize automatic field segmentation and improve 80% efficiency
● Reduced 64% modeling and query API latency by multi-threading in the backend, implementing pagination and adding appropriate indexes to MySQL 
● Achieved the highest honor for undergraduate thesis at college: Top 10 Outstanding Graduation Thesis

## Abstract

Against the background of the global food crisis and limited arable land, it is imperative to raise genetic improvement rates, increase crop yields, and enhance resilience through agricultural and breeding technology. Agricultural breeding testing collects and analyzes spatial and temporal data on the characteristics of different plants in different breeding plots. Unmanned aerial vehicle (UAV) remote sensing is applicable for collecting large-scale and high-revisit-frequency information. At the same time, machine learning serves as a powerful technique for analyzing large-scale image data, which can be used for detecting plots, classifying images, and detecting crop growth trends. The combination of the two can serve to collect remote sensing images and then generate complete field data sets. Thus, the current study planned to develop a crop breeding data management software based on UAV remote sensing images. This software is expected to statistically collect machine-learned partition plot data. A multi-modal expandable database of numerical text images will also be built from the data collected to enhance breeding information spatiotemporal management, with which breeding efficiency can be improved and in turn increase yields and income in the industry.

We found that existing breeding data management systems emphasize large scales with the ignorance of small plots. They also have relatively weak expandability and customizability, focusing more on data collection rather than user interaction. Therefore, the current study designed a crop breeding data management system with supplementary features such as strengthened expandability, increased user-friendliness, and lower cost in installation, learning, and usage. We identified the data types that need to be managed, compared existing model platforms, and chose development tools, software, and hardware environments based on our goals. The design of the database architecture fully considered user needs and stuck to design principles. We also offered a specific introduction to the system's functions, with real data testing of its software functionality and usage conducted in an actual production environment.

The current software combines advanced technologies such as a software interface developed based on QT for friendly human-computer interaction, high-quality databases built based on MySQL, and automated UAV remote sensing plot image processing based on Mask R-CNN. It can manage breeding plots from three dimensions namely space, time, and indicators, with the spatial dimension divided into four scales: breeding bases, complete plots, breeding zones, and single plantations. 
The database includes multi-modal data including images, texts, and numerics. It enables breeders to have a panorama of the entire breeding base as well as check specific plots or even have a close look at one particular plant. Breeders can obtain remote breeding plot information without traveling among breeding bases, which will save breeders' time for more significant work.


**Keywords:** Breeding; Database; Field Identification; UAV Remote Sensing
