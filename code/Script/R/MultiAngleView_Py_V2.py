
#python code

import Metashape
chunk = Metashape.app.document.chunk
T = chunk.transform.matrix
chunk.importShapes(path="C:\\Users\\xieji\\Desktop\\tem\\MyShapefile.shp",
                   replace=True, format=Metashape.ShapesFormatSHP)

chunk.shapes.updateAltitudes(chunk.shapes)

for shape in chunk.shapes:
    p = shape.geometry.coordinates[0]
    pT = T.inv().mulp(chunk.crs.unproject(p))
    chunk.addMarker(pT)
    chunk.markers[-1].label = shape.attributes["plot"]





chunk.exportMarkers(path="C:\\Users\\KevinXie\\Desktop\\202211tem\\maker_summary.xml")





## export orthomosaic
compression = Metashape.ImageCompression()
compression.tiff_compression = Metashape.ImageCompression.TiffCompressionLZW
compression.tiff_big = False
compression.tiff_overviews = False
compression.tiff_tiled = False
chunk.exportRaster(path = "C:\\Users\\xieji\\Desktop\\tem\\temtem\\tem_raster.tif",
				   save_alpha=False, image_compression = compression, description='JX')














### Archive
for shape in chunk.shapes:
		marker = chunk.addMarker(T.inv().mulp(shape.vertices[0]))
		projections = marker.projections.items()
		for proj in projections:
			camera = proj[0]
			vector = proj[1]
			fwriter.writerow([shape.label, camera.photo.path, vector.coord.x, vector.coord.y])
		chunk.remove(marker)












