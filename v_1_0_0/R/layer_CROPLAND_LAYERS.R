################################################################################
################################################################################
############################### CROPLAND LAYERS ################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# The following script creates both the CROP_PERC_UNI and CROP_PERC_IASA. Both
# of these layers are metrics indicating the proportion of cropland [%] in each
# cell.

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("./UnifiedCroplandLayer.tif")
source_02 <- terra::rast("./IIASA Hybrid Cropland.tif")

# Process ----------------------------------------------------------------------
# CROP_PERC_UNI ----------------------------------------------------------------
crop_perc_uni_01 <- terra::resample(source_01, worldClim,
  method = "bilinear",
  filename = "./output/CROP_PERC_UNI_IM1.tif",
  datatype = "FLT4S", filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

crs(crop_perc_uni_01) = crs(worldClim)

crop_perc_uni_02 <- terra::mask(crop_perc_uni_01, worldClim,
  filename = "./output/CROP_PERC_UNI.tif",
  datatype = "FLT4S", filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

# CROP_PERC_IASA ---------------------------------------------------------------
crop_perc_uni_03 <- terra::resample(source_02, worldClim,
  method = "bilinear",
  filename = "./output/CROP_PERC_IASA.tif",
  datatype = "FLT4S", filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)