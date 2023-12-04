################################################################################
################################################################################
############################### FOOTPRINT_PERC #################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Metric indicating anthropogenic impacts [%] on the environment.

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("/wildareas-v3-2009-human-footprint.tif")

# Process ----------------------------------------------------------------------
footprint_perc_01 <- terra::project(source_01, worldClim,
                                   filename = "./output/FOOTPRINT_PERC_IM1.tif",
                                   datatype = "FLT4S",
                                   filetype = "GTiff",
                                   method = "bilinear",
                                   overwrite = FALSE,
                                   NAflag = -3.4e+38
)

footprint_perc_02 <- terra::classify(footprint_perc_01, rbind(c(128, NA)),
                         filename = "./output/FOOTPRINT_PERC_IM2.tif",
                         datatype = "FLT4S",
                         filetype = "GTiff",
                         gdal = c("COMPRESS=LZW"), overwrite = TRUE,
                         NAflag = -3.4e+38
)


footprint_perc_03 <- terra::mask(footprint_perc_02, worldClim,
                         filename = "./output/FOOTPRINT_PERC_IM3.tif",
                         datatype = "FLT4S",
                         filetype = "GTiff",
                         gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                         NAflag = -3.4e+38
)

footprint_perc_04 = footprint/terra::minmax(footprint_perc_03)[2] * 100

terra::writeRaster(footprint_perc_04,
                   filename = "./output/FOOTPRINT_PERC.tif",
                   datatype = "FLT4S",
                   filetype = "GTiff",
                   gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                   NAflag = -3.4e+38)