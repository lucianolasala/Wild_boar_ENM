### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

```r
// Add shapefile of calibration area

Map.addLayer(M,{},'M');

var Mean_temp_coldest_quarter = ee.Image('WORLDCLIM/V1/BIO')
.select('bio11')
.clip(M)

var corrected = Mean_temp_coldest_quarter.divide(10);

// Palette creation

var visParams = {
  min: -5.8,
  max: 11.2,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};


// Create region

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = Mean_temp_coldest_quarter.bandNames();
print("Band names: ", bandNames);

// Get scale in meters

var scale = Mean_temp_coldest_quarter.select("bio11").projection().nominalScale();
print("Band scale: ", scale);


Map.addLayer(corrected, visParams, 'Mean_temp_coldest_quarter M');


Export.image.toDrive({
  image: corrected,
  description: "BioClim_Mean_temp_coldest_quarter_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
´´´

