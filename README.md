# spectre.methodology

## Description
Repository for methods used in creating SPECTRE, a novel set of standardized, high-resolution global raster layers, each a potential threat to endangered species.

Check out SPECTRE at [LIBRe](https://biodiversityresearch.org/spectre/). There you can find a handy dashboard allowing for quick visualization of each layers and instructions on alternative ways of accessing SPECTRE, such as through [Paituli](https://paituli.csc.fi/). You can also check a versioned history of SPECTRE at Zenodo.

## Version history

| Version | Date |
| :----------------: | :------: |
| 1.0.0 (Initial release) | 05/12/2023 |

## Content table

The following are the scripts contained in the archive **./layer_scripts.zip** and the SPECTRE layers they cover:

| File | Content | File | Content |
| :----------------: | :------: | :----------------: | :------: |
| CLIMATE_VARS | 5.1, 5.2, 5.3, 5.4, 5.5 | HUMAN_BIOMES | 1.9 |
| CROPLAND_LAYERS | 1.11, 1.12 | HUMAN_SETTLEMENT | 1.3, 1.4 |
| FERTILIZER_KGHA | 3.2 | IMPACT_AREA | 1.7 |
| FOOTPRINT_PERC | 1.6 | LIGHT_MCDM2 | 3.1 |
| FOREST_LOSS_PERC | 2.1 | LIVESTOCK_MASS | 1.13 |
| FOREST_TREND | 1.10, 2.2 | MINING_AREA | 1.1 |
| HANPP | 2.3, 2.4 | MODIF_AREA | 1.8 |
| HAZARD_POTENTIAL | 1.2 | ROAD_DENSITY | 1.5 |

## Usage notes

* **SPL_001.tif** is a raster with the number of layers containing information (non-NA) for any given pixel.

* The archive **./file_scripts.zip** contains the scripts used to construct the majority of SPECTRE layers. A simple step by step run should be standard in most scripts. However, there are some exceptions, like some climate layers and fire occurrence layers. These were in some cases processed over a week and made use of the [Puhti](https://www.puhti.csc.fi/public/welcome.html) supercomputer available at the [CSC](https://www.csc.fi/).

