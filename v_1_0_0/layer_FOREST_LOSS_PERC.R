################################################################################
################################################################################
############################## FOREST_LOSS_PERC ################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Continuous -100 to 100 metric of forest tree cover loss between 2007 and 2017
# using data from JAXA.
# For more, see: https://earth.jaxa.jp/en/data/2555/index.html
# The values 200 and 255 represent oceans and NA values respectively in the
# source data. We'll start by reclassifying them and then calculate forest
# cover differences between 2007 and 2017.

# Packages needed --------------------------------------------------------------
library(terra)

# Process ----------------------------------------------------------------------
source_01 = terra::rast("./layerConversion_input/JAXA_2007.tif")
source_02 = terra::rast("./layerConversion_input/JAXA_2017.tif")
worldClim = terra::rast("./worldClim_30s_lakes.tif")
JAXA_matrix = matrix(c(200, NA, 255, NA), nrow = 2, ncol = 2, byrow = T)

forest_loss_perc_01 = terra::classify(source_01, JAXA_matrix,
                                 filename = "./output/FOREST_LOSS_PERC_IM1.tif",
                                 datatype ="FLT4S", filetype = "GTiff",
                                 gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                                 NAflag = -3.4e+38)

forest_loss_perc_02 = terra::classify(source_02, JAXA_matrix,
                                 filename = "./output/FOREST_LOSS_PERC_IM2.tif",
                                 datatype ="FLT4S", filetype = "GTiff",
                                 gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                                 NAflag = -3.4e+38)

forest_loss_perc_03 = forest_loss_perc_01 - forest_loss_perc_02

forest_loss_perc_03 = terra::classify(forest_loss_perc_03, cbind(NA, -3.4e+38),
                                 filename = "./output/FOREST_LOSS_PERC_IM3.tif",
                                 datatype ="FLT4S", filetype = "GTiff",
                                 gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                                 NAflag = -3.4e+38)

forest_loss_perc_04 = terra::resample(forest_loss_perc_03, worldClim,
                               method = "bilinear", filename = "./output/FOREST_LOSS_PERC_IM4.tif",
                               datatype ="FLT4S", filetype = "GTiff",
                               gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                               NAflag = -3.4e+38)

forest_loss_perc_05 <- terra::mask(forest_loss_perc_04, worldClim,
                                 filename = "./output/FOREST_LOSS_PERC.tif",
                                 datatype = "FLT4S", filetype = "GTiff",
                                 gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                                 NAflag = -3.4e+38
)
