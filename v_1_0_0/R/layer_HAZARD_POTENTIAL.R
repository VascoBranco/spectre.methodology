################################################################################
################################################################################
############################## HAZARD_POTENTIAL ################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Number of significant hazards potentially affecting cells based on hazard
# frequency data. The multihazard dataset clumps together 0 value pixels with NA
# pixels so they need to be added again.

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("./GlobalMultiHazards.asc")

# Process ----------------------------------------------------------------------
change_matrix = matrix(nrow = 1, ncol = 2)
change_matrix[1,] = c(NA, 0)

hazard_potential_01 = terra::classify(source_01, change_matrix,
                                 datatype ="FLT4S", 
                                 filetype = "GTiff",
                                 gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                                 NAflag = -3.4e+38)

hazard_potential_02 = terra::resample(hazard_potential_01, worldClim, method = "near",
                               datatype ="FLT4S",
                               filetype = "GTiff",
                               gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                               NAflag = -3.4e+38)

crs(hazard_potential_02) = crs(worldClim)

hazard_potential_03 = terra:::mask(hazard_potential_02, worldClim,
                           filename = "./output/HAZARD_POTENTIAL.tif",
                           datatype ="FLT4S",
                           filetype = "GTiff",
                           gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                           NAflag = -3.4e+38)