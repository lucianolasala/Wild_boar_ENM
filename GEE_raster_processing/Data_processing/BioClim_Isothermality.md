### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis  

```r 
// Add shapefile of calibration region
Map.addLayer(M,{},'M');

var isother = ee.Image('WORLDCLIM/V1/BIO')
.select('bio03')
.clip(M)


//Forma artesanal de definir paleta
var visParams = {
  min: 40,
  max: 70.3,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};


// Create region
var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = isother.bandNames();
print("Band names: ", bandNames);

// Get scale in meters
var scale = isother.select("bio03").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(isother, visParams, 'Isothermality');


Export.image.toDrive({
  image: isother,
  description: "Bioclim_Isothermality",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
´´´

