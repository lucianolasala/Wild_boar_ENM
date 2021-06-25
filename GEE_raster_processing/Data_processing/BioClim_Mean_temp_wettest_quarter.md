### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var Mean_temp_wettest_quarter = ee.Image('WORLDCLIM/V1/BIO')
.select('bio08')
.clip(M)

var corrected = Mean_temp_wettest_quarter.divide(10);

// Palette creation

var visParams = {
  min: -8.1,
  max: 27.0,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Region creation 

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = Mean_temp_wettest_quarter.bandNames();
print("Band names: ", bandNames);

// Get scale in meters

var scale = Mean_temp_wettest_quarter.select("bio08").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(corrected, visParams, 'Mean temp wettest quarter M');

Export.image.toDrive({
  image: corrected,
  description: "BioClim_Mean_temp_wettest_quarter_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
  ´´´
