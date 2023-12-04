################################################################################
################################################################################
########################### Human settlement layer #############################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# The following script creates both the HUMAN_DENSITY and BUILT_AREA, which
# are, respectively, a continuous metric of population density [persons/km^2] 
# and a percentage metric indicating built-up presence [%].

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_template.tif")
source_01 <- terra::rast("./GHS_POPULATION_2015_1KM.tif")
source_02 <- terra::rast("./GHS_BUILT_2018.tif")

# Process ----------------------------------------------------------------------

# HUMAN_DENSITY ----------------------------------------------------------------
human_density_01 <- terra::project(source_01, worldClim,
  filename = "./output/HUMAN_DENSITY_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  method = "bilinear",
  overwrite = FALSE,
  NAflag = -3.4e+38
)

human_density_02 <- mask(human_density_01, worldClim,
  filename = "./output/HUMAN_DENSITY.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

# BUILT_AREA -------------------------------------------------------------------
human_density_01 <- terra::project(source_02, worldClim,
  filename = "./output/BUILT_AREA_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  method = "bilinear",
  overwrite = FALSE,
  NAflag = -3.4e+38
)

human_density_02 <- mask(human_density_01, worldClim,
  filename = "./output/BUILT_AREA.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"),
  overwrite = FALSE,
  NAflag = -3.4e+38
)