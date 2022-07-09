## Niche Modeling for wild boar (*Sus scrofa*) in Argentina and neighboring countries

<img src="https://user-images.githubusercontent.com/20196847/82152923-d78ba600-983a-11ea-9bfc-2a9115a029f5.jpg" height="100" width="100" img align="right">

>**Luciano F. La Sala**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.  
**Julián M. Burgos**, Marine and Freshwater Research Institute, Reykjavik, Iceland.   
**Nicolás Caruso**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina. 

This repository contains R and Java scripts used for the development of an ecological niche model (henceforth ENM) for Wild boar (*Sus scrofa*) in Argentina and neighboring countries.
The repository is meand to serve as a dynamic document for other parties interested on the ecology of Wild boar and it will be updated as additional data is gathered and new methodological methods are developed. 
The code included is divided into a series of separate scripts that should be run sequentially.

A Maximum Entropy approach (https://biodiversityinformatics.amnh.org/open_source/maxent/) method was used inside the R programing environment (https://www.r-project.org/).

Table of Contents
----------

### Environmental data

[1. Geospatial data processing](./GEE_raster_processing/README.md)  
- [Remote sensing products](./GEE_raster_processing/Data_processing)

[2. Distance to water bodies](./Scripts/Distance_to_water.md)

### Occurrence data, model calibration and evaluation

[3. Occurrence data & model setup](./Scripts/Occurrence_data_&_model_setup.md)

[4. Model calibration, evaluation & projection](./Scripts/Calibration_evaluation_&_projection.md)

[5. Model averaging](./Scripts/Model_averaging.md)

[6. Model thresholding](./Scripts/Model_thresholding.md)

[7. Extrapolation risk](./Scripts/Extrapolation_risk.md)

[8. Mapping](Scripts/Mapping.md)

[9. Model validation](./Validation/README.md)


----------
> Suggested citation: La Sala LF, Burgos JM, Caruso N (2021) Niche Modeling for wild boar (*Sus scrofa*) in Argentina and neighboring countries. DOI: https://zenodo.org/badge/375789827.svg) 