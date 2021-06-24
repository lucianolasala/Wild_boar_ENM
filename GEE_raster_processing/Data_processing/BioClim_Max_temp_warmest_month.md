### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var max_temp_warmest_month = ee.Image('WORLDCLIM/V1/BIO')
.select('bio05')
.clip(M)

var corrected = max_temp_warmest_month.divide(10);

// Palette creation

var visParams = {
  min: 25.3,
  max: 33.3,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};


// Create region

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = max_temp_warmest_month.bandNames();
print("Band names: ", bandNames);


// Get scale in meters

var scale = max_temp_warmest_month.select("bio05").projection().nominalScale();
print("Band scale: ", scale);


Map.addLayer(corrected, visParams, 'Max_temp_warmest_month');


Export.image.toDrive({
  image: corrected,
  description: "BioClim_Max_temp_warmest_month",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
´´´ 



