################################################################################
################################################################################
################################ HUMAN_BIOMES ##################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Classification of land cover into different anthropogenic biomes of differing
# pressure such as dense settlements, villages and cropland. We present it as
# basically as a simplified classification, ordered by the general degree of
# impact that biome has on its surroundings. A large city has more impact in
# its surroundings than a village, for example.

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim <- terra::rast("./worldClim_30s_templates.tif")
source_01 <- terra::rast("./anthropogenic_biomes.tif")

# Process ----------------------------------------------------------------------

reclass_matrix <- matrix(ncol = 2, c(
  11, 5, 12, 5, 21, 4, 22, 4, 23, 4, 24, 4, 25, 4, 26, 4, 31, 3, 32, 3, 33, 3,
  34, 3, 35, 3, 41, 2, 42, 2, 43, 2, 51, 1, 52, 1, 61, 0, 62, 0, 63, 0
), byrow = T)

# We'll save each intermediate step to disk as it's generally faster. Feel free
# to do otherwise.

human_biomes_01 <- terra::classify(source_01, reclass_matrix,
  filename = "./output/HUMAN_BIOMES_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

human_biomes_02 <- terra::resample(human_biomes_01, worldClim,
  method = "near",
  filename = "./output/HUMAN_BIOMES_IM2.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

crs(human_biomes_02) = crs(worldClim)

# Mask with template for the final layer.
human_biomes_03 <- terra::mask(human_biomes_02, worldClim,
  filename = "./output/HUMAN_BIOMES.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)
