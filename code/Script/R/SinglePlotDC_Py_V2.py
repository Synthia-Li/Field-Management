
#python code

import Metashape
#import SinglePlotDC_Py_crop

point_path = "D:\\temp\\root\\MockProject\\flight1\\ROI1\\set1\\SingleDCShapefile.shp"
ply_save_path = "D:\\temp\\root\\MockProject\\flight1\\ROI1\\set1\\test.ply"
boundary_path = "C:\\Users\\Administrator\\Desktop\\test.txt"


def SinglePlotDenseCloud(point_path, ply_save_path, boundary_path):

	chunk = Metashape.app.document.chunk
	chunk.importShapes(path = point_path, replace=True, format=Metashape.ShapesFormatSHP)
	chunk.shapes.updateAltitudes(chunk.shapes)
	T = chunk.transform.matrix

	for point in chunk.shapes:
		p = point.geometry.coordinates[0]
		pT = T.inv().mulp(chunk.crs.unproject(p))
		chunk.addMarker(pT)
		marker = chunk.markers[len(chunk.markers)-1]
		marker.label = "SingleDC" + str(len(chunk.markers))

	cam_list = []
	for marker in chunk.markers:
		if "SingleDC" in marker.label:
			#print("working")
			cameras_filtered = marker.projections.keys()
			cam_list = cam_list + cameras_filtered

	for cam in chunk.cameras:
		cam.enabled = False

	for cam in cam_list:
		cam.enabled = True

	chunk.buildDepthMaps(downscale=1, filter_mode=Metashape.MildFiltering)
	chunk.buildDenseCloud()

	crop_dense_cloud_by_shape(boundary_path)

	chunk.exportPoints(path=ply_save_path, format=Metashape.PointsFormatPLY)



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



































