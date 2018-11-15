

elevate_triangles <- function(g, r) {
  ## assuming geometry of POLYGON
  sf::st_polygon(list(cbind(g[[1]], raster::extract(r, g[[1]]))))
}

elevate_sf <- function(x, r, exag = 1) {
  sf::st_set_geometry(x, sf::st_sfc(purrr::map(sf::st_geometry(x), elevate_triangles, r = r * exag), crs = sf::st_crs(x)))
}

## get sf data (in longlat)
nc <- sf::read_sf(system.file("shape/nc.shp", package="sf"))
bb <- sf::st_bbox(nc)
bb <- bb + c(-2, -2, 2, 2)
## get topo data (also longlat)
topo <- marmap::as.raster(marmap::getNOAA.bathy(bb["xmax"], bb["xmin"], bb["ymax"], bb["ymin"], 
                                                resolution = 2))
## sf POLYGON triangle for every element (a is *area* in native coordinates )
triangles <- sf::st_cast(sfdct::ct_triangulate(nc, a = .02))


library(mapdeck)
zfac <- 100
x <- elevate_sf(triangles, topo * zfac)

## my attempt at mapdeck XYZ triangle glory
mapdeck(token = Sys.getenv("MAPBOX_TOKEN"), style = 'mapbox://styles/mapbox/dark-v9', location = c(mean(bb[c("xmin", "xmax")]), mean(bb[c("ymin", "ymax")])), zoom = 5) %>% 
  add_polygon(data = x, layer_id = "polylayer") 


#jsonify::to_json( qm )

# IT'S SO FAST!
#
# This is really cool, but it brings me immediately to a meta-question I've been
# circling around. This example takes an example raster (from the marmap
# package), converts it to triangles and then to sf polygons, and then into
# mapdeck.


library(quadmesh)
data("hawaii", package = "marmap")
qm <- hawaii %>% 
  marmap::as.raster() %>% 
  #raster::aggregate(fact = 2) %>% 
  quadmesh()

## z exag
qm$vb[3, ] <- qm$vb[3, ] * 20
qm2sf <- function(x, crs = NA_character_) {
  tri <- if(is.null(x$it)) triangulate_quads(x$ib) else x$it
  psfc <- sf::st_sfc(lapply(split(rbind(tri, tri[1, ]),
                          rep(seq_len(ncol(tri)), each = 4))
                    , 
                    function(a) sf::st_polygon(list(t(qm$vb[, a])))), crs = crs)
  sf::st_sf(geometry = psfc, a = .colMeans(matrix(x$vb[3, tri], 3), 3, ncol(tri)))
}
p <- qm2sf(qm)
library(mapdeck)
mapdeck(token = Sys.getenv("MAPBOX_TOKEN"), style = 'mapbox://styles/mapbox/dark-v9', 
        location = c(mean(qm$vb[1, ]), mean(qm$vb[2, ])), zoom = 5) %>% 
  add_polygon(data = p, layer_id = "polylayer", fill_colour = "a" ) 


#
# Most everything here is fast, the only really slow parts are the checks that
# go on in `st_polygon` to ensure the polygon is closed -  no doubt this could
# be made much faster, and I'm very keen to discuss the fastest ways to convert
# set-based data like this from and to sf.
#
# (I usually hand-craft an sf-constructor for the case at hand, but I believe
# there are common forms we could use for that, your work in spatialwidget is a
# clear example.)
#
# But, my real question - do we really have to construct sf here?   I want to
# shortcut the pathway from raster or polygon+raster to these visualizations.
# Expanding triangles into 4-vertex polygons with no sharing doesn't seem like
# the right way to go. I also don't think mapdeck should have 'add_raster',
# 'add_raster_meshed_polygon', 'add_mesh3d', and so on - but maybe that's not a
# crazy idea, it would be better than having to expand everything into simple
# features.


