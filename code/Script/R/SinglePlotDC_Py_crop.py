

########
def crop_dense_cloud_by_shape(path):
	doc = Metashape.app.document
	chunk = doc.chunk
	if not chunk:
		print("Empty project, script aborted")
		return 0

	#path = Metashape.app.getOpenFileName("Specify the input file with shape coordinates:", filter="*.txt")
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

#Metashape.app.addMenuItem("Custom menu/Crop dense cloud by shape", crop_dense_cloud_by_shape)
