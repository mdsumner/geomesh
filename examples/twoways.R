# two ways to think about raster data

m <- matrix(c(1:8,7:1), 3)
library(raster)
r <- setExtent(raster(m), extent(0, ncol(m), 0, nrow(m)))
library(sf)
p <- spex::polygonize(r)
p$color_ <- colourvalues::colour_values(p$layer,  palette = t(col2rgb(palr::bathyDeepPal(10))))
plot(st_geometry(p), col = p$color_)

library(rgl)
library(anglr)
library(silicate)

tmp <- plot3d(copy_down(TRI(spex::polygonize(disaggregate(r, 4))), "layer"))
rgl.clear()
shade3d(tmp, alpha = 0.2)
rgl::aspect3d(1, 1, .2)

qm <- quadmesh::quadmesh(r)
tm <- qm
tm$it <- quadmesh::triangulate_quads(qm$ib)
tm$ib <- NULL
tm$primitivetype <- "triangle"
rgl::wire3d(tm, lwd = 4)
rgl::aspect3d(1, 1, .2)

rt <- geometry::delaunayn(coordinates(r))
triangles3d(cbind(coordinates(r), values(r))[rt, ])
library(rgl)
points3d(cbind(coordinates(r), values(r)), cex = 16)



p$color_ <- colourvalues::colour_values(p$layer, alpha = 0.5)
plot3d(copy_down(TRI(p), "layer"))
rgl::aspect3d(1, 1, .2)

