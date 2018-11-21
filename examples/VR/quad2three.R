library(sf)
library(raster)
library(quadmesh)
library(r2vr)
library(dplyr)      ## as_data_frame
library(purrr)      ## transpose
library(tidyverse)  ## write_lines
e <- new("Extent", xmin = -399385.062565881, xmax = -395571.828168234, 
         ymin = -44988.0566170369, ymax = -42439.9607344968)
r <- raster::raster('../r2vr3_shading/data/ELVIS_CLIP.tif')
qm <- quadmesh(raster::crop(r, e))
## not necessarily good to store on same object, but tidy for now
## as we won't use as a mesh3d
qm$it <- quadmesh::triangulate_quads(qm$ib)

## write to JSON
#index0 <- as.matrix(sc$triangle[c(".vx0", ".vx1", ".vx2")])
#index0 <- 

source("../r2vr3_shading/helpers/trimesh_to_threejson.R")
mesh_json <- trimesh_to_threejson(vertices = t(qm$vb[1:3, ]), 
                                  face_vertices = t(qm$it))


write_lines(mesh_json, "nc.json")

## render in A-Frame
scale_factor <- 0.001
ground_height <- min(qm$vb[3, ])
height_correction <- -1 * (ground_height - mean(qm$vb[3, ]))

nc <- a_asset(id = "nc",
              src = "nc.json")

aframe_scene <-
  a_scene(.template = "basic",
          .title = "Uluru mesh, Mike's way",
          .description = "An A-Frame scene of Uluru",
          .children = list(
            a_json_model(src = nc,
                         material = list(color = '#C88A77'),
                         scale = scale_factor*c(1,1,1),
                         position = c(0,0 + height_correction * scale_factor ,-3),
                         rotation = c(-90, 180, 0))))
#aframe_scene$stop()

aframe_scene$serve()
