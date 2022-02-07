### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

Clould computing using Google Earth Engine (https://earthengine.google.com/) is described for each of the variables included in model calibration and projection.
For the present work, two different assets (i.e. calibration and projection areas) were defined using vector files (ESRI shapefiles). These areas were defined as M and G, respectively. In the code shown, remote sensing data are processed only for M by clipping each product to  that region. Codes for data processing corresponding to G are identical, with the only difference that G is used as the Google Earth Engine asset to define the area of interest.
Here, all the analyses were implemented using the Earth Engine API available in JavaScript. 

|Variable          |Band             |Reducer      |Spatial resol. |Temporal resol. |GEE snippet<sup>*</sup> |   
|------------------|-----------------|-------------| --------------|--------------- |----------------------- |
|Land surface temp.|LST_Day_1km      |Mean         |1 km           |2000-2020       |MODIS/006/MOD11A1       |
|                  |                 |Min.         |1 km           |2000-2020       |MODIS/006/MOD11A1       |
|                  |                 |Max.         |1 km           |2000-2020       |MODIS/006/MOD11A1       |
|Land surface temp.|LST_Night_1km    |Mean         |1 km           |2000-2020       |MODIS/006/MOD11A1       |
|                  |                 |Min.         |1 km           |2000-2020       |MODIS/006/MOD11A1       |
|                  |                 |Max.         |1 km           |2000-2020       |MODIS/006/MOD11A1       |
|Vegetation index  |EVI              |Mean         |1 km           |2000-2020       |MODIS/006/MOD13A2       |
|                  |                 |Min.         |1 km           |2000-2020       |MODIS/006/MOD13A2       |
|                  |                 |Max.         |1 km           |2000-2020       |MODIS/006/MOD13A2       |
|Global precip.    |precipitationCal |Anual mean   |0.1 deg.       |2000-2019	      |NASA/GPM_L3/IMERG_V06   |
|Evapotranspiration|Mean             |             |500 m.         |2002-2017       |CAS/IGSNRR/PML/V2       |
|and gross primary |                 |             |               |                |                        |
|product           |                 |             |        	     | 	              |                        |



<sup>*</sup>GEE (Google Earth Engine) collection snippets provide direct reference to data sources.  
