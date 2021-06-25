### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

```r
// Add shapefile of calibration area

Map.addLayer(G,{},'G');

var Mean_temp_driest_quarter = ee.Image('WORLDCLIM/V1/BIO')
.select('bio09')
.clip(G)

var corrected = Mean_temp_driest_quarter.divide(10);

// Palette creation

var visParams = {
  min: 2.8,
  max: 21.7,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};


// Region creation

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = Mean_temp_driest_quarter.bandNames();
print("Band names: ", bandNames);


// Get scale in meters

var scale = Mean_temp_driest_quarter.select("bio09").projection().nominalScale();

print("Band scale: ", scale);

Map.addLayer(corrected, visParams, 'Mean temp driest quarter');

Export.image.toDrive({
  image: corrected,
  description: "BioClim_Mean_temp_driest_quarter_G",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
  ´´´