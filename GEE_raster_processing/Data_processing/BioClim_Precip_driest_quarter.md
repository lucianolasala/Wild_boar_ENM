### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var Precip_driest_quarter = ee.Image('WORLDCLIM/V1/BIO')
.select('bio17')
.clip(M)

// Create palette

var visParams = {
  min: 7.0,
  max: 276.9,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Create region

var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = Precip_driest_quarter.bandNames();
print("Band names: ", bandNames);

// Get scale in meters

var scale = Precip_driest_quarter.select("bio17").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(Precip_driest_quarter, visParams, 'Precip driest quarter M');

Export.image.toDrive({
  image: Precip_driest_quarter,
  description: "BioClim_Precip_driest_quarter_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
  ´´´
