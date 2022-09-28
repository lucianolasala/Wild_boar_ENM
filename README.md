## Niche Modeling for wild boar (*Sus scrofa*) and feral pigs (*Sus scrofa domstica*) in the southern cone of South America

<img src="https://user-images.githubusercontent.com/20196847/82152923-d78ba600-983a-11ea-9bfc-2a9115a029f5.jpg" height="100" width="100" img align="right">

>**Luciano F. La Sala**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.  
**Julián M. Burgos**, Marine and Freshwater Research Institute, Reykjavik, Iceland.   
**Nicolás Caruso**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.   
**Camilo Bagnato**, Instituto de Investigaciones en Recursos Naturales, Agroecología y Desarrollo Rural, Río Negro, Argentina (IRNAD) (UNRN-CONICET).

This repository contains R and Java scripts used for the development of an ecological niche model (henceforth ENM) for Wild boar (*Sus scrofa*) and feral pigs (*Sus scrofa domstica*) in the southern cone of South America.
The repository is meant to serve as a dynamic document for other parties interested on the ecology of Wild boar and it will be updated as additional data is gathered and new methodological methods are developed. 
The code included is divided into a series of separate scripts that should be run sequentially.

A Maximum Entropy approach (https://biodiversityinformatics.amnh.org/open_source/maxent/) method was used inside the R programing environment (https://www.r-project.org/).

Table of Contents
----------

### Environmental data

[1. Geospatial data processing](./GEE_raster_processing/README.md)  
- [Remote sensing products](./GEE_raster_processing/Data_processing)

[2. Correct rasters](./Scripts/Correct_rasters.md)

[3. Distance to water bodies](./Scripts/Distance_to_water.md)

[4. Variable selection](./Scripts/Variable_selection.md)

### Occurrence data

[4. Occurrence data](./Scripts/Occurrence_data.md)

### Modelling

[5. Model calibration, evaluation & projection](./Scripts/Calibration_evaluation_&_projection.md)

[6. Model averaging](./Scripts/Model_averaging.md)

[7. Model thresholding](./Scripts/Thresholding.md)

[8. Extrapolation risk](./Scripts/Extrapolation_risk.md)

[9. Model validation](./Validation/README.md)

[10. Country-level analysis](./Scripts/Country_level_suitability.md)

[11. Ecoregions and biodiversity hotspots](./Scripts/Ecoregions_&_hotspots.md)

[12. Protected areas processing](./Scripts/Protected_areas_processing.md)

### Mapping

[13. Continuous models: countries](./Scripts/Mapping_countries_continuous.md)

[14. Binary models: countries](./Scripts/Mapping_countries_binary.md.md)

[15. Continuous models: ecoregions](./Scripts/Mapping_continuous_ecoregions.md)

[16. Continuous models: biodiversity hotspots ecoregions](./Scripts/Mapping_continuous_ecoregions.md)

[17. Binary models: biodiversity hotspots ecoregions](./Scripts/Mapping_continuous_ecoregions.md)

[18. Extrapolation risk analysis](./Ecoregions_models/)  

[19. Model uncertainty](./Ecoregions_models/)  

### Other plots

[20. Histograms of suitability in hotspots](./Scripts/Graphics.md)