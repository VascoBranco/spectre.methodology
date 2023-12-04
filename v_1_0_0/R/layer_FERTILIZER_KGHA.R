################################################################################
################################################################################
############################### FERTILIZER_KGHA ################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Continuous metric of kilograms of fertilizer used per hectare [kg/ha].

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("./global_fertilizer_application.tif")

# Process ----------------------------------------------------------------------
fertilizer_kgha <- terra::resample(source_01, worldClim,
  method = "bilinear",
  filename = "./output/FERTILIZER_KGHA.tif",
  datatype = "FLT4S", filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)