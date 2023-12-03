################################################################################
################################################################################
################################ FOREST_TREND ##################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# FOREST_TREND is a classification metric of 0 (no loss) or a discrete value
# from 1 to 17, representing loss (a stand-replacement disturbance or change
# from a forest to non-forest state) detected primarily in the year 2001–2019,
# respectively.
# This layer is based on ForestWatch data, which requires little transformation.
# The main challenge to us was the original resolution of the data
# (0.03 x 0.03 kms). Given their size, they are available to our knowledge only
# in map segments of 10 by 10 degrees. Hence, we need to merge these segments
# which is processing intensive.

# Packages needed --------------------------------------------------------------
library(terra)
library(red)
library(doParallel)
library(ClusterR)

# Process ----------------------------------------------------------------------
worldClim = terra::rast("worldClim_30s_lakes.tif")

# Resample all segments --------------------------------------------------------
f1 <- function(x) {
  sum(x == 0)
}

for (k in dir("./forestwatch/patches")) {
  source_01 <- terra::rast(paste("./forestwatch/patches/", k, sep = ""))

  use_cores <- detectCores() - 2
  beginCluster(use_cores)
  forest_trend_01 <- clusterR(
    x = source_01, fun = f1,
    filename = "./tmp_bab.tif", overwrite = TRUE
  )
  endCluster()

  # now let's go map segment by map segment and check if there's data. If there
  # isn't, lets skip it. If there is, we resample the map segment to our
  # standard.
  if (forest_trend_01@ptr$range_min != forest_trend_01@ptr$range_max ||
    (forest_trend_01@ptr$range_min == 0 && forest_trend_01@ptr$range_max == 0)) {
    new_ext <- terra::ext(source_01)
    template <- terra::rast(vals = 0, nrows = 1200, ncols = 1200, ext = new_ext)

    terra::resample(source_01, template,
      method = "near",
      paste("./forestwatch/res_patches_closest/patch_",
        new_ext[1], "_", new_ext[2], "_",
        new_ext[3], "_", new_ext[4], ".tif",
        sep = ""
      ),
      datatype = "FLT4S",
      filetype = "GTiff",
      gdal = c("COMPRESS=LZW"), overwrite = FALSE,
      NAflag = -3.4e+38
    )
  }
}

# Merge



# Resample all segments --------------------------------------------------------
# These are the last steps after taking the patches produced above and putting
# them together with the same method used for the FIRE_OCCUR layer. The layer we
# load under forest_trend_02 should look patchy with NA's where there was no
# information, such as in oceans.
forest_trend_02 <- terra::classify(
  terra::rast("./forestwatch/FW_segments.tif"),
  matrix(c(NA, 0), nrow = 1, ncol = 2, byrow = T)
)

forest_trend_03 <- terra::resample(forest_trend_02, worldClim,
  method = "near",
  filename = "./forestwatch/FOREST_TREND_IM1.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

forest_trend_04 <- terra::mask(forest_trend_03, worldClim,
  filename = "./forestWatch/FOREST_TREND.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)