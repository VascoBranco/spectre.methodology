################################################################################
################################################################################
################################# LIGHT_MCDM2 ##################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Continuous simulated zenith radiance data [mcd/m^2].

# Packages needed --------------------------------------------------------------
library(terra)

# Process ----------------------------------------------------------------------
worldClim = terra::rast("./worldClim_30s_lakes.tif")

# PROCESSING
source_01 = terra::rast("./layerConversion_input/World_Atlas_2015_light.tif")

light_mcdm2 = terra::resample(source_01, worldClim, method = "bilinear",
                       filename = "./output/LIGHT_MCDM2.tif",
                       datatype = "FLT4S",
                       filetype = "GTiff",
                       gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                       NAflag = -3.4e+38)