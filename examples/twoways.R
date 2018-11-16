## What is a raster? 
m <- matrix(c(seq(0, 0.5, length = 5), 
            seq(0.375, 0, length = 4)), 3)
library(raster)
library(dplyr)
colpal <- function(n = 26, drop = 5) sf::sf.colors(n)[-seq_len(drop)]
plot_values <- function(x) {
  plot(x, axes = FALSE, main = "value", box = FALSE, col = colpal()); 
  text(coordinates(x), label = values(x))
  plot(extent(x), add = TRUE)
}
plot_cells <- function(x) {
  plot(x, axes = FALSE, main = "cell", legend = FALSE, box = FALSE, col = colpal()); 
  plot(extent(x), add = TRUE)
  text(coordinates(x), label = sprintf("[%i]", seq_len(ncell(x))), cex = 0.8)
}
r <- setExtent(raster(m), extent(0, ncol(m), 0, nrow(m)))
op <- par(mfcol = c(1, 2))
plot_values(raster(m))
plot_cells(raster(m))
par(op)

plot_edges <- function(x, main = "") {
  sc <- silicate::SC(spex::polygonize(x))
  e <- silicate::sc_edge(sc)
  v <- silicate::sc_vertex(sc)
  x0 <- e %>% dplyr::inner_join(v, c(".vx0" = "vertex_"))
  x1 <- e %>% dplyr::inner_join(v, c(".vx1" = "vertex_"))
  plot(rbind(x0, x1)[c("x_", "y_")], asp = 1, type = "n", 
       axes = FALSE, xlab = "", ylab = "", main = main)
  graphics::segments(x0$x_, x0$y_, x1$x_, x1$y_, lty = 2)
}
op <- par(mfcol = c(1, 2))
plot_edges(r, main = "points")
points(coordinates(r), col = colpal(10, drop = 1)[scales::rescale(values(r), c(1, 9))], pch = 19, cex = 1.5)
plot_edges(r, main = "field?")
rr <- setExtent(disaggregate(r, fact = 12, method = "bilinear"), extent(0.5, ncol(r) - 0.5, 0.5, nrow(r) - 0.5))

points(coordinates(rr), 
       col = colpal(10, drop = 1)[scales::rescale(values(rr), c(1, 9))],
       pch = 19, cex = 0.65)
points(coordinates(r), col = "black", bg = colpal(10, drop = 1)[scales::rescale(values(r), c(1, 9))], pch = 21, cex = 1.5)

par(op)



# two ways to think about raster data
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
