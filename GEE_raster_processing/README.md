### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

Clould computing using Google Earth Engine (https://earthengine.google.com/) is described for each of the variables included in model calibration and projection.
For the present work, two different assets (i.e. calibration and projection areas) were defined using vector files (ESRI shapefiles). These areas were defined as M and G, respectively. In the code shown, remote sensing data are processed only for M by clipping each product to  that region. Codes for data processing corresponding to G are identical, with the only difference that G is used as the Google Earth Engine asset to define the area of interest.
Here, all the analyses were implemented using the Earth Engine API available in JavaScript. 

| Variable            | Band                | Reducer | GEE snippet 
|---------------------|:-------------------:|--------:|
| Land surface temp.  | LST_Day_1km         | Mean    | MODIS/006/MOD11A1
