
library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(dplyr)
library(sf)

shape_files <- "../../inputs/shape_files/"
csv_files <- "../../inputs/csv_data/"
outputs <- "../../outputs/7_Samples_to_Species/"
script3outputs <- "../../outputs/3_Observed_Richness/"


usa <- readOGR(paste(shape_files, "USA", sep = ""))
usa <- usa[usa$STATE_NAME != "Alaska",]
usa <- usa[usa$STATE_NAME != "Hawaii",]
globe <- readOGR(paste(shape_files, "Continents", sep = ""))
nam <- globe[globe$CONTINENT == "North America",]
nam <- crop(nam, extent(-165, -60, 8, 85))
usaWGS <- spTransform(usa, CRS(proj4string(nam)))

## do ALL BEES first

#step 1 load in alldat for North America and species list
alldat <- read.csv(paste(csv_files, "NorAmer_highQual_only_ALLfamilies.csv"), sep = "")
spList <- read.csv(paste(csv_files, "contiguousSpecies_high_Only.csv"), sep = "")
spList <- select(spList, (-X))

#step 2 crop the records so that it"s only records for the US species
#and simplify so just 4 columns
alldat_other <- anti_join(alldat, spList, by = "finalName") # 86krecords for species not in US period
alldat_USspecies <- anti_join(alldat, alldat_other, by = "finalName") #good, 2.15 mil records for Nor America that involve the 3169 US species
alldat_USspecies <- select(alldat_USspecies, family, finalName, finalLongitude, finalLatitude)

#add a column that is just a 1 showing presence
alldat_USspecies$Presence <- 1

#step 3 make your points into a spatial Points Data Frame
#in doing so take the lon and lat columns and creating an object for "coord", call this xy
#then create a SpatialPointsDataFrame, must always assign a proj4string
xy <- alldat_USspecies[, c(3, 4)] #columns 3 and 4 are lon and lat
spdf <- SpatialPointsDataFrame(coords = xy, data = alldat_USspecies,
                              proj4string = CRS("+proj=longlat +datum=WGS84"))

#step 4 create empty raster at the 30x30 resolution and crop to study area
r30 <- raster(ncol = 1080, nrow = 540)
r30[r30 > 0] <- 0
r30 <- crop(r30, usaWGS)

#step 5 rasterize the spatial points dataframe to the empty raster created above
#function = "count" allows points to be counted per pixel
allPoints <- rasterize(spdf, r30, field = alldat_USspecies$Presence, fun = "count")

#step 6 there are some points included that we don"t want, outside of contiguous US
#we already got rid of AK and HI above, so it must be some in Canada and Mexico and coasts
#mask to usaWGS again, very explict
allPoints <- mask(allPoints, usaWGS)

#step 7 make into data frame and sum number of pixels that are included in your area
allPoints_df <- as.data.frame(allPoints, xy = TRUE)
allPoints_df <- na.omit(allPoints_df) #gets rid of many NAs that aren"t a part of study area
allPixelsSum <- sum(allPoints_df$layer)

#next, need to mash up these total points per pixel 
#with the rasters that give number of expected species per pixel
#as well as the number of observed species per pixel

#read in the 30x30 for expected and observed and stack for all bees
AndObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full_OR.grd", sep = ""))
ApiObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full_OR.grd", sep = ""))
ColObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full_OR.grd", sep = ""))
HalObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full_OR.grd", sep = ""))
MegObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full_OR.grd", sep = ""))
MelObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full_OR.grd", sep = ""))
all30obs <- AndObserved30 + ApiObserved30 + ColObserved30 + HalObserved30 + MegObserved30 + MelObserved30

AndPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full.grd", sep = ""))
ApiPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full.grd", sep = ""))
ColPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full.grd", sep = ""))
HalPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full.grd", sep = ""))
MegPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full.grd", sep = ""))
MelPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd", sep = ""))

AndPredict30[is.na(AndPredict30[])] <- 0
ApiPredict30[is.na(ApiPredict30[])] <- 0
ColPredict30[is.na(ColPredict30[])] <- 0
HalPredict30[is.na(HalPredict30[])] <- 0
MegPredict30[is.na(MegPredict30[])] <- 0
MelPredict30[is.na(MelPredict30[])] <- 0
all30 <- AndPredict30 + ApiPredict30 + ColPredict30 + HalPredict30 + MegPredict30 + MelPredict30

#crop predicted to observed raster
all30 <- crop(all30, all30obs)

#mask both observed and predicted to the US
all30 <- mask(all30, usaWGS)
all30obs <- mask(all30obs, usaWGS)

#see that the resolutions are not the same for allPoints against the expected/observed
#so resample those to match as well!
res(all30)
res(allPoints)
allPoints2 <- resample(allPoints, all30, method = "ngb") #fix

#get the ratio by dividing # of occurrences by # of expected species between rasters
#it makes another raster
ratio_occTospec <- allPoints2 / all30
plot(ratio_occTospec)

#compile all 3 rasters
compiledRaster <- stack(allPoints2, all30, ratio_occTospec)
compiledRaster <- as.data.frame(compiledRaster, xy = TRUE)

compiledRaster <- compiledRaster %>% rename(Occurrences = layer.1)
compiledRaster <- compiledRaster %>% rename(PredictedSpecies = layer.2)
compiledRaster <- compiledRaster %>% rename(Ratio = layer.3)
compiledRaster <- filter(compiledRaster, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

write.csv(compiledRaster, file = paste(outputs, "csv/pointDensity_expected_richness_AllBees.csv", sep = ""))

## NOW do by family

#just reread everything in to verify working with original dataset
alldat <- read.csv(paste(csv_files, "NorAmer_highQual_only_ALLfamilies.csv"), sep = "")
spList <- read.csv(paste(csv_files, "contiguousSpecies_high_Only.csv"), sep = "")
spList <- select(spList, (-X)) #don"t want that column

#step 2 crop the records so that it"s only records for the US species
#and simplify so just 4 columns
alldat_other <- anti_join(alldat, spList, by = "finalName") # 86krecords for species not in US period
alldat_USspecies <- anti_join(alldat, alldat_other, by = "finalName") #good, 2.15 mil records for Nor America that involve the 3159 US species
alldat_USspecies <- select(alldat_USspecies, family, finalName, finalLongitude, finalLatitude)

#add a column that is just a 1 showing presence
alldat_USspecies$Presence <- 1

#make into six family groups
allUSdata_And <- alldat_USspecies[grepl("Andrenidae", alldat_USspecies$family),]
allUSdata_Api <- alldat_USspecies[grepl("Apidae", alldat_USspecies$family),]
allUSdata_Meg <- alldat_USspecies[grepl("Megachilidae", alldat_USspecies$family),]
allUSdata_Hal <- alldat_USspecies[grepl("Halictidae", alldat_USspecies$family),]
allUSdata_Col <- alldat_USspecies[grepl("Colletidae", alldat_USspecies$family),]
allUSdata_Mel <- alldat_USspecies[grepl("Melittidae", alldat_USspecies$family),]


#step 3 make your points into a spatial Points Data Frame
#in doing so take the lon and lat columns and creating an object for "coord", call this xy
#then create a SpatialPointsDataFrame, must always assign a proj4string
xyAnd <- allUSdata_And[, c(3, 4)] #columns 3 and 4 are lon and lat
xyApi <- allUSdata_Api[, c(3, 4)] #columns 3 and 4 are lon and lat
xyMeg <- allUSdata_Meg[, c(3, 4)] #columns 3 and 4 are lon and lat
xyHal <- allUSdata_Hal[, c(3, 4)] #columns 3 and 4 are lon and lat
xyCol <- allUSdata_Col[, c(3, 4)] #columns 3 and 4 are lon and lat
xyMel <- allUSdata_Mel[, c(3, 4)] #columns 3 and 4 are lon and lat

spdf_And <- SpatialPointsDataFrame(coords = xyAnd, data = allUSdata_And,
                              proj4string = CRS("+proj=longlat +datum=WGS84"))

spdf_Api <- SpatialPointsDataFrame(coords = xyApi, data = allUSdata_Api,
                                  proj4string = CRS("+proj=longlat +datum=WGS84"))

spdf_Meg <- SpatialPointsDataFrame(coords = xyMeg, data = allUSdata_Meg,
                                  proj4string = CRS("+proj=longlat +datum=WGS84"))

spdf_Hal <- SpatialPointsDataFrame(coords = xyHal, data = allUSdata_Hal,
                                  proj4string = CRS("+proj=longlat +datum=WGS84"))

spdf_Col <- SpatialPointsDataFrame(coords = xyCol, data = allUSdata_Col,
                                  proj4string = CRS("+proj=longlat +datum=WGS84"))

spdf_Mel <- SpatialPointsDataFrame(coords = xyMel, data = allUSdata_Mel,
                                  proj4string = CRS("+proj=longlat +datum=WGS84"))


#step 4 create empty raster at the 30x30 resolution and crop to study area
r30 <- raster(ncol = 1080, nrow = 540)
r30[r30 > 0] <- 0
r30 <- crop(r30, usaWGS)

#step 5 rasterize the spatial points dataframe to the empty raster created above
#function = "count" allows points to be counted per pixel
allPoints_And <- rasterize(spdf_And, r30, field = allUSdata_And$Presence, fun = "count")
allPoints_Api <- rasterize(spdf_Api, r30, field = allUSdata_Api$Presence, fun = "count")
allPoints_Meg <- rasterize(spdf_Meg, r30, field = allUSdata_Meg$Presence, fun = "count")
allPoints_Hal <- rasterize(spdf_Hal, r30, field = allUSdata_Hal$Presence, fun = "count")
allPoints_Col <- rasterize(spdf_Col, r30, field = allUSdata_Col$Presence, fun = "count")
allPoints_Mel <- rasterize(spdf_Mel, r30, field = allUSdata_Mel$Presence, fun = "count")

#step 6 there are some points included that we don"t want, outside of contiguous US
#we already got rid of AK and HI above, so it must be some in Canada and Mexico and coasts
#mask to usaWGS again, very explict
allPoints_And <- mask(allPoints_And, usaWGS)
allPoints_Api <- mask(allPoints_Api, usaWGS)
allPoints_Meg <- mask(allPoints_Meg, usaWGS)
allPoints_Hal <- mask(allPoints_Hal, usaWGS)
allPoints_Col <- mask(allPoints_Col, usaWGS)
allPoints_Mel <- mask(allPoints_Mel, usaWGS)

#read in observed and predicted for each family, do appropriate cropping
#even if ultimately you are only going to use the predicted rasters
AndObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full_OR.grd", sep = ""))
ApiObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full_OR.grd", sep = ""))
ColObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full_OR.grd", sep = ""))
HalObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full_OR.grd", sep = ""))
MegObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full_OR.grd", sep = ""))
MelObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full_OR.grd", sep = ""))

AndPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full.grd", sep = ""))
ApiPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full.grd", sep = ""))
ColPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full.grd", sep = ""))
HalPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full.grd", sep = ""))
MegPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full.grd", sep = ""))
MelPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd", sep = ""))


AndPredict30[is.na(AndPredict30[])] <- 0
ApiPredict30[is.na(ApiPredict30[])] <- 0
ColPredict30[is.na(ColPredict30[])] <- 0
HalPredict30[is.na(HalPredict30[])] <- 0
MegPredict30[is.na(MegPredict30[])] <- 0
MelPredict30[is.na(MelPredict30[])] <- 0

AndPredict30 <- crop(AndPredict30, AndObserved30)
ApiPredict30 <- crop(ApiPredict30, ApiObserved30)
MegPredict30 <- crop(MegPredict30, MegObserved30)
HalPredict30 <- crop(HalPredict30, HalObserved30)
ColPredict30 <- crop(ColPredict30, ColObserved30)
MelPredict30 <- crop(MelPredict30, MelObserved30)

#and also resample to continue the matching of rasters process bc extents are slightly off
AndObserved30 <- resample(AndObserved30, AndPredict30, method = "ngb")
ApiObserved30 <- resample(ApiObserved30, ApiPredict30, method = "ngb")
MegObserved30 <- resample(MegObserved30, MegPredict30, method = "ngb")
HalObserved30 <- resample(HalObserved30, HalPredict30, method = "ngb")
ColObserved30 <- resample(ColObserved30, ColPredict30, method = "ngb")
MelObserved30 <- resample(MelObserved30, MelPredict30, method = "ngb")

#mask both observed and predicted to the US
AndPredict30 <- mask(AndPredict30, usaWGS)
AndObserved30 <- mask(AndObserved30, usaWGS)

ApiPredict30 <- mask(ApiPredict30, usaWGS)
ApiObserved30 <- mask(ApiObserved30, usaWGS)

MegPredict30 <- mask(MegPredict30, usaWGS)
MegObserved30 <- mask(MegObserved30, usaWGS)

HalPredict30 <- mask(HalPredict30, usaWGS)
HalObserved30 <- mask(HalObserved30, usaWGS)

ColPredict30 <- mask(ColPredict30, usaWGS)
ColObserved30 <- mask(ColObserved30, usaWGS)

MelPredict30 <- mask(MelPredict30, usaWGS)
MelObserved30 <- mask(MelObserved30, usaWGS)

#see that the resolutions are not the same for allPoints against the expected/observed
#so resample those to match as well!
res(AndPredict30)
res(allPoints_And)

allPoints_And2 <- resample(allPoints_And, AndPredict30, method = "ngb")
allPoints_Api2 <- resample(allPoints_Api, ApiPredict30, method = "ngb")
allPoints_Meg2 <- resample(allPoints_Meg, MegPredict30, method = "ngb")
allPoints_Hal2 <- resample(allPoints_Hal, HalPredict30, method = "ngb")
allPoints_Col2 <- resample(allPoints_Col, ColPredict30, method = "ngb")
allPoints_Mel2 <- resample(allPoints_Mel, MelPredict30, method = "ngb")

#make sure good to go
res(allPoints_And2)
extent(allPoints_And2)
extent(AndPredict30)

#get the ratio by dividing # of occurrences by # of expected species between rasters
#it makes another raster
ratio_occTospec_And <- allPoints_And2 / AndPredict30
ratio_occTospec_Api <- allPoints_Api2 / ApiPredict30
ratio_occTospec_Meg <- allPoints_Meg2 / MegPredict30
ratio_occTospec_Hal <- allPoints_Hal2 / HalPredict30
ratio_occTospec_Col <- allPoints_Col2 / ColPredict30
ratio_occTospec_Mel <- allPoints_Mel2 / MelPredict30

#compile all three
compiledRaster_And <- stack(allPoints_And2, AndPredict30, ratio_occTospec_And)
compiledRaster_And <- as.data.frame(compiledRaster_And, xy = TRUE)

compiledRaster_Api <- stack(allPoints_Api2, ApiPredict30, ratio_occTospec_Api)
compiledRaster_Api <- as.data.frame(compiledRaster_Api, xy = TRUE)

compiledRaster_Meg <- stack(allPoints_Meg2, MegPredict30, ratio_occTospec_Meg)
compiledRaster_Meg <- as.data.frame(compiledRaster_Meg, xy = TRUE)

compiledRaster_Hal <- stack(allPoints_Hal2, HalPredict30, ratio_occTospec_Hal)
compiledRaster_Hal <- as.data.frame(compiledRaster_Hal, xy = TRUE)

compiledRaster_Col <- stack(allPoints_Col2, ColPredict30, ratio_occTospec_Col)
compiledRaster_Col <- as.data.frame(compiledRaster_Col, xy = TRUE)

compiledRaster_Mel <- stack(allPoints_Mel2, MelPredict30, ratio_occTospec_Mel)
compiledRaster_Mel <- as.data.frame(compiledRaster_Mel, xy = TRUE)

#rename all columns
compiledRaster_And <- compiledRaster_And %>% rename(Occurrences = layer.1)
compiledRaster_And <- compiledRaster_And %>% rename(PredictedSpecies = layer.2)
compiledRaster_And <- compiledRaster_And %>% rename(Ratio = layer.3)

compiledRaster_Api <- compiledRaster_Api %>% rename(Occurrences = layer.1)
compiledRaster_Api <- compiledRaster_Api %>% rename(PredictedSpecies = layer.2)
compiledRaster_Api <- compiledRaster_Api %>% rename(Ratio = layer.3)

compiledRaster_Meg <- compiledRaster_Meg %>% rename(Occurrences = layer.1)
compiledRaster_Meg <- compiledRaster_Meg %>% rename(PredictedSpecies = layer.2)
compiledRaster_Meg <- compiledRaster_Meg %>% rename(Ratio = layer.3)

compiledRaster_Hal <- compiledRaster_Hal %>% rename(Occurrences = layer.1)
compiledRaster_Hal <- compiledRaster_Hal %>% rename(PredictedSpecies = layer.2)
compiledRaster_Hal <- compiledRaster_Hal %>% rename(Ratio = layer.3)

compiledRaster_Col <- compiledRaster_Col %>% rename(Occurrences = layer.1)
compiledRaster_Col <- compiledRaster_Col %>% rename(PredictedSpecies = layer.2)
compiledRaster_Col <- compiledRaster_Col %>% rename(Ratio = layer.3)

compiledRaster_Mel <- compiledRaster_Mel %>% rename(Occurrences = layer.1)
compiledRaster_Mel <- compiledRaster_Mel %>% rename(PredictedSpecies = layer.2)
compiledRaster_Mel <- compiledRaster_Mel %>% rename(Ratio = layer.3)

compiledRaster_And <- filter(compiledRaster_And, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)
compiledRaster_Api <- filter(compiledRaster_Api, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)
compiledRaster_Meg <- filter(compiledRaster_Meg, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)
compiledRaster_Hal <- filter(compiledRaster_Hal, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)
compiledRaster_Col <- filter(compiledRaster_Col, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)
compiledRaster_Mel <- filter(compiledRaster_Mel, PredictedSpecies > 0) #don"t want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

write.csv(compiledRaster_And, file = paste(outputs, "csv/pointDensity_expected_richness_Andrenidae.csv", sep = ""))
write.csv(compiledRaster_Api, file = paste(outputs, "csv/pointDensity_expected_richness_Apidae.csv", sep = ""))
write.csv(compiledRaster_Meg, file = paste(outputs, "csv/pointDensity_expected_richness_Megachilidae.csv", sep = ""))
write.csv(compiledRaster_Hal, file = paste(outputs, "csv/pointDensity_expected_richness_Halictidae.csv", sep = ""))
write.csv(compiledRaster_Col, file = paste(outputs, "csv/pointDensity_expected_richness_Colletidae.csv", sep = ""))
write.csv(compiledRaster_Mel, file = paste(outputs, "csv/pointDensity_expected_richness_Melittidae.csv", sep = ""))
