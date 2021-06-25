### Google Earth Engine: a new cloud-computing platform for global-scale earth observation data and analysis

```r
// Add shapefile of Argentina

Map.addLayer(M,{},'M');

var Precip_coldest_quarter = ee.Image('WORLDCLIM/V1/BIO')
.select('bio19')
.clip(M)

// Palette creation
var visParams = {
  min: 7.9,
  max: 735.0,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};

// Create region
var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = Precip_coldest_quarter.bandNames();
print("Band names: ", bandNames);

// Get scale in meters
var scale = Precip_coldest_quarter.select("bio19").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(Precip_coldest_quarter, visParams, "Precip coldest quarter");

Export.image.toDrive({
  image: Precip_coldest_quarter,
  description: "BioClim_Precip_coldest_quarter_M",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
  ´´´