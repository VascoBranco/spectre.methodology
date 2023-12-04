################################################################################
################################################################################
################################# MINING_AREA ##################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# Mining density based on 50 cell radiuses around known mining properties. The
# original data by Sonter et al. isn't super clear on how they've organized
# their data. In short, they have separated their mining data into three
# raster layers: one has data for locations that have *only* critical resources,
# another has locations that have *only* critical resources and a third layer
# only has locations that have *both* types of resources.  

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim = terra::rast("./worldClim_30s_template.tif")
source_stack = terra::rast(
  c("./global_mining_areas_both.tif", 
    "./global_mining_areas_critical.tif",
    "./global_mining_areas_other.tif")
)

# Process ----------------------------------------------------------------------
# raster::calc can take a while to finish some times so you might want to
# consider using parallel processing. You can also further simplify this merge,
# this is just how we performed it.
mine_fun = function(i){ 
  if (sum(is.na(i)) == 3){
    return(0)
  } else {
    return(sum(i, na.rm = TRUE))
  }
  
}

mining_area_01 = terra::app(x = source_stack, fun = mine_fun,
                            filename = "./output/MINING_AREA_IM1.tif",
                            overwrite = TRUE,
                            wopt = list(
                              datatype ="FLT4S",
                              filetype = "GTiff",
                              gdal = c("COMPRESS=LZW"),
                              NAflag = -3.4e+38
                            )
)

mining_area_02 = terra::project(mining_area_01, to = worldClim,
                                 filename = "./output/MINING_AREA_IM2.tif",
                                 method = "near",
                                 datatype ="FLT4S",
                                 filetype = "GTiff",
                                 gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                                 NAflag = -3.4e+38)

mining_area_03 = terra::mask(mining_area_02, worldClim,
                      filename = "./output/MINING_AREA.tif",
                      datatype = "FLT4S",
                      filetype = "GTiff",
                      gdal = c("COMPRESS=LZW"), overwrite = FALSE,
                      NAflag = -3.4e+38)