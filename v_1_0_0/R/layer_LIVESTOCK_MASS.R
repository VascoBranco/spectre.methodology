################################################################################
################################################################################
############################### LIVESTOCK_MASS #################################
################################################################################
################################################################################
# Background -------------------------------------------------------------------
# LIVESTOCK_MASS is the estimated total amount of livestock wet biomass based 
# on global livestock head counts.

# It was created using a similar methodology to that described in 
# Bar-On et al. (2018). The average wet biomass values present in Dong et al. 
# (2006) are used to infer average wet biomass values for developed,
# transitioning and developing economies and the inferred values are combined
# with a country polygon vector map (Natural Earth, 2018) and a classification
# of world economies (United Nations, 2006) and then applied to 
# 2006 livestock count rasters from the Gridded Livestock of the World (GLW2)
# for cattle, chickens, ducks, goats, pigs and sheep, as to estimate total 
# livestock biomass. 

# Packages needed --------------------------------------------------------------
library(terra)

# Layers -----------------------------------------------------------------------
worldClim = terra::rast("worldClim_30s_template.tif")
source_01 = terra::rast((dir("./all_livestock_maps", full.names = T)))

# Process ----------------------------------------------------------------------
livestock_mass_01 = terra::classify(source_01, matrix(c(NA, 0), nrow = 1, ncol = 2, byrow = T))
livestock_mass_01 = terra::crop(livestock_mass_01, terra::ext(-180, 180, -60, 90))
# Average biomass values -------------------------------------------------------
# Here we will use the average wet biomass values present in Dong et al. (2006),
# to infer average wet biomass values for developed, transitioning and 
# developing economies
biomass_table = data.frame(Cattle = c(412.886, 214.61, 313.748),
                           Chickens = c(0.9, 0.9, 0.9), 
                           Ducks = c(2.7, 2.7, 2.7),
                           Goats = c(38.5, 30, 34.25),
                           Pigs = c(173.3, 28, 100.65),
                           Sheep = c(48.5, 28, 38.25),
                           row.names = c("Developed economies",
                                         "Developing economies", 
                                         "Transition economies"))
# Average biomass values -------------------------------------------------------
# Here we load a set of self-made rasters that determine the areas of different
# world economies. Classification of countries according to each economy follows
# already established UN classifications (United Nations, 2006). When this
# wasn't possible due to missing info, the closest neighbor was selected.
source_02 = terra::rast((dir("livestock_data/EconomyVectors/2006/Raster conversions", full.names = T)))

# Economy corrected biomass ----------------------------------------------------
for (c in 1:6){
  livestock_mass_02 = source_02 * biomass_table[,c]
  livestock_mass_03 = terra::app(livestock_mass_02, fun = sum, na.rm = TRUE)

  livestock_mass_04 = livestock_mass_01[[c]] * livestock_mass_03
  # It seems there are some incorrect points in the original dataset where we
  # have negative amounts of ducks. While we find the idea that one can measure
  # a lack of ducks very amusing, we will assume these are artifacts and 
  # re-assign them to zero.
  if(c == 3){
    livestock_mass_04 = terra::classify(livestock_mass_04,
                                   matrix(c(-5, 0, 0),
                                          nrow = 1, ncol = 3, byrow = T))
  }
  
  terra::writeRaster(livestock_mass_04,
              filename = paste( "./layerConversion_output/",
                     colnames(biomass_table)[c], "_global_biomass.tif", sep = "" ),
              datatype ="FLT4S",
              filetype = "GTiff",
              gdal = c("COMPRESS=LZW"), overwrite = TRUE,
              NAflag = -3.4e+38)
}



livestock_mass_05 = terra::rast((dir("./layerConversion_output/livestock_biomass_intermediates/", full.names = T)))
  
livestock_mass_06 = terra::app(livestock_mass_05, fun = sum)

crs(livestock_mass_06) = crs(worldClim)

livestock_mass_07 = terra::mask(livestock_mass_06, worldClim,
                          filename = "./LIVESTOCK_MASS.tif",
                          datatype ="FLT4S",
                          filetype = "GTiff",
                          gdal = c("COMPRESS=LZW"), overwrite = TRUE,
                          NAflag = -3.4e+38)  