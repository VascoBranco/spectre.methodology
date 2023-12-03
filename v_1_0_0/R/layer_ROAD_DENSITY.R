################################################################################
################################################################################
################################ ROAD_DENSITY ##################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Continuous metric of road density [m/km^2] from GRIPS.

# Packages needed --------------------------------------------------------------
library(raster)

# Process ----------------------------------------------------------------------
worldClim = terra::rast("./worldClim_30s_lakes.tif")
source_01 = terra::rast("./layerConversion_input/grip4_total_dens_m_km2.asc")
crs(source_01) = crs(worldClim)

road_density_01 = terra::resample(source_01, worldClim, method = "bilinear",
                           filename = "./output/ROAD_DENSITY_IM1.tif",
                           datatype ="FLT4S",
                           filetype = "GTiff",
                           gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                           NAflag = -3.4e+38)

change_matrix = matrix(c(-5, 0, 0), nrow = 1, ncol = 3)

road_density_02 = terra::classify(road_density_01, change_matrix,
                             filename = "./output/ROAD_DENSITY_IM2.tif",
                             datatype ="FLT4S", 
                             filetype = "GTiff",
                             gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                             NAflag = -3.4e+38)

road_density_03 = mask(road_density_02, worldClim,
                          filename = "./output/ROAD_DENSITY.tif",
                          datatype ="FLT4S",
                          format = "GTiff",
                          options = c("COMPRESS=LZW"), overwrite = FALSE,
                          NAflag = -3.4e+38)