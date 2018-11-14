library(raster)
library(quadmesh)
library(r2vr)
library(r2vr.gis)
library(dplyr)      ## as_data_frame
library(purrr)      ## transpose
e <- new("Extent", xmin = -399385.062565881, xmax = -395571.828168234, 
         ymin = -44988.0566170369, ymax = -42439.9607344968) + 1500
r <- crop(raster::raster('../r2vr3_shading/data/ELVIS_CLIP.tif'), e)

## generic scale
r <- setExtent(r, extent(0.1, 0.9, 0.1, 0.9))
r[] <- scales::rescale(r[], c(0.1, 0.9))

qm <- quadmesh(r)
## not necessarily good to store on same object, but tidy for now
## as we won't use as a mesh3d
qm$it <- quadmesh::triangulate_quads(qm$ib)

mesh_json <- r2vr.gis::trimesh_to_threejson(vertices = t(qm$vb[1:3, ]), 
                                  face_vertices = t(qm$it))
readr::write_lines(mesh_json, "a1_quad2three.json")

## render in A-Frame
# scale_factor <- 1
# ground_height <- 0
# height_correction <- 0

a1  <- a_asset(id = "a1",
              src = "a1_quad2three.json")

aframe_scene$stop()

zscale <- .1
aframe_scene <-
  a_scene(.template = "empty",
          .title = "Quad to three.js",
          .description = "An A-Frame scene of Uluru",
          .children = list(
            a_json_model(src = a1,
                         material = list(color = '#C88A77'),
                         scale = c(1, 1 / zscale, 1),
                         position = c(0, 1 + 2 * zscale, 0),
                         rotation = c(-90, 180, 90))))

## off RStudio server we need the host
aframe_scene$serve(host = "0.0.0.0")
