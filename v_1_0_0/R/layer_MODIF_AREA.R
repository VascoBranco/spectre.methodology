################################################################################
################################################################################
################################# MODIF_AREA ###################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Continuous 0-1 metric that reflects the proportion of a landscape that has
# been modified.

# Packages needed --------------------------------------------------------------
library(raster)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("./global_human_modifications.tif")

# Process ----------------------------------------------------------------------
modif_area_01 <- project(source_01, worldClim, method = "bilinear")

terra::writeRaster(modif_area_01,
  filename = "./output/MODIF_AREA.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)
