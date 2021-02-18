## Niche Modeling for wild boar (*Sus scrofa*) in Argentina and neighboring countries

<img src="https://user-images.githubusercontent.com/20196847/82152923-d78ba600-983a-11ea-9bfc-2a9115a029f5.jpg" height="100" width="100" img align="right">

Luciano F. La Sala and Julián M. Burgos

Table of Contents
---------- 
-   [Introduction](#introduction)
-   [Methodological approach](#methodological-approach)
    - Occurrence data processing  
    - Remote sensing and climate data   
    - Raster layers processing 
    - Model calibration     
    - Model validation
    
    
Introduction
----------  
This repository contains the R scripts and details of methods employed for the development of an ecological niche model (henceforth ENM) for Wild boar (*Sus scrofa*) in contiguous Argentina and neighboring countries.

A Maximum Entropy approach (https://biodiversityinformatics.amnh.org/open_source/maxent/) method was used inside the R programing environment (https://www.r-project.org/). The repository also aims to serve as a document for the methodology.  Rather than having everything in a single script, the code is divided in a series of separate scripts that should be run sequentially.  

Methodological approach
----------

[1. Occurrence data processing](./Occurrences/README.md)  
The process of data random allocation to training and testing sets used for model calibration and validation, respectively, is described. 

[2. Remote sensing and climate data](https://github.com/lucianolasala/Wild_boar_ENM/blob/main/GEE%20raster%20processing/BioClim_Anual%20precipitation.md)  
Clould computing using Google Earth Engine (https://earthengine.google.com/) is described for each of the variables included in model calibration and projection. 

[3. Raster layers processing](./Environmental-data-processing.R)

[4. Model calibration](./calibration/calibration.md)

[5. Model validation](./Validation/README.md)

[5. Plots](./plots)
