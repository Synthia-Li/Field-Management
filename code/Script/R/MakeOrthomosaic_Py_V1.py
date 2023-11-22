#python code

import Metashape
import os

print(Metashape.app.activated)


image_folder = "D:\\2022_Fuyang_rice\\data\\raw\\KC_test_202208260828_正射影像"
psx_save_path = os.path.join(image_folder, "project.psx")
ortho_save_path = os.path.join(image_folder, "ortho.tif")
GCP_path = "C:\\Users\\Administrator\\Desktop\\GCP1-4-13-16.csv"

# 有RTK信息，使用Metashape.ReferencePreselectionSource
# 缺失RTK信息,使用Metashape.ReferencePreselectionEstimated
photo_align_preselection_mode = Metashape.ReferencePreselectionEstimated


def find_files(folder, types):
    return [entry.path for entry in os.scandir(folder) if (entry.is_file() and os.path.splitext(entry.name)[1].lower() in types)]

def GCP_adjust(chunk, GCP_file):

    file = open(GCP_file, "rt")  # input file

    photos_total = len(chunk.cameras)  # number of photos in chunk
    markers_total = len(chunk.markers)  # number of markers in chunk

    camera_list = list()
    for camera in chunk.cameras:
        camera_list.append(camera.label.upper())

    lines = file.readlines()

    for line in lines:
        if line[0] == "#":
            continue  # skipping commented lines
        if len(line.strip()) < 2:
            continue  # skipping empty lines
        # print(line)

        sp_line = line.split(",", 7)  # splitting read line by four parts

        x = float(sp_line[2])  # x- coordinate of the current projection in pixels
        y = float(sp_line[3])  # y- coordinate of the current projection in pixels
        x_coord = float(sp_line[4])  # x- coordinate of the marker
        y_coord = float(sp_line[5])  # y- coordinate of the marker
        z_coord = float(sp_line[6])  # x- coordinate of the marker

        camera_label = sp_line[1]  # camera label
        marker_name = sp_line[0]  # marker label

        flag = 0
        for marker in chunk.markers:  # searching for the marker (comparing with all the marker labels in chunk)
            if marker.label == marker_name:

                camera_index = camera_list.index(camera_label.upper())
                this_camera = chunk.cameras[camera_index]
                chunk.markers[-1].projections[this_camera] = Metashape.Marker.Projection(Metashape.Vector([x, y]), True)
                flag = 1
                break

        if not flag:
            chunk.addMarker()
            chunk.markers[-1].label = marker_name
            chunk.markers[-1].reference.location = Metashape.Vector([x_coord, y_coord, z_coord])

            camera_index = camera_list.index(camera_label.upper())
            this_camera = chunk.cameras[camera_index]
            chunk.markers[-1].projections[this_camera] = Metashape.Marker.Projection(Metashape.Vector([x, y]), True)

    file.close()

    chunk.optimizeCameras(adaptive_fitting=True, tiepoint_covariance=True)

    return(chunk)

def run(image_folder, psx_save_path, ortho_save_path, GCP_path, photo_align_preselection_mode):

        doc = Metashape.Document()
        doc.save(psx_save_path)

        chunk = doc.addChunk()
        photos = find_files(image_folder, [".jpg", ".jpeg", ".tif", ".tiff", ".png"])
        chunk.addPhotos(photos)

        #downscale: Highest = 0; High = 1; Medium = 2; Low = 4; Lowest = 8

        chunk.matchPhotos(downscale = 2, keypoint_limit=100000, keypoint_limit_per_mpx=0, tiepoint_limit=0,
                          reference_preselection_mode=photo_align_preselection_mode,
                          generic_preselection=False, reference_preselection=False)

        chunk.alignCameras()

        if GCP_path != 0:
            chunk = GCP_adjust(chunk, GCP_path)

        doc.save()

        chunk.buildDepthMaps(downscale = 8, filter_mode=Metashape.MildFiltering)

        #chunk.buildDenseCloud()

        chunk.buildModel(source_data=Metashape.DepthMapsData, face_count=Metashape.LowFaceCount)

        chunk.buildOrthomosaic()

        #chunk.exportPoints(path=ply_save_path, format=Metashape.PointsFormatPLY)

        ## export orthomosaic
        compression = Metashape.ImageCompression()
        compression.tiff_compression = Metashape.ImageCompression.TiffCompressionLZW
        compression.tiff_big = True
        compression.tiff_overviews = False
        compression.tiff_tiled = False
        chunk.exportRaster(path=ortho_save_path,
                           save_alpha=False, image_compression=compression, description='JX')

run(image_folder, psx_save_path, ortho_save_path, GCP_path, photo_align_preselection_mode)

# class Metashape.DataSource
# Data source in [PointCloudData, DenseCloudData, DepthMapsData, ModelData, TiledModelData, ElevationData, OrthomosaicData, ImagesData]






















### Archive
for shape in chunk.shapes:
		marker = chunk.addMarker(T.inv().mulp(shape.vertices[0]))
		projections = marker.projections.items()
		for proj in projections:
			camera = proj[0]
			vector = proj[1]
			fwriter.writerow([shape.label, camera.photo.path, vector.coord.x, vector.coord.y])
		chunk.remove(marker)














