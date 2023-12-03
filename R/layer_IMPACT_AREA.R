################################################################################
################################################################################
################################# IMPACT_AREA ##################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Classification of land into very low impact areas (1), low impact areas (2) 
# and non-low impact areas (3). 

# Packages needed --------------------------------------------------------------
library(terra)

# Process ----------------------------------------------------------------------
# The original dataset is a bit confusing. In short: 128's are NA values, 0's 
# are positive classifications (e.g: the pixel is classified as low impact) and
# 100's are negative classifications (e.g: the pixel is not classified as low
# impact). We reorganize data so that in the end we have
# not low impact  - > 3
# low impact      - > 2
# very low impact - > 1
worldClim <- terra::rast("worldClim_30s_lakes.tif")

# Low impact -------------------------------------------------------------------
source_01 <- terra::rast("./layerConversion_input/Low_Impact.tif")

change_matrix_01 <- matrix(c(0, 2, 100, 3, 128, 0), nrow = 3, ncol = 2, byrow = T)

impact_area_01 <- terra::classify(source_01, change_matrix_01,
  filename = "./output/IMPACT_AREA_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)


# Very low impact --------------------------------------------------------------
source_02 <- terra::rast("./layerConversion_input/Very_Low_Impact.tif")

change_matrix_02 <- matrix(c(0, 1, 100, 0, 128, 0), nrow = 3, ncol = 2, byrow = T)

impact_area_02 <- terra::classify(source_02, change_matrix_02,
  filename = "./output/IMPACT_AREA_IM2.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

# Final ------------------------------------------------------------------------
# Calculate difference, reclassify NA's, project to our standard.
impact_area_03 <- impact_area_01 - impact_area_02

impact_area_04 <- terra::classify(impact_area_03, cbind(0, NA),
  filename = "./output/IMPACT_AREA_IM3.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

impact_area_05 <- terra::project(impact_area_04, worldClim,
  method = "near",
  filename = "./output/IMPACT_AREA.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  overwrite = FALSE,
  NAflag = -3.4e+38
)