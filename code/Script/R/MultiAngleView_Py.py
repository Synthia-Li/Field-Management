
#python code

import Metashape
chunk = Metashape.app.document.chunk
T = chunk.transform.matrix
chunk.importShapes(path="C:\\Users\\xieji\\Desktop\\tem\\MyShapefile.shp",
                   replace=True, format=Metashape.ShapesFormatSHP)

chunk.shapes.updateAltitudes(chunk.shapes)

for point in chunk.shapes:
    p = point.geometry.coordinates[0]
    pT = T.inv().mulp(chunk.crs.unproject(p))
    chunk.addMarker(pT)

chunk.exportMarkers(path="C:\\Users\\KevinXie\\Desktop\\202211tem\\maker_summary.xml")



















### Archive
for shape in chunk.shapes:
		marker = chunk.addMarker(T.inv().mulp(shape.vertices[0]))
		projections = marker.projections.items()
		for proj in projections:
			camera = proj[0]
			vector = proj[1]
			fwriter.writerow([shape.label, camera.photo.path, vector.coord.x, vector.coord.y])
		chunk.remove(marker)














