### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var min_temp_coldest_month = ee.Image('WORLDCLIM/V1/BIO')
.select('bio06')
.clip(M)

var corrected = min_temp_coldest_month.divide(10);

// Palette creation

var visParams = {
  min: -7.1,
  max: 4.0,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Create region

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = min_temp_coldest_month.bandNames();
print("Band names: ", bandNames);

// Get scale in meters
var scale = min_temp_coldest_month.select("bio06").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(corrected, visParams, 'Min_temp_coldest_month');

Export.image.toDrive({
  image: corrected,
  description: "BioClim_Min_temp_coldest_month",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
´´´