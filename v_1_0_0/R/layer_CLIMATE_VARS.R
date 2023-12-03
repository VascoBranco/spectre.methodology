############################################################################
############################################################################
########################## Climate layers ##################################
############################################################################
############################################################################
# Background -------------------------------------------------------------------
# This script describes the methodology to create:

# TEMP_TRENDS. A continuous metric of temperature trends, based on the linear
# regression coefficients of mean monthly temperature for the years of 1950 to
# 2019.

# TEMP_SIGNIF. Continuous metric of temperature trend significance, the
# temperature trends divided by its standard error.

# CLIM_EXTREME. Continuous metric calculated as whatever is the largest of the
# absolute of the trend coefficients of the months with the lowest or highest
# mean temperatures.

# CLIM_VELOCITY. Continuous metric of the velocity of climate change, the ratio
# between TEMP_TRENDS and a local spatial gradient in mean temperature
# calculated as the slope of a plane fitted to the values of a 3x3 cell 
# neighbourhood centered on each pixel.

# ARIDITY_TREND. Continuous metric of aridity trends, based on the linear
# regression coefficients of aridity for the years of 1990 to 2019,
# i.e: MPET/(MPRE+1).

# Packages needed --------------------------------------------------------------
library(terra)

library(ClusterR)
library(doParallel)
library(gtools)

# Process ----------------------------------------------------------------------
worldClim = terra::rast("worldClim_30s_lakes.tif")

setwd("/media/witch-king-of-angmar/magus-tower/SPECTRE_WORKSPACE/R Space/")

# Prep work - Unpacking CRU climate data ---------------------------------------

# Here we unpack the CRU surface temperature data by getting all bands corresponding
# to our years of interest.
# Details:

# var_id: tmp
# units: degrees Celsius
# long_name: near-surface temperature
# names: near-surface temperature

# For the sake of simplicity we will give a non NA value to the NAs in our dataset
# as NAs will create problems when doing calculations. We can do this because the
# CRU dataset is consistent in their NA cells across all layers used.

#temp_stack = stack()
cmatrix = matrix(data = c(0, NA), nrow = 1, ncol = 2, byrow = TRUE)
for (i in 1:1428){
  # In our research we focus on anthropocene impacts so we will just use
  # bands respective to that general time frame (>1081 from 1428 total).
  # Regardless, here we will save all layers to two different folders, just in
  # case we want to run some analyses on pre-anthropocene years later. 
  temp_test = terra::rast("./climate layers/cru_ts4.04.1901.2019.tmp.dat.nc", band = i)
  temp_test = terra::classify(temp_test, cmatrix)
  if (i >= 1081){
    new_entry = terra::writeRaster(temp_test, paste("./tmp_separated_NA/anthropocene/test_layer_", i, ".tif", sep=""))
  } else {
    new_entry = terra::writeRaster(temp_test, paste("./tmp_separated_NA/pre-anthropocene/test_layer_", i, ".tif", sep=""))
  }
}


# Prep work - Construct mean rasters (temp_stack) ------------------------------

# Now that we have our bands in their own folder we run this short code that 
# collects monthly anthropocene temp data (sequence is for this purpose) and
# performs the yearly average.

mean_stack = stack() 
year_sequence = seq(1080, 1428, 12)[1:29]
for (j in 1:29){
  monthly_sequence = c((year_sequence[j]+1):(year_sequence[j]+12))
  
  for (i in monthly_sequence){
    open_raster = raster(paste("./climate layers/tmp_separated/anthropocene/test_layer_", 
                               i, ".tif", sep = ""))
    mean_stack = stack(mean_stack, open_raster)
  }
  
  average_yearly_temperature = calc(mean_stack, fun = mean,
                                    paste("tmp_separated/", 
                                          "anthropocene_year_means/year_", 
                                          j, ".tif", sep = "")
                                    )
}


# Prep work - Collect mean rasters (temp_stack) --------------------------------

# Collect all yearly mean temperature rasters to a rasterstack.
temp_stack = terra::rast(gtools::mixedsort(dir("./climate layers/tmp_separated/anthropocene_year_means", full.names = T)))


# 5.1 Temperature trends -------------------------------------------------------
# This is the first analysis performed. Temperature trend is the slope of a
# regression between all yearly means. Intermediate product.
time <- 1:dim(temp_stack)[3]
lm_fun <- function(x) {
  lm(x ~ time)$coefficients[2]
}

temp_trend <- terra::app(temp_stack, fun = lm_fun)

temp_trend_res <- terra::resample(temp_trend, worldClim,
  filename = paste0(
    "./climate layers/output/",
    "5_1_TEMP_TRENDS_intermediate.tif"
  ),
  method = "bilinear",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"),
  overwrite = FALSE, NAflag = -3.4e+38
)

temp_trend_res <- terra::mask(temp_trend_res, worldClim,
  filename = paste0("./output/", "5_1_TEMP_TRENDS.tif"),
  datatype = "FLT4S", filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

# 5.2 Temperature significance -------------------------------------------------
# This is the second analysis performed. Temperature divergence is the slope of
# a regression between all yearly means divided by its standard error (square
# root of mean of residuals squared). Intermediate product.
time <- 1:dim(temp_stack)[3]
lm_fun <- function(x) {
  a <- lm(x ~ time)
  b <- a$coefficients[2]
  c <- sqrt(mean(a$residuals * a$residuals))
  return(b / c)
}

temp_significance_yearly <- terra::app(temp_stack, fun = lm_fun)

temp_significance_yearly_res <- terra::resample(temp_significance_yearly,
  filename = "./output/5_2_TEMP_SIGNIF.tif",
  worldClim, method = "bilinear",
  datatype = "FLT4S", filetype = "GTiff",
  gdal = c("COMPRESS=LZW"),
  overwrite = FALSE, NAflag = -3.4e+38
)

temp_significance_yearly_res <- terra::mask(temp_significance_yearly_res, worldClim,
  filename = "./output/5_2_TEMP_SIGNIF_2.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = TRUE,
  NAflag = -3.4e+38
)

# 5.3 Climate extremes --------------------------------------------------------

# Needs revision

# This is the third analysis performed. Temperature divergence is the greatest 
# of the absolute values of the trend coefficients of the months with the
# lowest or highest mean temperatures. 

# For this purpose we'll select the layers for every year and get the max and min
# for each pixel create two sets of intermediate layers.
warmest_or_coldest <- "warmest"

year_sequence <- seq(1080, 1428, 12)[1:29]
for (i in 1:length(year_sequence)) {
  mean_stack <- stack()
  monthly_sequence <- c((year_sequence[i] + 1):(year_sequence[i] + 12))
  mean_stack <- terra::rast(
    paste("./climate layers/tmp_separated/anthropocene/test_layer_", monthly_sequence, ".tif", sep = "")
  )
  if (warmest_or_coldest == "warmest") {
    terra::app(mean_stack,
      fun = max,
      paste("./climate layers/tmp_separated/anthropocene_year_mean_of_warmest_months/year_", i, ".tif", sep = ""),
      datatype = "FLT4S",
      filetype = "GTiff",
      gdal = c("COMPRESS=LZW"), overwrite = FALSE,
      NAflag = -3.4e+38
    )
  } else if (warmest_or_coldest == "coldest") {
    terra::app(mean_stack,
      fun = min,
      paste("./climate layers/tmp_separated/anthropocene_year_mean_of_coldest_months/year_", i, ".tif", sep = ""),
      datatype = "FLT4S",
      filetype = "GTiff",
      gdal = c("COMPRESS=LZW"), overwrite = FALSE,
      NAflag = -3.4e+38
    )
  }
}

# Now we'll take the intermediate layers described above and make two separate
# regressions: WARMEST_MONTHS_TREND and COLDEST_MONTHS_TREND
warmest_or_coldest <- "warmest"
path <- paste0("./climate layers/tmp_separated/anthropocene_year_mean_of_", warmest_or_coldest, "_months")
temp_stack <- terra::rast(gtools::mixedsort(dir(path, full.names = TRUE)))

lm_fun <- function(x) {
  lm(x ~ c(1:29))$coefficients[2]
}

temperature_trend <- terra::app(
  x = temp_stack, fun = lm_fun,
  filename = paste0(
    "./climate layers/output/",
    toupper(warmest_or_coldest),
    "_MONTHS_TREND_YEARLY.tif"
  ),
  wopt = list(
    datatype = "FLT4S",
    filetype = "GTiff",
    gdal = c("COMPRESS=LZW"),
    NAflag = -3.4e+38
  ),
  overwrite = TRUE
)

# Now we load absolute versions of our layers into a raster stack.

extremes_stack <- c(
  sqrt(terra::rast("./climate layers/intermediates/WARMEST_MONTHS_TREND_YEARLY.tif")^2),
  sqrt(terra::rast("./climate layers/intermediates/COLDEST_MONTHS_TREND_YEARLY.tif")^2)
)

change_in_extremes <- terra::app(extremes_stack,
  fun = max,
  wopt = list(
    datatype = "FLT4S",
    filetype = "GTiff",
    gdal = c("COMPRESS=LZW"),
    NAflag = -3.4e+38
  ),
  overwrite = FALSE
)

change_in_extremes_res <- terra::resample(change_in_extremes,
  filename = "./climate layers/intermediates/CLIM_EXTREME_IM1.tif",
  worldClim, method = "bilinear",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"),
  overwrite = TRUE, NAflag = -3.4e+38
)

terra::mask(change_in_extremes_res, worldClim,
  filename = "./output/5_3_CLIM_EXTREME.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = TRUE,
  NAflag = -3.4e+38
)

# 5.4 Climate velocity -------------------------------------------------------------

## Spatial gradient raster 

# The spatial gradient raster is process intensive so the following code uses
# parallel processing to calculate it in pre-determined segments that are easier
# to achieve and save our progress.
# A draft version of this script has a smaller scale example, in case it's ever
# needed.

# Register our cores
# use_cores = detectCores() - 2
use_cores = 6
cl = makeCluster(use_cores)
registerDoParallel(cl)

# As our input for creating the spatial gradient raster, we are using mean
# monthly land surface temperature from MODIS between 2000 and 2020. The 2000/01 layer
# is missing in the original dataset (we have 251 layers total as opposed to 252)
# Furthermore, this layer only considers pixels with more than 100 out of the 
# total 251. Additional information on this step can be provided in the future.  
input_test_raster = terra::rast("./climate layers/output_new_clim/ALL_YEARS_LST_MORE_THAN_100.tif")
cellsize = 5.565

# Here interval will be two integer specifying rows. the following parallel loop
# will create the spatial gradient, row by row. We set it here to the first 100
# rows, as an example
interval = 0:100
spatial_gradient = foreach(r = interval, .combine = rbind) %dopar% {
  library(raster)
  row_vec = c()
  for (c in 1:ncol(input_test_raster)){
    
    if (is.na(input_test_raster[r,c])){
      #spatial_gradient = NA
      row_vec = c(row_vec, NA)
    } else {
      cell_values = c()
      for (x in 1:-1){
        val = sapply(1:-1, function(y){suppressWarnings(input_test_raster[r-x, c-y])})
        val[is.na(val)] = input_test_raster[r,c]
        cell_values = c(cell_values, val)
      }
      cell_values = matrix(cell_values, nrow = 3, ncol = 3, byrow = TRUE)
      
      dz_dx = ( (cell_values[1,3] + 2*cell_values[2,3] + cell_values[3,3]) -
                  (cell_values[1,1] + 2*cell_values[2,1] + cell_values[3,1]) ) / (8 * cellsize)
      
      dz_dy = ( (cell_values[3,1] + 2*cell_values[3,2] + cell_values[3,3]) - 
                  (cell_values[1,1] + 2*cell_values[1,2] + cell_values[1,3])) / (8 * cellsize)
      # add the spatial gradient
      row_vec = c(row_vec, atan( sqrt( (dz_dx)^2 + (dz_dy)^2) ) )
    }
    
  }
  return (row_vec)
}
write.csv(spatial_gradient, paste0("./climate layers/intermediates",
                                   "/spatial_gradient/spatial_grad_", interval[1], 
                                   "_", interval[length(interval)], ".csv"))



# After we have all raster segments completed we can put them back together
all_slices <- matrix(nrow = 0, ncol = 7200)
for (x in gtools::mixedsort(dir("./climate layers/intermediates/spatial_gradient/", full.names = T))) {
  open_slice <- read.csv(x)
  open_slice <- open_slice[1:nrow(open_slice), 2:ncol(open_slice)]
  all_slices <- rbind(all_slices, open_slice)
}

all_raster <- terra::rast(x = as.matrix(all_slices))
terra::ext(all_raster) <- c(-180, 180, -60, 90)
plot(all_raster)
terra::writeRaster(all_raster, "./climate layers/intermediates/LOCAL_SPATIAL_GRADIENT_NEW.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)

## Joining the local spatial gradient with the temperature trends

# FINAL PRODUCT
temp_trend <- terra::rast("./output/5_1_TEMP_TRENDS.tif")
temp_trend_norm <- (temp_trend - temp_trend@ptr$range_min) / (temp_trend@ptr$range_max - temp_trend@ptr$range_min)

spatial_grad_res = terra::rast("./climate layers/output/1_0_LOCAL_SPATIAL_GRADIENT_NA.tif")
spatial_grad_norm = (spatial_grad_res - spatial_grad_res@ptr$range_min)/(spatial_grad_res@ptr$range_max-spatial_grad_res@ptr$range_min)

clim_velocity = temp_trend_norm/(spatial_grad_norm + 1)
terra::plot(clim_velocity)

terra::writeRaster(clim_velocity, "./output/5_4_CLIM_VELOCITY.tif",
            datatype ="FLT4S",
            filetype = "GTiff",
            gdal = c("COMPRESS=LZW"), overwrite = FALSE,
            NAflag = -3.4e+38)

# 5.5 Aridity trend ----------------------------------------------------------------
# This is the last analysis performed. The aridity index is the trend 
# coefficients of aridity, here defined as:
# MPET/(MPRE+1), 
# MPET being the mean potential evapotranspiration in a month
# and MPRE the mean precipitation in a month

# var_id: pet
# long_name: potential evapotranspiration
# units: mm/day
# names: potential evapotranspiration

# var_id: pre
# long_name: precipitation
# units: mm/month
# names: precipitation

# We need to keep in mind that in the CRU dataset, MPET is in [mm day^-1]
# while MPRE is in [mm month^-1]. For this reason we have to multiply
# the opened PET rasters by 30.44 to approximate a monthly value.
# In our case we have already performed this step during a process similar to
# what is described under UNPACK ALL THE BANDS
pet_files <- gtools::mixedsort(dir("./climate layers/pet_separated/anthropocene"))
for (x in 1:length(pet_files)) {
  new_entry_pet <- terra::rast(paste("./climate layers/pet_separated/anthropocene/", pet_files[x], sep = ""))
  new_entry_pre <- terra::rast(paste("./climate layers/pre_separated/anthropocene/", pet_files[x], sep = ""))
  terra::writeRaster((new_entry_pet / (new_entry_pre + 1)),
    paste0("./climate layers/intermediates/aridity/aridity_", x, ".tif"),
    datatype = "FLT4S",
    filetype = "GTiff",
    gdal = c("COMPRESS=LZW"), overwrite = FALSE,
    NAflag = -3.4e+38
  )
}
aridity_files <- gtools::mixedsort(dir("./climate layers/intermediates/aridity", full.names = T))
aridity_stack <- terra::rast(aridity_files)

time <- 1:dim(aridity_stack)[3]
lm_fun <- function(x) {
  return(lm(x ~ time)$coefficients[2])
}

aridity_trend <- terra::app(aridity_stack,
  fun = lm_fun,
  wopt = list(
    datatype = "FLT4S",
    filetype = "GTiff",
    gdal = c("COMPRESS=LZW"),
    NAflag = -3.4e+38
  ),
  overwrite = FALSE
)

aridity_trend_res <- terra::resample(aridity_trend, worldClim,
  filename = "./output/5_5_ARIDITY_TREND_1.tif",
  method = "bilinear",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"),
  overwrite = TRUE, NAflag = -3.4e+38
)

aridity_trend_mask <- terra::mask(aridity_trend_res, worldClim,
  filename = "./output/5_5_ARIDITY_TREND_2.tif",
  datatype = "FLT4S",
  filetype = "GTiff",
  gdal = c("COMPRESS=LZW"), overwrite = FALSE,
  NAflag = -3.4e+38
)
