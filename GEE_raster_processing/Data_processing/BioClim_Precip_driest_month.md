### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var precip_driest_month = ee.Image('WORLDCLIM/V1/BIO')
.select('bio14')
.clip(M)

// Palette

var visParams = {
  min: 15.6,
  max: 373.6,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Create region

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = precip_driest_month.bandNames();
print("Band names: ", bandNames);

// Get scale in meters

var scale = precip_driest_month.select("bio14").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(precip_driest_month, visParams, 'Precip driest month M');

Export.image.toDrive({
  image: precip_driest_month,
  description: "BioClim_Precip_driest_month_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
  ´´´
