library(raster)
library(rgdal)
library(sf)
library(fasterize)
library(dplyr)
library(tidyr)
library(tidyverse)
getwd()

#prep- create folders for "whole_country_rasters", "masked_rasters" and add "megapixels.geojson" to your desired output directory.
# This script should be run first, followed by the "megapixels_zonal" script afterwards.
# FEWS and LHZ data are not included in this script. They were processed separately through QGIS for inclusion into megapixels.
#  Megapixels.geojson must contain the megapixels you will use for analysis.
# Once you specify the directory paths, you can re-run this code, only changing the 3 letter country code.


COUNTRY<- "AAA" #be sure to replace this with the 3 letter country code

setwd(paste0("PATH TO OUTPUT DATA DIRECTORY",COUNTRY))
list.files()
megapixels<- readOGR(dsn="megapixels.geojson")
setwd(paste0("PATH TO DATA DICTIONARY HERE",COUNTRY)) 

#create AOI and a population mask- this will pull directly from the data dictionary
aoi<-raster("population_density/medn_popd.tif")
aoi_mask<- aoi>1 
plot(aoi) - ##run this if you want to test what the AOI data looks like

#create a function to resample the data to match the population mask and remove data from unpopulated pixels
resample_aoi <- function(x){aoi_mask*(raster::resample(x,aoi,method="bilinear"))}

#Get Data dictionary layers and resample them
popd<- aoi
stunting<- resample_aoi(raster("child_growth_failure/medn_stunting.tif"))
wasting<- resample_aoi(raster("child_growth_failure/medn_wasting.tif"))
underweight<- resample_aoi(raster("child_growth_failure/medn_underweight.tif"))
female_ed<-resample_aoi(raster("education/medn_female_edu.tif"))
male_ed<- resample_aoi(raster("education/medn_male_edu.tif"))
diff_ed<- resample_aoi(raster("education/medn_difference_edu.tif"))
nightlights <- resample_aoi(raster("nightlights/medn_lght.tif"))
piped_water<- resample_aoi(raster("sanitation/medn_piped_water.tif"))
sanitation <- resample_aoi (raster("sanitation/medn_sanitation_facilities.tif"))
migration <- resample_aoi(raster("migration/rcnt_migration.tif"))
awe <- resample_aoi(raster(paste0("wealth_index/",COUNTRY,"_AWE.tif")))
rwi<- resample_aoi(raster(paste0("wealth_index/",COUNTRY,"_rwi.tif")))

#add non data dictionary layers here. these are outside of the data dictionary so you will need to specify their paths below
dep_ratio <- resample_aoi(raster("PATH HERE")) 
lhz <- resample_aoi(raster("PATH HERE"))

layers_list_names<- c("popd","stunting","wasting","underweight","female_ed","male_ed","diff_ed","nightlights","piped_water","sanitation","migration","awe","rwi","dep_ratio","lhz")
layers_list<- c(popd,stunting,wasting,underweight,female_ed,male_ed,diff_ed,nightlights,piped_water,sanitation,migration,awe,rwi,dep_ratio,lhz)
names(layers_list)<- layers_list_names

setwd(paste0("PATH TO OUTPUT",COUNTRY)) ##Return back to the output directory

megapixels$id<-seq_along(megapixels[,1]) # format megapixels

# mask data to megapixels- this is important if your megapixel data is smaller than the whole country.

megapixels_raster<- fasterize((st_as_sf(megapixels)),aoi,field="id")
megapixels_mask <- function(x){x*(megapixels_raster>0)}

masked_list<-lapply(layers_list,megapixels_mask)
names(masked_list)<- layers_list_names
masked_list<- stack(masked_list)
getwd()
list.files()

#Write all data into rasters masked by the megapixels
writeRaster(stack(masked_list), paste0("masked_rasters/",names(masked_list)), bylayer = TRUE, format='GTiff')

#Write all data into rasters without the mask
writeRaster(stack(layers_list), paste0("whole_country_rasters/",names(layers_list)), bylayer = TRUE, format='GTiff')



