################################################################################
################################################################################
#################################### HANPP #####################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# The following script creates both the NPPCARBON_GRAM and NPPCARBON_PERC, which
# are, respectively, the quantity of carbon (in grams) needed to derive food and
# fiber products (Human Appropriation of Net Primary Productivity, i.e. HANPP) 
# and HANNP as a percentage of local Net Primary Productivity.

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("./HANPP_carbon.tif")
source_02 <- terra::rast("./HANPP_percentage.tif")

# Process ----------------------------------------------------------------------
# The original dataset comes with some scaling issues that we have to fix for
# better data presentation. This includes our NA values not being classified as
# such (they show up as -3.402823e+38).

# NPPCARBON_GRAM ---------------------------------------------------------------
nppcarbon_gram_01 <- terra::classify(source_01 < 0, cbind(1, NA),
  filename = "./output/NPPCARBON_GRAM_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

nppcarbon_gram_02 <- terra::mask(source_01, nppcarbon_gram_01,
  filename = "./output/NPPCARBON_GRAM_IM2.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

nppcarbon_gram_03 <- terra::resample(nppcarbon_gram_02, worldClim,
  method = "bilinear",
  filename = "./output/NPPCARBON_GRAM_IM3.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

crs(nppcarbon_gram_03) = crs(worldClim)

nppcarbon_gram_04 <- terra::mask(nppcarbon_gram_03, worldClim,
  filename = "./output/NPPCARBON_GRAM.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

# NPPCARBON_PERC ---------------------------------------------------------------

nppcarbon_perc_01 <- terra::classify(source_02 < 0, cbind(1, NA),
  filename = "./output/NPPCARBON_PERC_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

nppcarbon_perc_02 <- terra::mask(source_02, nppcarbon_perc_01,
  filename = "./output/NPPCARBON_PERC_IM2.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

nppcarbon_perc_03 <- terra::resample(nppcarbon_perc_02, worldClim,
  method = "bilinear",
  filename = "./output/NPPCARBON_PERC_IM3.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

crs(nppcarbon_perc_03) = crs(worldClim)

nppcarbon_gram_04 <- terra::mask(nppcarbon_perc_03, worldClim,
  filename = "./output/NPPCARBON_PERC.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)