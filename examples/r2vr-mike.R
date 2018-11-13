library(silicate)
library(anglr)
library(sf)
library(r2vr)
library(dplyr)      ## as_data_frame
library(purrr)      ## transpose
library(tidyverse)  ## write_lines
#xsf <- st_transform(read_sf(system.file("gpkg/nc.gpkg", package = "sf")), "+proj=laea +lon_0=-80 +lat_0=34 +datum=WGS84")

#sc <- copy_down(DEL(xsf), gebco1)
e <- new("Extent", xmin = -399385.062565881, xmax = -395571.828168234, 
         ymin = -44988.0566170369, ymax = -42439.9607344968)
r <- raster::raster('../r2vr3_shading/data/ELVIS_CLIP.tif')
xsf <- spex::spex(raster::crop(r, e))

sc <- copy_down(DEL(xsf, max_area = 9740455 / 1e3), r)


## write to JSON
index0 <- as.matrix(sc$triangle[c(".vx0", ".vx1", ".vx2")])
#source("helpers/trimesh_to_threejson.R")
source("../r2vr3_shading/helpers/trimesh_to_threejson.R")
mesh_json <- trimesh_to_threejson(vertices = as.matrix(sc$vertex[c("x_", "y_", "z_")]), 
                                  face_vertices = matrix(match(index0, sc$vertex$vertex_), ncol = 3))

## this shows that it does work
# library(rgl)
# triangles3d(as.matrix(sc$vertex[c("x_", "y_", "z_")])[t(matrix(match(index0, sc$vertex$vertex_), ncol = 3)), ], col = "grey")
# rglwidget()

write_lines(mesh_json, "nc.json")

## render in A-Frame
scale_factor <- 0.001
ground_height <- min(sc$vertex$z_)
height_correction <- -1 * (ground_height - mean(sc$vertex$z_))

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
