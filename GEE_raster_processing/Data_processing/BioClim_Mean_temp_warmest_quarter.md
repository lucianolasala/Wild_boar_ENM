### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var Mean_temp_warmest_quarter = ee.Image('WORLDCLIM/V1/BIO')
.select('bio10')
.clip(M)

var corrected = Mean_temp_warmest_quarter.divide(10);

// Palette creation

var visParams = {
  min: 5.0,
  max: 24.2,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Region creation

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = Mean_temp_warmest_quarter.bandNames();
print("Band names: ", bandNames);

// Get scale in meters

var scale = Mean_temp_warmest_quarter.select("bio10").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(corrected, visParams, 'Mean_temp_warmest_quarter M');

Export.image.toDrive({
  image: corrected,
  description: "BioClim_Mean_temp_warmest_quarter_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
  ´´´