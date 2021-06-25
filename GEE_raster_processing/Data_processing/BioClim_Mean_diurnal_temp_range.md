### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var temp_range = ee.Image('WORLDCLIM/V1/BIO')
.select('bio02')
.clip(M)

var corrected = temp_range.divide(10) 

// Create palette

var visParams = {
  min: 8.6,
  max: 17.4,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Create region

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = temp_range.bandNames();
print("Band names: ", bandNames);

// Get scale in meters

var scale = temp_range.select("bio02").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(corrected, visParams, 'Annual Diurnal Temperature Range M');

Map.centerObject(M, 4)

Export.image.toDrive({
  image: corrected,
  description: "BioClim_Annual_Diurnal_Temperature_Range_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
´´´