# two ways to think about raster data

m <- matrix(c(1:5, 4:1), 3)
library(raster)
r <- setExtent(raster(m), extent(0, ncol(m), 0, nrow(m)))
library(sf)
p <- spex::polygonize(r)
p$color_ <- colourvalues::colour_values(p$layer,  palette = t(col2rgb(palr::bathyDeepPal(10))))
plot(st_geometry(p), col = p$color_)

library(rgl)
library(anglr)
library(silicate)
library(quadmesh)
tri <- copy_down(TRI(spex::polygonize(disaggregate(r, 4))), "layer")
tri$object$color_ <- colourvalues::colour_values(tri$object$layer)
tmp <- plot3d(tri)
rgl.pop()
rgl.clear()
shade3d(tmp, alpha = 0.5, specular = "black", col = "grey")
wire3d(tmp, col = "black", lwd = 2)
rgl::aspect3d(1, 1, .2)
bg3d("lightgrey")
# 
qm <- quadmesh::quadmesh(r)
#tm <- qm
#tm$it <- quadmesh::triangulate_quads(qm$ib)
#tm$ib <- NULL
#tm$primitivetype <- "triangle"

## the point of this part is to show the quads don't carry the z information well (it's ok with very fine quads)
rgl::wire3d(qm, lwd = 8, col = "green")

ptri <- geometry::delaunayn(coordinates(r))
t3d <- structure(list(vb = t(cbind(coordinates(r), values(r), 1)), it = t(ptri), 
            primitivetype = "triangle", material = list()), normals = NULL, texcoords = NULL,  
            class = c("mesh3d", "shape3d"))

rgl::wire3d(t3d, lwd = 10, col = "black")

# 
# rt <- geometry::delaunayn(coordinates(r))
# triangles3d(cbind(coordinates(r), values(r))[rt, ])
# library(rgl)
# points3d(cbind(coordinates(r), values(r)), cex = 16)
# 
# 
# 
# p$color_ <- colourvalues::colour_values(p$layer, alpha = 0.5)
# plot3d(copy_down(TRI(p), "layer"))
# rgl::aspect3d(1, 1, .2)
# 
