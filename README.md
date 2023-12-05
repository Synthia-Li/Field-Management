# Field-Management

My Undergraduate Thesis: 

Development of an image data management system based on UAV remote sensing for crop breeding

Awarded '**Top Ten Excellent Graduation Thesis**' at Zhejiang University

## Abstract

Given the global food crisis and limited arable land, it is imperative to improve genetic improvement rates and increase crop yields and resilience through agricultural and breeding work. Agricultural breeding testing involves spatial and temporal data collection and analysis of different plant characteristics in different breeding plots. Unmanned aerial vehicle (UAV) remote sensing is applicable for collecting large-scale and high-revisit-frequency information, while machine learning serves as a powerful technique for analyzing large-scale image data, which can be used for detecting plots, classifying images, and detecting crop growth trends. Therefore, we can obtain remote sensing images through UAVs and use machine learning to generate complete field data sets. Based on this background, this study expects to develop a crop breeding data management software based on UAV remote sensing images to statistically collect machine-learned partition plot data, establish a multi-modal expandable database of numerical text images, enhance breeding information spatio-temporal management, thereby improving breeding efficiency and  increasing yield and income in the industry.

This article initially analyzes relevant domestic and foreign literature in related fields, identifying existing breeding data management systems’ shortcomings including emphasis on large scales rather than small plots, weak expandability and customizability, and a focus on data collection rather than user interaction. Therefore, this study hopes to design a crop breeding data management system that exhibits advantages such as strong expandability, user-friendliness, and low installation, learning, and usage costs. Based on this, this paper identifies the data types that need to be managed, compares existing model platforms, and discusses development tools and software and hardware environments. While designing the overall architecture, this study delves into user needs and clarifies design principles, ultimately completing the software database architecture design. Finally, software development is completed, and a specific introduction to the system's functions is provided, with real data testing of software functionality and usage conducted in an actual production environment.

The software technology combines advanced technologies such as a software interface developed based on QT for friendly human-computer interaction, high-quality databases built based on MySQL, and automated UAV remote sensing plot image processing based on Mask R-CNN. Regarding software functionality, it can manage breeding plots from three dimensions: space, time, and indicators, with the spatial dimension divided into four scales: breeding bases, complete plots, breeding zones, and single plantations. This database includes multi-modal data such as images, texts, and numerics. Breeders can view the situation of the entire breeding base macroscopically or view specific plots or even some specific plants through images. Breeders can analyze and obtain breeding plot information without the need for constant travel between breeding bases, which can help breeders conduct breeding work more quickly and accurately.


**Keywords:** Breeding; Database; Field Identification; UAV Remote Sensing
