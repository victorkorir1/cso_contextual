#This script is used to add data dictionary layers into megapixels. Please make sure all of your raster data is reprojected and resampled accordingly.
# This script should be run following the "prep_data_layers_data_dict" has been executed.
# This script does not include LHZ or FEWS data. Those layers are qualitative and had to be added manually via QGIS by calculating their zonal modal values.
# Remember to change pathways where indicated. Once you have specified your pathways, you will only need to re-run by changing the 3 letter country code.

library(dplyr)
library(magrittr)
library(stars)
library(raster)
library(rgdal)
library(fasterize)

COUNTRY<- "AAA" # 3 letter country code
##
setwd(paste0("PATH TO DATA",COUNTRY)) #make sure this points to one step above your country folder,
list.files()


setwd("PATH TO DATA HERE") #Specify whether you want the whole country raster or masked rasters (masked is faster)
stunting<-raster("stunting.tif")
wasting<-raster("wasting.tif")
underweight<-raster("underweight.tif")
female_ed<-raster("female_ed.tif")
male_ed<-raster("male_ed.tif")
diff_ed<-raster("diff_ed.tif")
nightlights <-raster("nightlights.tif")
piped_water<-raster("piped_water.tif")
sanitation <-raster("sanitation.tif")
migration <-raster("migration.tif")
popd<- raster("popd.tif")
awe <-raster("awe.tif")
rwi<-raster("rwi.tif")
dep_ratio<-raster("dep_ratio.tif")
setwd('..') #return to the country folder

#load and process megapixels
megapixels<- readOGR(dsn="megapixels.geojson") 
megapixels$id<-seq_along(megapixels[,1])
megapixels_raster<- fasterize((st_as_sf(megapixels)),popd,field="id")
megapixels_mask <- function(x){x*(megapixels_raster>0)}
View(megapixels@data)

#calculate population for each megapixels and add them into megapixels
pop<- as.data.frame(zonal (popd,megapixels_raster,fun='sum'))
megapixels<-merge(megapixels,pop, by.x = 'id', by.y= 'zone')
megapixels@data <- rename(megapixels@data, pop = sum)
megapixels$pop<- round(megapixels$pop, digits = 0)


#create functions to weigh megapixel data by population
weight_zonal<- function(x){as.data.frame(zonal(x*popd,megapixels_raster,fun = 'sum'))} 
merge_megapixel<- function(y){merge(megapixels,y, by.x = 'id', by.y= 'zone')} 
value_megapixel<- function(x){round(x/megapixels$pop,digits=2)}  

##These lines apply the weights to each of the raster layers. If you wish to add more raster layers, copy and paste the code below accordingly.

zonal_female_ed<-weight_zonal(female_ed)
colnames(zonal_female_ed)[2] <- "female_ed_weighted"
megapixels<-merge_megapixel(zonal_female_ed)
megapixels$female_ed <- value_megapixel(megapixels$female_ed_weighted)
megapixels<- subset(megapixels, select = -(female_ed_weighted))

zonal_male_ed<-weight_zonal(male_ed)
colnames(zonal_male_ed)[2] <- "male_ed_weighted"
megapixels<-merge_megapixel(zonal_male_ed)
megapixels$male_ed <- value_megapixel(megapixels$male_ed_weighted)
megapixels<- subset(megapixels, select = -(male_ed_weighted))

zonal_stunting<-weight_zonal(stunting)
colnames(zonal_stunting)[2] <- "stunting_weighted"
megapixels<-merge_megapixel(zonal_stunting)
megapixels$stunting <- value_megapixel(megapixels$stunting_weighted)
megapixels<- subset(megapixels, select = -(stunting_weighted))

zonal_wasting<-weight_zonal(wasting)
colnames(zonal_wasting)[2] <- "wasting_weighted"
megapixels<-merge_megapixel(zonal_wasting)
megapixels$wasting <- value_megapixel(megapixels$wasting_weighted)
megapixels<- subset(megapixels, select = -(wasting_weighted))

zonal_underweight<-weight_zonal(underweight)
colnames(zonal_underweight)[2] <- "underweight_weighted"
megapixels<-merge_megapixel(zonal_underweight)
megapixels$underweight <- value_megapixel(megapixels$underweight_weighted)
megapixels<- subset(megapixels, select = -(underweight_weighted))

zonal_difference_ed<-weight_zonal(diff_ed)
colnames(zonal_difference_ed)[2] <- "difference_ed_weighted"
megapixels<-merge_megapixel(zonal_difference_ed)
megapixels$difference_ed <- value_megapixel(megapixels$difference_ed_weighted)
megapixels<- subset(megapixels, select = -(difference_ed_weighted))

zonal_nightlights<-weight_zonal(nightlights)
colnames(zonal_nightlights)[2] <- "nightlights_weighted"
megapixels<-merge_megapixel(zonal_nightlights)
megapixels$nightlights <- value_megapixel(megapixels$nightlights_weighted)
megapixels<- subset(megapixels, select = -(nightlights_weighted))

zonal_piped_water<-weight_zonal(piped_water)
colnames(zonal_piped_water)[2] <- "piped_water_weighted"
megapixels<-merge_megapixel(zonal_piped_water)
megapixels$piped_water <- value_megapixel(megapixels$piped_water_weighted)
megapixels<- subset(megapixels, select = -(piped_water_weighted))

zonal_sanitation<-weight_zonal(sanitation)
colnames(zonal_sanitation)[2] <- "sanitation_weighted"
megapixels<-merge_megapixel(zonal_sanitation)
megapixels$sanitation <- value_megapixel(megapixels$sanitation_weighted)
megapixels<- subset(megapixels, select = -(sanitation_weighted))

zonal_migration<-weight_zonal(migration)
colnames(zonal_migration)[2] <- "migration_weighted"
megapixels<-merge_megapixel(zonal_migration)
megapixels$migration <- value_megapixel(megapixels$migration_weighted)
megapixels<- subset(megapixels, select = -(migration_weighted))

zonal_awe<-weight_zonal(awe)
colnames(zonal_awe)[2] <- "awe_weighted"
megapixels<-merge_megapixel(zonal_awe)
megapixels$awe <- value_megapixel(megapixels$awe_weighted)
megapixels<- subset(megapixels, select = -(awe_weighted))

zonal_rwi<-weight_zonal(rwi)
colnames(zonal_rwi)[2] <- "rwi_weighted"
megapixels<-merge_megapixel(zonal_rwi)
megapixels$rwi <- value_megapixel(megapixels$rwi_weighted)
megapixels<- subset(megapixels, select = -(rwi_weighted))

zonal_dep_ratio<-weight_zonal(dep_ratio)
colnames(zonal_dep_ratio)[2] <- "dep_ratio_weighted"
megapixels<-merge_megapixel(zonal_dep_ratio)
megapixels$dep_ratio <- value_megapixel(megapixels$dep_ratio_weighted)
megapixels<- subset(megapixels, select = -(dep_ratio_weighted))

#write the megapixels as geojson
## you can change this to whichever format by altering the extension in file name and choosing a new driver
writeOGR(megapixels,paste0("/media/alex/LaCie/GIS/CSO/sample_data/",COUNTRY,"/",COUNTRY,"_megapixels1.geojson"),driver= "GeoJSON", layer='megapixels', overwrite_layer = TRUE)

#calculate national averages- creates a function to calculate averages of all raster values.
nat_avgs<-data.frame(COUNTRY)
nat_avg<- function(x){cellStats((x*popd),sum)/cellStats(popd,sum)}

setwd("whole_country_rasters") ##reset path to whole country rasters


nat_avgs$stunting<-nat_avg(stunting)
nat_avgs$wasting<-nat_avg(wasting)
nat_avgs$female_ed<-nat_avg(female_ed)
nat_avgs$male_ed<- nat_avg(male_ed)
nat_avgs$diff_ed<- nat_avg(diff_ed)
nat_avgs$nightlights<- nat_avg(nightlights)
nat_avgs$piped_water <- nat_avg(piped_water)
nat_avgs$sanitation <- nat_avg(sanitation)
nat_avgs$migration <- nat_avg(migration)
nat_avgs$awe<- nat_avg(awe)
nat_avgs$rwi<- nat_avg(rwi)
nat_avgs$dep_ratio <- nat_avg(dep_ratio)
nat_avgs$female_ed<-cellStats((female_ed*popd),sum)/cellStats(popd,sum)
nat_avgs$male_ed<-cellStats((male_ed*popd),sum)/cellStats(popd,sum)

getwd()
write.csv(nat_avgs,"national_average.csv")

