
#python code

import Metashape

shp_file_path = "D:\\temp\\root\\MockProject\\flight1\\ROI1\\set1\\SingleDCShapefile.shp"
ply_save_path = "D:\\temp\\root\\MockProject\\flight1\\ROI1\\set1\\test.ply"

chunk = Metashape.app.document.chunk
chunk.importShapes(path=shp_file_path,
                   replace=True, format=Metashape.ShapesFormatSHP)
chunk.shapes.updateAltitudes(chunk.shapes)
T = chunk.transform.matrix

for point in chunk.shapes:
	p = point.geometry.coordinates[0]
	pT = T.inv().mulp(chunk.crs.unproject(p))
	chunk.addMarker(pT)

paths_list = []
for marker in chunk.markers:
	cameras_filtered = marker.projections.keys()
	#cameras = [camera for camera in chunk.cameras if camera.selected and camera.type == Metashape.Camera.Type.Regular] #cameras to be moved
	paths = [camera.photo.path for camera in cameras_filtered] #camera paths
	paths_list = paths_list + paths

paths_list = list( dict.fromkeys(paths_list) )
print(paths_list)

# a intensive way
new_chunk = Metashape.app.document.addChunk()
new_chunk.addPhotos(paths_list)
new_chunk.matchPhotos(downscale=0, keypoint_limit=10000, keypoint_limit_per_mpx=10000, tiepoint_limit=4000,
                          generic_preselection=True, reference_preselection=False)
new_chunk.alignCameras()
new_chunk.buildDepthMaps(downscale=1, filter_mode=Metashape.MildFiltering)
new_chunk.buildDenseCloud()

new_chunk.exportPoints(path=ply_save_path, format=Metashape.PointsFormatPLY)

doc.remove(new_chunk)



######### test

new_chunk.importShapes(path = "D:\\temp\\root\\MockProject\\flight1\\ROI1\\set1\\boundary.shp",boundary_type=Metashape.Shape.OuterBoundary)

new_chunk.shapes.crs = new_chunk.crs

shapes = new_chunk.shapes
crs = shapes.crs
for shape in new_chunk.shapes:
	shape.boundary_type = Metashape.Shape.BoundaryType.NoBoundary

layer = new_chunk.shapes.addGroup()
layer.label = "Cropping boundary"
shape = shapes.addShape()
shape.label = "Cropping boundary"
shape.group = layer
shape.geometry.type = Metashape.Geometry.Type.PolygonType
shape.geometry = Metashape.Geometry.Polygon(coords)
shape.boundary_type = Metashape.Shape.BoundaryType.OuterBoundary

print("Shape created.")

task = Metashape.Tasks.DuplicateAsset()
task.asset_key = new_chunk.dense_cloud.key
task.asset_type = Metashape.DataSource.DenseCloudData
task.clip_to_boundary = True
task.apply(new_chunk)

new_chunk.dense_cloud.label = "Cropped dense cloud"





########
def crop_dense_cloud_by_shape():
	doc = Metashape.app.document
	chunk = doc.chunk
	if not chunk:
		print("Empty project, script aborted")
		return 0

	path = Metashape.app.getOpenFileName("Specify the input file with shape coordinates:", filter="*.txt")
	if not path:
		print("File not selected, script aborted.")
		return 0
	file = open(path, "rt")
	lines = file.readlines()
	if len(lines) < 3:
		print("Unable to create polygonal shape, script aborted")
		file.close()
		return 0
	coords = []
	for line in lines:
		if line.strip().startswith("#"):
			continue  # skipping commented lines
		if len(line.strip()) < 5:
			continue  # too short line
		try:
			x, y, z = line.strip().split(" ", 2)
			x = float(x)
			y = float(y)
			z = float(z)
		except:
			print("Something wrong while reading file, line:\n" + line + "\nScript aborted")
			file.close()
			return 0
		coords.append(Metashape.Vector([x, y, z]))
	file.close()
	if len(coords) < 3:
		print("Unable to create polygonal shape, script aborted")
		return 0

	if not chunk.shapes:
		chunk.shapes = Metashape.Shapes()
		if chunk.dense_cloud.crs:
			chunk.shapes.crs = chunk.dense_cloud.crs
		else:
			chunk.shapes.crs = chunk.crs
	shapes = chunk.shapes
	crs = shapes.crs
	for shape in chunk.shapes:
		shape.boundary_type = Metashape.Shape.BoundaryType.NoBoundary

	layer = chunk.shapes.addGroup()
	layer.label = "Cropping boundary"
	shape = shapes.addShape()
	shape.label = "Cropping boundary"
	shape.group = layer
	shape.geometry.type = Metashape.Geometry.Type.PolygonType
	shape.geometry = Metashape.Geometry.Polygon(coords)
	shape.boundary_type = Metashape.Shape.BoundaryType.OuterBoundary

	print("Shape created.")

	task = Metashape.Tasks.DuplicateAsset()
	task.asset_key = chunk.dense_cloud.key
	task.asset_type = Metashape.DataSource.DenseCloudData
	task.clip_to_boundary = True
	task.apply(chunk)

	chunk.dense_cloud.label = "Cropped dense cloud"

	print("Script finished")
	return 1


Metashape.app.addMenuItem("Custom menu/Crop dense cloud by shape", crop_dense_cloud_by_shape)	

### Archive
for shape in chunk.shapes:
		marker = chunk.addMarker(T.inv().mulp(shape.vertices[0]))
		projections = marker.projections.items()
		for proj in projections:
			camera = proj[0]
			vector = proj[1]
			fwriter.writerow([shape.label, camera.photo.path, vector.coord.x, vector.coord.y])
		chunk.remove(marker)














