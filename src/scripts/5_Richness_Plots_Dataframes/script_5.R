library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(dplyr)
library(sf)

shape_files <- "../../inputs/shape_files/"
csv_files <- "../../inputs/csv_data/"
outputs <- "../../outputs/5_Richness_Plots_Dataframes/"
script3outputs <- "../../outputs/3_Observed_Richness/"

usa <- readOGR("/Users/paige/Dropbox/Bee_Gap/Shape Files/USA")
usa <- usa[usa$STATE_NAME != "Alaska", ]
usa <- usa[usa$STATE_NAME != "Hawaii", ]
globe <- readOGR("/Users/paige/Dropbox/Bee_Gap/Shape Files/Continents")
nam <- globe[globe$CONTINENT == "North America", ]
nam <- crop(nam, extent(-165, -60, 8, 85))
usaWGS <- spTransform(usa, CRS(proj4string(nam)))


##MEGACHILIDAE
#read in observed
MegObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full_OR.grd", sep = ""))
MegObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full_OR.grd", sep = ""))
MegObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full_OR.grd", sep = ""))
MegObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full_OR.grd", sep = ""))

#read in predicted
MegPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full.grd", sep = "")) # WHERE ARE NON *_OR.grd FILES?
MegPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full.grd", sep = ""))
MegPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full.grd", sep = ""))
MegPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full.grd", sep = ""))

#crop predicted to observed raster
MegPredict30 <- crop(MegPredict30, MegObserved30)
MegPredict60 <- crop(MegPredict60, MegObserved60)
MegPredict110 <- crop(MegPredict110, MegObserved110)
MegPredict220 <- crop(MegPredict220, MegObserved220)

#resample to continue the matching of rasters process
MegObserved30 <- resample(MegObserved30, MegPredict30, method = "ngb")
MegObserved60 <- resample(MegObserved60, MegPredict60, method = "ngb")
MegObserved110 <- resample(MegObserved110, MegPredict110, method = "ngb")
MegObserved220 <- resample(MegObserved220, MegPredict220, method = "ngb")

#mask both observed and predicted to the US
MegObserved30 <- mask(MegObserved30, usaWGS)
MegObserved30 <- mask(MegObserved30, nam)

MegObserved60 <- mask(MegObserved60, usaWGS)
MegObserved60 <- mask(MegObserved60, nam)

MegObserved110 <- mask(MegObserved110, usaWGS)
MegObserved110 <- mask(MegObserved110, nam)

MegObserved220 <- mask(MegObserved220, usaWGS)
MegObserved220 <- mask(MegObserved220, nam)

MegPredict30 <- mask(MegPredict30, usaWGS)
MegPredict30 <- mask(MegPredict30, nam)

MegPredict60 <- mask(MegPredict60, usaWGS)
MegPredict60 <- mask(MegPredict60, nam)

MegPredict110 <- mask(MegPredict110, usaWGS)
MegPredict110 <- mask(MegPredict110, nam)

MegPredict220 <- mask(MegPredict220, usaWGS)
MegPredict220 <- mask(MegPredict220, nam)

## PLOT ALL OBSERVED ##
plot(MegObserved30, main = "Megachilidae Observed Richness @ 30km x 30km", zlim = range(0, 160), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MegObserved60, main = "Megachilidae Observed Richness @ 60km x 60km", zlim = range(0, 230), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MegObserved110, main = "Megachilidae Observed @ 110km x 110km", zlim = range(0, 230), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MegObserved220, main = "Megachilidae Observed @ 220km x 220km", zlim = range(0, 270), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

## PLOT ALL PREDICTED ##
plot(MegPredict30, main = "Megachilidae Predicted @ 30km x 30km", zlim = range(0, 315), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MegPredict60, main = "Megachilidae Predicted @ 60km x 60km", zlim = range(0, 315), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MegPredict110, main = "Megachilidae Predicted @ 110km x 110km", zlim = range(0, 330), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MegPredict220, main = "Megachilidae Predicted @ 220km x 220km", zlim = range(0, 350), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
MegObserved30 <- as.data.frame(MegObserved30, xy = TRUE)
MegObserved60 <- as.data.frame(MegObserved60, xy = TRUE)
MegObserved110 <- as.data.frame(MegObserved110, xy = TRUE)
MegObserved220 <- as.data.frame(MegObserved220, xy = TRUE)

MegPredict30 <- as.data.frame(MegPredict30, xy = TRUE)
MegPredict60 <- as.data.frame(MegPredict60, xy = TRUE)
MegPredict110 <- as.data.frame(MegPredict110, xy = TRUE)
MegPredict220 <- as.data.frame(MegPredict220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
MegObserved30 <- na.omit(MegObserved30)
MegObserved60 <- na.omit(MegObserved60)
MegObserved110 <- na.omit(MegObserved110)
MegObserved220 <- na.omit(MegObserved220)

MegPredict30 <- na.omit(MegPredict30)
MegPredict60 <- na.omit(MegPredict60)
MegPredict110 <- na.omit(MegPredict110)
MegPredict220 <- na.omit(MegPredict220)

#write out all files (observed)
write.csv(MegObserved30, file = paste(outputs, "csv/observed/Megachilidae30km.csv", sep = ""))
write.csv(MegObserved60, file = paste(outputs, "csv/observed/Megachilidae60km.csv", sep = ""))
write.csv(MegObserved110, file = paste(outputs, "csv/observed/Megachilidae110km.csv", sep = ""))
write.csv(MegObserved220, file = paste(outputs, "csv/observed/Megachilidae220km.csv", sep = ""))

#write out all files (predicted)
write.csv(MegPredict30, file = paste(outputs, "csv/predicted/Megachilidae30km.csv", sep = ""))
write.csv(MegPredict60, file = paste(outputs, "csv/predicted/Megachilidae60km.csv", sep = ""))
write.csv(MegPredict110, file = paste(outputs, "csv/predicted/Megachilidae110km.csv", sep = ""))
write.csv(MegPredict220, file = paste(outputs, "csv/predicted/Megachilidae220km.csv", sep = ""))

#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
MegPredict30 <- read.csv(paste(outputs, "csv/predicted/Megachilidae30km.csv", sep = ""))
colnames(MegPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(MegPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(MegPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(MegPredict30)[1] <- "Pixel" #make column names the same between dfs

MegPredict60 <- read.csv(paste(outputs, "csv/predicted/Megachilidae60km.csv", sep = ""))
colnames(MegPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(MegPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(MegPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(MegPredict60)[1] <- "Pixel" #make column names the same between dfs

MegPredict110 <- read.csv(paste(outputs, "csv/predicted/Megachilidae110km.csv", sep = ""))
colnames(MegPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(MegPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(MegPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(MegPredict110)[1] <- "Pixel" #make column names the same between dfs

MegPredict220 <- read.csv(paste(outputs, "csv/predicted/Megachilidae220km.csv", sep = ""))
colnames(MegPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(MegPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(MegPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(MegPredict220)[1] <- "Pixel" #make column names the same between dfs

MegObserved30 <- read.csv(paste(outputs, "csv/observed/Megachilidae30km.csv", sep = ""))
colnames(MegObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(MegObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(MegObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(MegObserved30)[1] <- "Pixel" #make column names the same between dfs

MegObserved60 <- read.csv(paste(outputs, "csv/observed/Megachilidae60km.csv", sep = ""))
colnames(MegObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(MegObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(MegObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(MegObserved60)[1] <- "Pixel" #make column names the same between dfs

MegObserved110 <- read.csv(paste(outputs, "csv/observed/Megachilidae110km.csv", sep = ""))
colnames(MegObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(MegObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(MegObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(MegObserved110)[1] <- "Pixel" #make column names the same between dfs

MegObserved220 <- read.csv(paste(outputs, "csv/observed/Megachilidae220km.csv", sep = ""))
colnames(MegObserved220)[4] <- "Observed" #make column names the same between dfs
colnames(MegObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(MegObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(MegObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
MegCompleteness30 <- merge(MegObserved30, MegPredict30, by = "Pixel")
MegCompleteness30 <- na.omit(MegCompleteness30) #this brings pixel # to 956 (US only)
MegCompleteness30 <- filter(MegCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

MegCompleteness60 <- merge(MegObserved60, MegPredict60, by = "Pixel")
MegCompleteness60 <- na.omit(MegCompleteness60) #this brings pixel # to 956 (US only)
MegCompleteness60 <- filter(MegCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

MegCompleteness110 <- merge(MegObserved110, MegPredict110, by = "Pixel")
MegCompleteness110 <- na.omit(MegCompleteness110) #this brings pixel # to 956 (US only)
MegCompleteness110 <- filter(MegCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

MegCompleteness220 <- merge(MegObserved220, MegPredict220, by = "Pixel")
MegCompleteness220 <- na.omit(MegCompleteness220) #this brings pixel # to 956 (US only)
MegCompleteness220 <- filter(MegCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

## Make completeness spreadsheets with Percent Complete column ##
MegCompleteness30$Completeness <- (MegCompleteness30$Observed / MegCompleteness30$Predicted) * 100
MegCompleteness60$Completeness <- (MegCompleteness60$Observed / MegCompleteness60$Predicted) * 100
MegCompleteness110$Completeness <- (MegCompleteness110$Observed / MegCompleteness110$Predicted) * 100
MegCompleteness220$Completeness <- (MegCompleteness220$Observed / MegCompleteness220$Predicted) * 100


write.csv(MegCompleteness30, file = paste(outputs, "csv/completeness/Megachilidae30km.csv", sep = ""))
write.csv(MegCompleteness60, file = paste(outputs, "csv/completeness/Megachilidae60km.csv", sep = ""))
write.csv(MegCompleteness110, file = paste(outputs, "csv/completeness/Megachilidae110km.csv", sep = ""))
write.csv(MegCompleteness220, file = paste(outputs, "csv/completeness/Megachilidae220km.csv", sep = ""))

#cap at 100% for all pixels
MegCompleteness30$Completeness[MegCompleteness30$Completeness > 100] <- 100
MegCompleteness60$Completeness[MegCompleteness60$Completeness > 100] <- 100
MegCompleteness110$Completeness[MegCompleteness110$Completeness > 100] <- 100
MegCompleteness220$Completeness[MegCompleteness220$Completeness > 100] <- 100

mean(MegCompleteness30$Completeness)
mean(MegCompleteness60$Completeness)
mean(MegCompleteness110$Completeness)
mean(MegCompleteness220$Completeness)

sd(MegCompleteness30$Completeness)
sd(MegCompleteness60$Completeness)
sd(MegCompleteness110$Completeness)
sd(MegCompleteness220$Completeness)




## ANDRENIDAE ####
#read in observed
AndObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full_OR.grd", sep = ""))
AndObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full_OR.grd", sep = ""))
AndObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full_OR.grd", sep = ""))
AndObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full_OR.grd", sep = ""))

#read in predicted
AndPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full.grd", sep = ""))
AndPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full.grd", sep = ""))
AndPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full.grd", sep = ""))
AndPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full.grd", sep = ""))

#crop predicted to observed raster
AndPredict30 <- crop(AndPredict30, AndObserved30)
AndPredict60 <- crop(AndPredict60, AndObserved60)
AndPredict110 <- crop(AndPredict110, AndObserved110)
AndPredict220 <- crop(AndPredict220, AndObserved220)

#resample to continue the matching of rasters process
AndObserved30 <- resample(AndObserved30, AndPredict30, method = "ngb")
AndObserved60 <- resample(AndObserved60, AndPredict60, method = "ngb")
AndObserved110 <- resample(AndObserved110, AndPredict110, method = "ngb")
AndObserved220 <- resample(AndObserved220, AndPredict220, method = "ngb")

#mask both observed and predicted to the US
AndObserved30 <- mask(AndObserved30, usaWGS)
AndObserved30 <- mask(AndObserved30, nam)

AndObserved60 <- mask(AndObserved60, usaWGS)
AndObserved60 <- mask(AndObserved60, nam)

AndObserved110 <- mask(AndObserved110, usaWGS)
AndObserved110 <- mask(AndObserved110, nam)

AndObserved220 <- mask(AndObserved220, usaWGS)
AndObserved220 <- mask(AndObserved220, nam)

AndPredict30 <- mask(AndPredict30, usaWGS)
AndPredict30 <- mask(AndPredict30, nam)

AndPredict60 <- mask(AndPredict60, usaWGS)
AndPredict60 <- mask(AndPredict60, nam)

AndPredict110 <- mask(AndPredict110, usaWGS)
AndPredict110 <- mask(AndPredict110, nam)

AndPredict220 <- mask(AndPredict220, usaWGS)
AndPredict220 <- mask(AndPredict220, nam)

## PLOT ALL OBSERVED ##
plot(AndObserved30, main = "Andrenidae Observed Richness @ 30km x 30km", zlim = range(0, 130), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(AndObserved60, main = "Andrenidae Observed Richness @ 60km x 60km", zlim = range(0, 150), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(AndObserved110, main = "Andrenidae Observed @ 110km x 110km", zlim = range(0, 190), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(AndObserved220, main = "Andrenidae Observed @ 220km x 220km", zlim = range(0, 270), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

## PLOT ALL PREDICTED ##
plot(AndPredict30, main = "Andrenidae Predicted @ 30km x 30km", zlim = range(0, 270), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(AndPredict60, main = "Andrenidae Predicted @ 60km x 60km", zlim = range(0, 275), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(AndPredict110, main = "Andrenidae Predicted @ 110km x 110km", zlim = range(0, 300), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(AndPredict220, main = "Andrenidae Predicted @ 220km x 220km", zlim = range(0, 360), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
AndObserved30 <- as.data.frame(AndObserved30, xy = TRUE)
AndObserved60 <- as.data.frame(AndObserved60, xy = TRUE)
AndObserved110 <- as.data.frame(AndObserved110, xy = TRUE)
AndObserved220 <- as.data.frame(AndObserved220, xy = TRUE)

AndPredict30 <- as.data.frame(AndPredict30, xy = TRUE)
AndPredict60 <- as.data.frame(AndPredict60, xy = TRUE)
AndPredict110 <- as.data.frame(AndPredict110, xy = TRUE)
AndPredict220 <- as.data.frame(AndPredict220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
AndObserved30 <- na.omit(AndObserved30)
AndObserved60 <- na.omit(AndObserved60)
AndObserved110 <- na.omit(AndObserved110)
AndObserved220 <- na.omit(AndObserved220)

AndPredict30 <- na.omit(AndPredict30)
AndPredict60 <- na.omit(AndPredict60)
AndPredict110 <- na.omit(AndPredict110)
AndPredict220 <- na.omit(AndPredict220)

#write out all files (observed)
write.csv(AndObserved30, file = paste(outputs, "csv/observed/Andrenidae30km.csv", sep = ""))
write.csv(AndObserved60, file = paste(outputs, "csv/observed/Andrenidae60km.csv", sep = ""))
write.csv(AndObserved110, file = paste(outputs, "csv/observed/Andrenidae110km.csv", sep = ""))
write.csv(AndObserved220, file = paste(outputs, "csv/observed/Andrenidae220km.csv", sep = ""))

#write out all files (predicted)
write.csv(AndPredict30, file = paste(outputs, "csv/predicted/Andrenidae30km.csv", sep = ""))
write.csv(AndPredict60, file = paste(outputs, "csv/predicted/Andrenidae60km.csv", sep = ""))
write.csv(AndPredict110, file = paste(outputs, "csv/predicted/Andrenidae110km.csv", sep = ""))
write.csv(AndPredict220, file = paste(outputs, "csv/predicted/Andrenidae220km.csv", sep = ""))

#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
AndPredict30 <- read.csv(paste(outputs, "csv/predicted/Andrenidae30km.csv", sep = ""))
colnames(AndPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict30)[1] <- "Pixel" #make column names the same between dfs

AndPredict60 <- read.csv(paste(outputs, "csv/predicted/Andrenidae60km.csv", sep = ""))
colnames(AndPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict60)[1] <- "Pixel" #make column names the same between dfs

AndPredict110 <- read.csv(paste(outputs, "csv/predicted/Andrenidae110km.csv", sep = ""))
colnames(AndPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict110)[1] <- "Pixel" #make column names the same between dfs

AndPredict220 <- read.csv(paste(outputs, "csv/predicted/Andrenidae220km.csv", sep = ""))
colnames(AndPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict220)[1] <- "Pixel" #make column names the same between dfs

AndObserved30 <- read.csv(paste(outputs, "csv/observed/Andrenidae30km.csv", sep = ""))
colnames(AndObserved30)[4] <- "Predicted" #make column names the same between dfs
colnames(AndObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved30)[1] <- "Pixel" #make column names the same between dfs

AndObserved60 <- read.csv(paste(outputs, "csv/observed/Andrenidae60km.csv", sep = ""))
colnames(AndObserved60)[4] <- "Predicted" #make column names the same between dfs
colnames(AndObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved60)[1] <- "Pixel" #make column names the same between dfs

AndObserved110 <- read.csv(paste(outputs, "csv/observed/Andrenidae110km.csv", sep = ""))
colnames(AndObserved110)[4] <- "Predicted" #make column names the same between dfs
colnames(AndObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved110)[1] <- "Pixel" #make column names the same between dfs

AndObserved220 <- read.csv(paste(outputs, "csv/observed/Andrenidae220km.csv", sep = ""))
colnames(AndObserved220)[4] <- "Predicted" #make column names the same between dfs
colnames(AndObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
AndCompleteness30 <- merge(AndObserved30, AndPredict30, by = "Pixel")
AndCompleteness30 <- na.omit(AndCompleteness30) #this brings pixel # to 20358 (US only)
AndCompleteness30 <- filter(AndCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

AndCompleteness60 <- merge(AndObserved60, AndPredict60, by = "Pixel")
AndCompleteness60 <- na.omit(AndCompleteness60) #this brings pixel # to 5100 (US only)
AndCompleteness60 <- filter(AndCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

AndCompleteness110 <- merge(AndObserved110, AndPredict110, by = "Pixel")
AndCompleteness110 <- na.omit(AndCompleteness110) #this brings pixel # to 2277 (US only)
AndCompleteness110 <- filter(AndCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

AndCompleteness220 <- merge(AndObserved220, AndPredict220, by = "Pixel")
AndCompleteness220 <- na.omit(AndCompleteness220) #this brings pixel # to 561 (US only)
AndCompleteness220 <- filter(AndCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)


## Make completeness spreadsheets with Percent Complete column ##
AndCompleteness30$Completeness <- (AndCompleteness30$Observed / AndCompleteness30$Predicted) * 100
AndCompleteness60$Completeness <- (AndCompleteness60$Observed / AndCompleteness60$Predicted) * 100
AndCompleteness110$Completeness <- (AndCompleteness110$Observed / AndCompleteness110$Predicted) * 100
AndCompleteness220$Completeness <- (AndCompleteness220$Observed / AndCompleteness220$Predicted) * 100


write.csv(AndCompleteness30, file = paste(outputs, "csv/completeness/Andrenidae30km.csv", sep = ""))
write.csv(AndCompleteness60, file = paste(outputs, "csv/completeness/Andrenidae60km.csv", sep = ""))
write.csv(AndCompleteness110, file = paste(outputs, "csv/completeness/Andrenidae110km.csv", sep = ""))
write.csv(AndCompleteness220, file = paste(outputs, "csv/completeness/Andrenidae220km.csv", sep = ""))

#Cap at 100% for And pixels?
AndCompleteness30$Completeness[AndCompleteness30$Completeness > 100] <- 100
AndCompleteness60$Completeness[AndCompleteness60$Completeness > 100] <- 100
AndCompleteness110$Completeness[AndCompleteness110$Completeness > 100] <- 100
AndCompleteness220$Completeness[AndCompleteness220$Completeness > 100] <- 100

mean(AndCompleteness30$Completeness)
mean(AndCompleteness60$Completeness)
mean(AndCompleteness110$Completeness)
mean(AndCompleteness220$Completeness)

sd(AndCompleteness30$Completeness)
sd(AndCompleteness60$Completeness)
sd(AndCompleteness110$Completeness)
sd(AndCompleteness220$Completeness)



## APIDAE ##
#read in observed
ApiObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full_OR.grd", sep = ""))
ApiObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Apidae/Apidae60_full_OR.grd", sep = ""))
ApiObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Apidae/Apidae110_full_OR.grd", sep = ""))
ApiObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Apidae/Apidae220_full_OR.grd", sep = ""))

#read in predicted
ApiPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full.grd", sep = ""))
ApiPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Apidae/Apidae60_full.grd", sep = ""))
ApiPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Apidae/Apidae110_full.grd", sep = ""))
ApiPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Apidae/Apidae220_full.grd", sep = ""))

#crop predicted to observed raster
ApiPredict30 <- crop(ApiPredict30, ApiObserved30)
ApiPredict60 <- crop(ApiPredict60, ApiObserved60)
ApiPredict110 <- crop(ApiPredict110, ApiObserved110)
ApiPredict220 <- crop(ApiPredict220, ApiObserved220)

#resample to continue the matching of rasters process
ApiObserved30 <- resample(ApiObserved30, ApiPredict30, method = "ngb")
ApiObserved60 <- resample(ApiObserved60, ApiPredict60, method = "ngb")
ApiObserved110 <- resample(ApiObserved110, ApiPredict110, method = "ngb")
ApiObserved220 <- resample(ApiObserved220, ApiPredict220, method = "ngb")

#mask both observed and predicted to the US
ApiObserved30 <- mask(ApiObserved30, usaWGS)
ApiObserved30 <- mask(ApiObserved30, nam)

ApiObserved60 <- mask(ApiObserved60, usaWGS)
ApiObserved60 <- mask(ApiObserved60, nam)

ApiObserved110 <- mask(ApiObserved110, usaWGS)
ApiObserved110 <- mask(ApiObserved110, nam)

ApiObserved220 <- mask(ApiObserved220, usaWGS)
ApiObserved220 <- mask(ApiObserved220, nam)

ApiPredict30 <- mask(ApiPredict30, usaWGS)
ApiPredict30 <- mask(ApiPredict30, nam)

ApiPredict60 <- mask(ApiPredict60, usaWGS)
ApiPredict60 <- mask(ApiPredict60, nam)

ApiPredict110 <- mask(ApiPredict110, usaWGS)
ApiPredict110 <- mask(ApiPredict110, nam)

ApiPredict220 <- mask(ApiPredict220, usaWGS)
ApiPredict220 <- mask(ApiPredict220, nam)

## PLOT ALL OBSERVED ##
plot(ApiObserved30, main = "Apidae Observed Richness @ 30km x 30km", zlim = range(0, 141), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(ApiObserved60, main = "Apidae Observed Richness @ 60km x 60km", zlim = range(0, 160), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(ApiObserved110, main = "Apidae Observed @ 110km x 110km", zlim = range(0, 200), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(ApiObserved220, main = "Apidae Observed @ 220km x 220km", zlim = range(0, 240), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

## PLOT ALL PREDICTED ##
plot(ApiPredict30, main = "Apidae Predicted @ 30km x 30km", zlim = range(0, 270), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(ApiPredict60, main = "Apidae Predicted @ 60km x 60km", zlim = range(0, 280), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(ApiPredict110, main = "Apidae Predicted @ 110km x 110km", zlim = range(0, 300), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(ApiPredict220, main = "Apidae Predicted @ 220km x 220km", zlim = range(0, 340), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
ApiObserved30 <- as.data.frame(ApiObserved30, xy = TRUE)
ApiObserved60 <- as.data.frame(ApiObserved60, xy = TRUE)
ApiObserved110 <- as.data.frame(ApiObserved110, xy = TRUE)
ApiObserved220 <- as.data.frame(ApiObserved220, xy = TRUE)

ApiPredict30 <- as.data.frame(ApiPredict30, xy = TRUE)
ApiPredict60 <- as.data.frame(ApiPredict60, xy = TRUE)
ApiPredict110 <- as.data.frame(ApiPredict110, xy = TRUE)
ApiPredict220 <- as.data.frame(ApiPredict220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
ApiObserved30 <- na.omit(ApiObserved30)
ApiObserved60 <- na.omit(ApiObserved60)
ApiObserved110 <- na.omit(ApiObserved110)
ApiObserved220 <- na.omit(ApiObserved220)

ApiPredict30 <- na.omit(ApiPredict30)
ApiPredict60 <- na.omit(ApiPredict60)
ApiPredict110 <- na.omit(ApiPredict110)
ApiPredict220 <- na.omit(ApiPredict220)

#write out all files (observed)
write.csv(ApiObserved30, file = paste(outputs, "csv/observed/Apidae30km.csv", sep = ""))
write.csv(ApiObserved60, file = paste(outputs, "csv/observed/Apidae60km.csv", sep = ""))
write.csv(ApiObserved110, file = paste(outputs, "csv/observed/Apidae110km.csv", sep = ""))
write.csv(ApiObserved220, file = paste(outputs, "csv/observed/Apidae220km.csv", sep = ""))

#write out all files (predicted)
write.csv(ApiPredict30, file = paste(outputs, "csv/predicted/Apidae30km.csv", sep = ""))
write.csv(ApiPredict60, file = paste(outputs, "csv/predicted/Apidae60km.csv", sep = ""))
write.csv(ApiPredict110, file = paste(outputs, "csv/predicted/Apidae110km.csv", sep = ""))
write.csv(ApiPredict220, file = paste(outputs, "csv/predicted/Apidae220km.csv", sep = ""))

#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
ApiPredict30 <- read.csv(paste(outputs, "csv/predicted/Apidae30km.csv", sep = ""))
colnames(ApiPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict30)[1] <- "Pixel" #make column names the same between dfs

ApiPredict60 <- read.csv(paste(outputs, "csv/predicted/Apidae60km.csv", sep = ""))
colnames(ApiPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict60)[1] <- "Pixel" #make column names the same between dfs

ApiPredict110 <- read.csv(paste(outputs, "csv/predicted/Apidae110km.csv", sep = ""))
colnames(ApiPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict110)[1] <- "Pixel" #make column names the same between dfs

ApiPredict220 <- read.csv(paste(outputs, "csv/predicted/Apidae220km.csv", sep = ""))
colnames(ApiPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict220)[1] <- "Pixel" #make column names the same between dfs


ApiObserved30 <- read.csv(paste(outputs, "csv/observed/Apidae30km.csv", sep = ""))
colnames(ApiObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved30)[1] <- "Pixel" #make column names the same between dfs

ApiObserved60 <- read.csv(paste(outputs, "csv/observed/Apidae60km.csv", sep = ""))
colnames(ApiObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved60)[1] <- "Pixel" #make column names the same between dfs

ApiObserved110 <- read.csv(paste(outputs, "csv/observed/Apidae110km.csv", sep = ""))
colnames(ApiObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved110)[1] <- "Pixel" #make column names the same between dfs

ApiObserved220 <- read.csv(paste(outputs, "csv/observed/Apidae220km.csv", sep = ""))
colnames(ApiObserved220)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
ApiCompleteness30 <- merge(ApiObserved30, ApiPredict30, by = "Pixel")
ApiCompleteness30 <- na.omit(ApiCompleteness30) #this brings pixel # to 956 (US only)
ApiCompleteness30 <- filter(ApiCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

ApiCompleteness60 <- merge(ApiObserved60, ApiPredict60, by = "Pixel")
ApiCompleteness60 <- na.omit(ApiCompleteness60) #this brings pixel # to 956 (US only)
ApiCompleteness60 <- filter(ApiCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

ApiCompleteness110 <- merge(ApiObserved110, ApiPredict110, by = "Pixel")
ApiCompleteness110 <- na.omit(ApiCompleteness110) #this brings pixel # to 956 (US only)
ApiCompleteness110 <- filter(ApiCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

ApiCompleteness220 <- merge(ApiObserved220, ApiPredict220, by = "Pixel")
ApiCompleteness220 <- na.omit(ApiCompleteness220) #this brings pixel # to 956 (US only)
ApiCompleteness220 <- filter(ApiCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)


## Make completeness spreadsheets with Percent Complete column ##
ApiCompleteness30$Completeness <- (ApiCompleteness30$Observed / ApiCompleteness30$Predicted) * 100
ApiCompleteness60$Completeness <- (ApiCompleteness60$Observed / ApiCompleteness60$Predicted) * 100
ApiCompleteness110$Completeness <- (ApiCompleteness110$Observed / ApiCompleteness110$Predicted) * 100
ApiCompleteness220$Completeness <- (ApiCompleteness220$Observed / ApiCompleteness220$Predicted) * 100


write.csv(ApiCompleteness30, file = paste(outputs, "csv/completeness/Apidae30km.csv", sep = ""))
write.csv(ApiCompleteness60, file = paste(outputs, "csv/completeness/Apidae60km.csv", sep = ""))
write.csv(ApiCompleteness110, file = paste(outputs, "csv/completeness/Apidae110km.csv", sep = ""))
write.csv(ApiCompleteness220, file = paste(outputs, "csv/completeness/Apidae220km.csv", sep = ""))

#Cap at 100% for Api pixels?
ApiCompleteness30$Completeness[ApiCompleteness30$Completeness > 100] <- 100
ApiCompleteness60$Completeness[ApiCompleteness60$Completeness > 100] <- 100
ApiCompleteness110$Completeness[ApiCompleteness110$Completeness > 100] <- 100
ApiCompleteness220$Completeness[ApiCompleteness220$Completeness > 100] <- 100

mean(ApiCompleteness30$Completeness)
mean(ApiCompleteness60$Completeness)
mean(ApiCompleteness110$Completeness)
mean(ApiCompleteness220$Completeness)

sd(ApiCompleteness30$Completeness)
sd(ApiCompleteness60$Completeness)
sd(ApiCompleteness110$Completeness)
sd(ApiCompleteness220$Completeness)



## COLLETIDAE ##
#read in observed
CollObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full_OR.grd", sep = ""))
CollObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Colletidae/Colletidae60_full_OR.grd", sep = ""))
CollObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Colletidae/Colletidae110_full_OR.grd", sep = ""))
CollObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Colletidae/Colletidae220_full_OR.grd", sep = ""))

#read in predicted
CollPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full.grd", sep = ""))
CollPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Colletidae/Colletidae60_full.grd", sep = ""))
CollPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Colletidae/Colletidae110_full.grd", sep = ""))
CollPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Colletidae/Colletidae220_full.grd", sep = ""))

#crop predicted to observed raster
CollPredict30 <- crop(CollPredict30, CollObserved30)
CollPredict60 <- crop(CollPredict60, CollObserved60)
CollPredict110 <- crop(CollPredict110, CollObserved110)
CollPredict220 <- crop(CollPredict220, CollObserved220)

#resample to continue the matching of rasters process
CollObserved30 <- resample(CollObserved30, CollPredict30, method = "ngb")
CollObserved60 <- resample(CollObserved60, CollPredict60, method = "ngb")
CollObserved110 <- resample(CollObserved110, CollPredict110, method = "ngb")
CollObserved220 <- resample(CollObserved220, CollPredict220, method = "ngb")

#mask both observed and predicted to the US
CollObserved30 <- mask(CollObserved30, usaWGS)
CollObserved30 <- mask(CollObserved30, nam)

CollObserved60 <- mask(CollObserved60, usaWGS)
CollObserved60 <- mask(CollObserved60, nam)

CollObserved110 <- mask(CollObserved110, usaWGS)
CollObserved110 <- mask(CollObserved110, nam)

CollObserved220 <- mask(CollObserved220, usaWGS)
CollObserved220 <- mask(CollObserved220, nam)

CollPredict30 <- mask(CollPredict30, usaWGS)
CollPredict30 <- mask(CollPredict30, nam)

CollPredict60 <- mask(CollPredict60, usaWGS)
CollPredict60 <- mask(CollPredict60, nam)

CollPredict110 <- mask(CollPredict110, usaWGS)
CollPredict110 <- mask(CollPredict110, nam)

CollPredict220 <- mask(CollPredict220, usaWGS)
CollPredict220 <- mask(CollPredict220, nam)

## PLOT ALL OBSERVED ##
plot(CollObserved30, main = "Colletidae Observed Richness @ 30km x 30km", zlim = range(0, 35), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollObserved60, main = "Colletidae Observed Richness @ 60km x 60km", zlim = range(0, 35), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollObserved110, main = "Colletidae Observed @ 110km x 110km", zlim = range(0, 40), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollObserved220, main = "Colletidae Observed @ 220km x 220km", zlim = range(0, 45), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)
#plot(nam, add= T)

## PLOT ALL PREDICTED ##
plot(CollPredict30, main = "Colletidae Predicted @ 30km x 30km", zlim = range(0, 60), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollPredict60, main = "Colletidae Predicted @ 60km x 60km", zlim = range(0, 60), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollPredict110, main = "Colletidae Predicted @ 110km x 110km", zlim = range(0, 65), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollPredict220, main = "Colletidae Predicted @ 220km x 220km", zlim = range(0, 65), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
CollObserved30 <- as.data.frame(CollObserved30, xy = TRUE)
CollObserved60 <- as.data.frame(CollObserved60, xy = TRUE)
CollObserved110 <- as.data.frame(CollObserved110, xy = TRUE)
CollObserved220 <- as.data.frame(CollObserved220, xy = TRUE)

CollPredict30 <- as.data.frame(CollPredict30, xy = TRUE)
CollPredict60 <- as.data.frame(CollPredict60, xy = TRUE)
CollPredict110 <- as.data.frame(CollPredict110, xy = TRUE)
CollPredict220 <- as.data.frame(CollPredict220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
CollObserved30 <- na.omit(CollObserved30)
CollObserved60 <- na.omit(CollObserved60)
CollObserved110 <- na.omit(CollObserved110)
CollObserved220 <- na.omit(CollObserved220)

CollPredict30 <- na.omit(CollPredict30)
CollPredict60 <- na.omit(CollPredict60)
CollPredict110 <- na.omit(CollPredict110)
CollPredict220 <- na.omit(CollPredict220)


#write out all files (observed)
write.csv(CollObserved30, file = paste(outputs, "csv/observed/Colletidae30km.csv", sep = ""))
write.csv(CollObserved60, file = paste(outputs, "csv/observed/Colletidae60km.csv", sep = ""))
write.csv(CollObserved110, file = paste(outputs, "csv/observed/Colletidae110km.csv", sep = ""))
write.csv(CollObserved220, file = paste(outputs, "csv/observed/Colletidae220km.csv", sep = ""))


#write out all files (observed)
write.csv(CollPredict30, file = paste(outputs, "csv/predicted/Colletidae30km.csv", sep = ""))
write.csv(CollPredict60, file = paste(outputs, "csv/predicted/Colletidae60km.csv", sep = ""))
write.csv(CollPredict110, file = paste(outputs, "csv/predicted/Colletidae110km.csv", sep = ""))
write.csv(CollPredict220, file = paste(outputs, "csv/predicted/Colletidae220km.csv", sep = ""))


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
CollPredict30 <- read.csv(paste(outputs, "csv/predicted/Colletidae30km.csv", sep = ""))
colnames(CollPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict30)[1] <- "Pixel" #make column names the same between dfs

CollPredict60 <- read.csv(paste(outputs, "csv/predicted/Colletidae60km.csv", sep = ""))
colnames(CollPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict60)[1] <- "Pixel" #make column names the same between dfs

CollPredict110 <- read.csv(paste(outputs, "csv/predicted/Colletidae110km.csv", sep = ""))
colnames(CollPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict110)[1] <- "Pixel" #make column names the same between dfs

CollPredict220 <- read.csv(paste(outputs, "csv/predicted/Colletidae220km.csv", sep = ""))
colnames(CollPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict220)[1] <- "Pixel" #make column names the same between dfs


CollObserved30 <- read.csv(paste(outputs, "csv/observed/Colletidae30km.csv", sep = ""))
colnames(CollObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved30)[1] <- "Pixel" #make column names the same between dfs

CollObserved60 <- read.csv(paste(outputs, "csv/observed/Colletidae60km.csv", sep = ""))
colnames(CollObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved60)[1] <- "Pixel" #make column names the same between dfs

CollObserved110 <- read.csv(paste(outputs, "csv/observed/Colletidae110km.csv", sep = ""))
colnames(CollObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved110)[1] <- "Pixel" #make column names the same between dfs

CollObserved220 <- read.csv(paste(outputs, "csv/observed/Colletidae220km.csv", sep = ""))
colnames(CollObserved220)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
CollCompleteness30 <- merge(CollObserved30, CollPredict30, by = "Pixel")
CollCompleteness30 <- na.omit(CollCompleteness30) #this brings pixel # to 956 (US only)
CollCompleteness30 <- filter(CollCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

CollCompleteness60 <- merge(CollObserved60, CollPredict60, by = "Pixel")
CollCompleteness60 <- na.omit(CollCompleteness60) #this brings pixel # to 956 (US only)
CollCompleteness60 <- filter(CollCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

CollCompleteness110 <- merge(CollObserved110, CollPredict110, by = "Pixel")
CollCompleteness110 <- na.omit(CollCompleteness110) #this brings pixel # to 956 (US only)
CollCompleteness110 <- filter(CollCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

CollCompleteness220 <- merge(CollObserved220, CollPredict220, by = "Pixel")
CollCompleteness220 <- na.omit(CollCompleteness220) #this brings pixel # to 956 (US only)
CollCompleteness220 <- filter(CollCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)


## Make completeness spreadsheets with Percent Complete column ##
CollCompleteness30$Completeness <- (CollCompleteness30$Observed / CollCompleteness30$Predicted) * 100
CollCompleteness60$Completeness <- (CollCompleteness60$Observed / CollCompleteness60$Predicted) * 100
CollCompleteness110$Completeness <- (CollCompleteness110$Observed / CollCompleteness110$Predicted) * 100
CollCompleteness220$Completeness <- (CollCompleteness220$Observed / CollCompleteness220$Predicted) * 100


write.csv(CollCompleteness30, file = paste(outputs, "csv/completeness/Colletidae30km.csv", sep = ""))
write.csv(CollCompleteness60, file = paste(outputs, "csv/completeness/Colletidae60km.csv", sep = ""))
write.csv(CollCompleteness110, file = paste(outputs, "csv/completeness/Colletidae110km.csv", sep = ""))
write.csv(CollCompleteness220, file = paste(outputs, "csv/completeness/Colletidae220km.csv", sep = ""))

#Cap at 100% for Coll pixels?
CollCompleteness30$Completeness[CollCompleteness30$Completeness > 100] <- 100
CollCompleteness60$Completeness[CollCompleteness60$Completeness > 100] <- 100
CollCompleteness110$Completeness[CollCompleteness110$Completeness > 100] <- 100
CollCompleteness220$Completeness[CollCompleteness220$Completeness > 100] <- 100

mean(CollCompleteness30$Completeness)
mean(CollCompleteness60$Completeness)
mean(CollCompleteness110$Completeness)
mean(CollCompleteness220$Completeness)

sd(CollCompleteness30$Completeness)
sd(CollCompleteness60$Completeness)
sd(CollCompleteness110$Completeness)
sd(CollCompleteness220$Completeness)



## HALICTIDAE ##
#read in observed
HalObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full_OR.grd", sep = ""))
HalObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Halictidae/Halictidae60_full_OR.grd", sep = ""))
HalObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Halictidae/Halictidae110_full_OR.grd", sep = ""))
HalObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Halictidae/Halictidae220_full_OR.grd", sep = ""))

#read in predicted
HalPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full.grd", sep = ""))
HalPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Halictidae/Halictidae60_full.grd", sep = ""))
HalPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Halictidae/Halictidae110_full.grd", sep = ""))
HalPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Halictidae/Halictidae220_full.grd", sep = ""))

#crop predicted to observed raster
HalPredict30 <- crop(HalPredict30, HalObserved30)
HalPredict60 <- crop(HalPredict60, HalObserved60)
HalPredict110 <- crop(HalPredict110, HalObserved110)
HalPredict220 <- crop(HalPredict220, HalObserved220)


#resample to continue the matching of rasters process
HalObserved30 <- resample(HalObserved30, HalPredict30, method = "ngb")
HalObserved60 <- resample(HalObserved60, HalPredict60, method = "ngb")
HalObserved110 <- resample(HalObserved110, HalPredict110, method = "ngb")
HalObserved220 <- resample(HalObserved220, HalPredict220, method = "ngb")

#mask both observed and predicted to the US
HalObserved30 <- mask(HalObserved30, usaWGS)
HalObserved30 <- mask(HalObserved30, nam)

HalObserved60 <- mask(HalObserved60, usaWGS)
HalObserved60 <- mask(HalObserved60, nam)

HalObserved110 <- mask(HalObserved110, usaWGS)
HalObserved110 <- mask(HalObserved110, nam)

HalObserved220 <- mask(HalObserved220, usaWGS)
HalObserved220 <- mask(HalObserved220, nam)

HalPredict30 <- mask(HalPredict30, usaWGS)
HalPredict30 <- mask(HalPredict30, nam)

HalPredict60 <- mask(HalPredict60, usaWGS)
HalPredict60 <- mask(HalPredict60, nam)

HalPredict110 <- mask(HalPredict110, usaWGS)
HalPredict110 <- mask(HalPredict110, nam)

HalPredict220 <- mask(HalPredict220, usaWGS)
HalPredict220 <- mask(HalPredict220, nam)

## PLOT ALL OBSERVED ##
plot(HalObserved30, main = "Halictidae Observed Richness @ 30km x 30km", zlim = range(0, 85), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(HalObserved60, main = "Halictidae Observed Richness @ 60km x 60km", zlim = range(0, 90), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(HalObserved110, main = "Halictidae Observed @ 110km x 110km", zlim = range(0, 105), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(HalObserved220, main = "Halictidae Observed @ 220km x 220km", zlim = range(0, 110), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

## PLOT ALL PREDICTED ##
plot(HalPredict30, main = "Halictidae Predicted @ 30km x 30km", zlim = range(0, 130), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(HalPredict60, main = "Halictidae Predicted @ 60km x 60km", zlim = range(0, 130), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(HalPredict110, main = "Halictidae Predicted @ 110km x 110km", zlim = range(0, 135), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(HalPredict220, main = "Halictidae Predicted @ 220km x 220km", zlim = range(0, 140), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
HalObserved30 <- as.data.frame(HalObserved30, xy = TRUE)
HalObserved60 <- as.data.frame(HalObserved60, xy = TRUE)
HalObserved110 <- as.data.frame(HalObserved110, xy = TRUE)
HalObserved220 <- as.data.frame(HalObserved220, xy = TRUE)

HalPredict30 <- as.data.frame(HalPredict30, xy = TRUE)
HalPredict60 <- as.data.frame(HalPredict60, xy = TRUE)
HalPredict110 <- as.data.frame(HalPredict110, xy = TRUE)
HalPredict220 <- as.data.frame(HalPredict220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
HalObserved30 <- na.omit(HalObserved30)
HalObserved60 <- na.omit(HalObserved60)
HalObserved110 <- na.omit(HalObserved110)
HalObserved220 <- na.omit(HalObserved220)

HalPredict30 <- na.omit(HalPredict30)
HalPredict60 <- na.omit(HalPredict60)
HalPredict110 <- na.omit(HalPredict110)
HalPredict220 <- na.omit(HalPredict220)


#write out all files (observed)
write.csv(HalObserved30, file = paste(outputs, "csv/observed/Halictidae30km.csv", sep = ""))
write.csv(HalObserved60, file = paste(outputs, "csv/observed/Halictidae60km.csv", sep = ""))
write.csv(HalObserved110, file = paste(outputs, "csv/observed/Halictidae110km.csv", sep = ""))
write.csv(HalObserved220, file = paste(outputs, "csv/observed/Halictidae220km.csv", sep = ""))


#write out all files (predicted)
write.csv(HalPredict30, file = paste(outputs, "csv/predicted/Halictidae30km.csv", sep = ""))
write.csv(HalPredict60, file = paste(outputs, "csv/predicted/Halictidae60km.csv", sep = ""))
write.csv(HalPredict110, file = paste(outputs, "csv/predicted/Halictidae110km.csv", sep = ""))
write.csv(HalPredict220, file = paste(outputs, "csv/predicted/Halictidae220km.csv", sep = ""))


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
HalPredict30 <- read.csv(paste(outputs, "csv/predicted/Halictidae30km.csv", sep = ""))
colnames(HalPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict30)[1] <- "Pixel" #make column names the same between dfs

HalPredict60 <- read.csv(paste(outputs, "csv/predicted/Halictidae60km.csv", sep = ""))
colnames(HalPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict60)[1] <- "Pixel" #make column names the same between dfs

HalPredict110 <- read.csv(paste(outputs, "csv/predicted/Halictidae110km.csv", sep = ""))
colnames(HalPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict110)[1] <- "Pixel" #make column names the same between dfs

HalPredict220 <- read.csv(paste(outputs, "csv/predicted/Halictidae220km.csv", sep = ""))
colnames(HalPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict220)[1] <- "Pixel" #make column names the same between dfs


HalObserved30 <- read.csv(paste(outputs, "csv/observed/Halictidae30km.csv", sep = ""))
colnames(HalObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved30)[1] <- "Pixel" #make column names the same between dfs

HalObserved60 <- read.csv(paste(outputs, "csv/observed/Halictidae60km.csv", sep = ""))
colnames(HalObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved60)[1] <- "Pixel" #make column names the same between dfs

HalObserved110 <- read.csv(paste(outputs, "csv/observed/Halictidae110km.csv", sep = ""))
colnames(HalObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved110)[1] <- "Pixel" #make column names the same between dfs

HalObserved220 <- read.csv(paste(outputs, "csv/observed/Halictidae220km.csv", sep = ""))
colnames(HalObserved220)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
HalCompleteness30 <- merge(HalObserved30, HalPredict30, by = "Pixel")
HalCompleteness30 <- na.omit(HalCompleteness30) #this brings pixel # to 956 (US only)
HalCompleteness30 <- filter(HalCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

HalCompleteness60 <- merge(HalObserved60, HalPredict60, by = "Pixel")
HalCompleteness60 <- na.omit(HalCompleteness60) #this brings pixel # to 956 (US only)
HalCompleteness60 <- filter(HalCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

HalCompleteness110 <- merge(HalObserved110, HalPredict110, by = "Pixel")
HalCompleteness110 <- na.omit(HalCompleteness110) #this brings pixel # to 956 (US only)
HalCompleteness110 <- filter(HalCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

HalCompleteness220 <- merge(HalObserved220, HalPredict220, by = "Pixel")
HalCompleteness220 <- na.omit(HalCompleteness220) #this brings pixel # to 956 (US only)
HalCompleteness220 <- filter(HalCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)


## Make completeness spreadsheets with Percent Complete column ##
HalCompleteness30$Completeness <- (HalCompleteness30$Observed / HalCompleteness30$Predicted) * 100
HalCompleteness60$Completeness <- (HalCompleteness60$Observed / HalCompleteness60$Predicted) * 100
HalCompleteness110$Completeness <- (HalCompleteness110$Observed / HalCompleteness110$Predicted) * 100
HalCompleteness220$Completeness <- (HalCompleteness220$Observed / HalCompleteness220$Predicted) * 100


write.csv(HalCompleteness30, file = paste(outputs, "csv/completeness/Halictidae30km.csv", sep = ""))
write.csv(HalCompleteness60, file = paste(outputs, "csv/completeness/Halictidae60km.csv", sep = ""))
write.csv(HalCompleteness110, file = paste(outputs, "csv/completeness/Halictidae110km.csv", sep = ""))
write.csv(HalCompleteness220, file = paste(outputs, "csv/completeness/Halictidae220km.csv", sep = ""))

#Cap at 100% for Hal pixels?
HalCompleteness30$Completeness[HalCompleteness30$Completeness > 100] <- 100
HalCompleteness60$Completeness[HalCompleteness60$Completeness > 100] <- 100
HalCompleteness110$Completeness[HalCompleteness110$Completeness > 100] <- 100
HalCompleteness220$Completeness[HalCompleteness220$Completeness > 100] <- 100

mean(HalCompleteness30$Completeness)
mean(HalCompleteness60$Completeness)
mean(HalCompleteness110$Completeness)
mean(HalCompleteness220$Completeness)

sd(HalCompleteness30$Completeness)
sd(HalCompleteness60$Completeness)
sd(HalCompleteness110$Completeness)
sd(HalCompleteness220$Completeness)



## MELLITIDAE ##
#read in observed
MelObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full_OR.grd", sep = ""))
MelObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Melittidae/Melittidae60_full_OR.grd", sep = ""))
MelObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Melittidae/Melittidae110_full_OR.grd", sep = ""))
MelObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Melittidae/Melittidae220_full_OR.grd", sep = ""))

#read in predicted
MelPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd", sep = ""))
MelPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Melittidae/Melittidae60_full.grd", sep = ""))
MelPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Melittidae/Melittidae110_full.grd", sep = ""))
MelPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Melittidae/Melittidae220_full.grd", sep = ""))

#crop predicted to observed raster
MelPredict30 <- crop(MelPredict30, MelObserved30)
MelPredict60 <- crop(MelPredict60, MelObserved60)
MelPredict110 <- crop(MelPredict110, MelObserved110)
MelPredict220 <- crop(MelPredict220, MelObserved220)

#resample to continue the matching of rasters process
MelObserved30 <- resample(MelObserved30, MelPredict30, method = "ngb")
MelObserved60 <- resample(MelObserved60, MelPredict60, method = "ngb")
MelObserved110 <- resample(MelObserved110, MelPredict110, method = "ngb")
MelObserved220 <- resample(MelObserved220, MelPredict220, method = "ngb")

#mask both observed and predicted to the US
MelObserved30 <- mask(MelObserved30, usaWGS)
MelObserved30 <- mask(MelObserved30, nam)

MelObserved60 <- mask(MelObserved60, usaWGS)
MelObserved60 <- mask(MelObserved60, nam)

MelObserved110 <- mask(MelObserved110, usaWGS)
MelObserved110 <- mask(MelObserved110, nam)

MelObserved220 <- mask(MelObserved220, usaWGS)
MelObserved220 <- mask(MelObserved220, nam)

MelPredict30 <- mask(MelPredict30, usaWGS)
MelPredict30 <- mask(MelPredict30, nam)

MelPredict60 <- mask(MelPredict60, usaWGS)
MelPredict60 <- mask(MelPredict60, nam)

MelPredict110 <- mask(MelPredict110, usaWGS)
MelPredict110 <- mask(MelPredict110, nam)

MelPredict220 <- mask(MelPredict220, usaWGS)
MelPredict220 <- mask(MelPredict220, nam)

## PLOT ALL OBSERVED ##
plot(MelObserved30, main = "Melittidae Observed Richness @ 30km x 30km", zlim = range(0, 6), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MelObserved60, main = "Melittidae Observed Richness @ 60km x 60km", zlim = range(0, 6), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MelObserved110, main = "Melittidae Observed @ 110km x 110km", zlim = range(0, 8), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MelObserved220, main = "Melittidae Observed @ 220km x 220km", zlim = range(0, 8), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

## PLOT ALL PREDICTED ##
plot(MelPredict30, main = "Melittidae Predicted @ 30km x 30km", zlim = range(0, 10), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MelPredict60, main = "Melittidae Predicted @ 60km x 60km", zlim = range(0, 10), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MelPredict110, main = "Melittidae Predicted @ 110km x 110km", zlim = range(0, 12), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(MelPredict220, main = "Melittidae Predicted @ 220km x 220km", zlim = range(0, 12), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
MelObserved30 <- as.data.frame(MelObserved30, xy = TRUE)
MelObserved60 <- as.data.frame(MelObserved60, xy = TRUE)
MelObserved110 <- as.data.frame(MelObserved110, xy = TRUE)
MelObserved220 <- as.data.frame(MelObserved220, xy = TRUE)

MelPredict30 <- as.data.frame(MelPredict30, xy = TRUE)
MelPredict60 <- as.data.frame(MelPredict60, xy = TRUE)
MelPredict110 <- as.data.frame(MelPredict110, xy = TRUE)
MelPredict220 <- as.data.frame(MelPredict220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
MelObserved30 <- na.omit(MelObserved30)
MelObserved60 <- na.omit(MelObserved60)
MelObserved110 <- na.omit(MelObserved110)
MelObserved220 <- na.omit(MelObserved220)

MelPredict30 <- na.omit(MelPredict30)
MelPredict60 <- na.omit(MelPredict60)
MelPredict110 <- na.omit(MelPredict110)
MelPredict220 <- na.omit(MelPredict220)


#write out all files (observed)
write.csv(MelObserved30, file = paste(outputs, "csv/observed/Melittidae30km.csv", sep = ""))
write.csv(MelObserved60, file = paste(outputs, "csv/observed/Melittidae60km.csv", sep = ""))
write.csv(MelObserved110, file = paste(outputs, "csv/observed/Melittidae110km.csv", sep = ""))
write.csv(MelObserved220, file = paste(outputs, "csv/observed/Melittidae220km.csv", sep = ""))


#write out all files (predicted)
write.csv(MelPredict30, file = paste(outputs, "csv/predicted/Melittidae30km.csv", sep = ""))
write.csv(MelPredict60, file = paste(outputs, "csv/predicted/Melittidae60km.csv", sep = ""))
write.csv(MelPredict110, file = paste(outputs, "csv/predicted/Melittidae110km.csv", sep = ""))
write.csv(MelPredict220, file = paste(outputs, "csv/predicted/Melittidae220km.csv", sep = ""))


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
MelPredict30 <- read.csv(paste(outputs, "csv/predicted/Melittidae30km.csv", sep = ""))
colnames(MelPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict30)[1] <- "Pixel" #make column names the same between dfs

MelPredict60 <- read.csv(paste(outputs, "csv/predicted/Melittidae60km.csv", sep = ""))
colnames(MelPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict60)[1] <- "Pixel" #make column names the same between dfs

MelPredict110 <- read.csv(paste(outputs, "csv/predicted/Melittidae110km.csv", sep = ""))
colnames(MelPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict110)[1] <- "Pixel" #make column names the same between dfs

MelPredict220 <- read.csv(paste(outputs, "csv/predicted/Melittidae220km.csv", sep = ""))
colnames(MelPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict220)[1] <- "Pixel" #make column names the same between dfs


MelObserved30 <- read.csv(paste(outputs, "csv/observed/Melittidae30km.csv", sep = ""))
colnames(MelObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved30)[1] <- "Pixel" #make column names the same between dfs

MelObserved60 <- read.csv(paste(outputs, "csv/observed/Melittidae60km.csv", sep = ""))
colnames(MelObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved60)[1] <- "Pixel" #make column names the same between dfs

MelObserved110 <- read.csv(paste(outputs, "csv/observed/Melittidae110km.csv", sep = ""))
colnames(MelObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved110)[1] <- "Pixel" #make column names the same between dfs

MelObserved220 <- read.csv(paste(outputs, "csv/observed/Melittidae220km.csv", sep = ""))
colnames(MelObserved220)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
MelCompleteness30 <- merge(MelObserved30, MelPredict30, by = "Pixel")
MelCompleteness30 <- na.omit(MelCompleteness30) #this brings pixel # to 956 (US only)
MelCompleteness30 <- filter(MelCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

MelCompleteness60 <- merge(MelObserved60, MelPredict60, by = "Pixel")
MelCompleteness60 <- na.omit(MelCompleteness60) #this brings pixel # to 956 (US only)
MelCompleteness60 <- filter(MelCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

MelCompleteness110 <- merge(MelObserved110, MelPredict110, by = "Pixel")
MelCompleteness110 <- na.omit(MelCompleteness110) #this brings pixel # to 956 (US only)
MelCompleteness110 <- filter(MelCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

MelCompleteness220 <- merge(MelObserved220, MelPredict220, by = "Pixel")
MelCompleteness220 <- na.omit(MelCompleteness220) #this brings pixel # to 956 (US only)
MelCompleteness220 <- filter(MelCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)


## Make completeness spreadsheets with Percent Complete column ##
MelCompleteness30$Completeness <- (MelCompleteness30$Observed / MelCompleteness30$Predicted) * 100
MelCompleteness60$Completeness <- (MelCompleteness60$Observed / MelCompleteness60$Predicted) * 100
MelCompleteness110$Completeness <- (MelCompleteness110$Observed / MelCompleteness110$Predicted) * 100
MelCompleteness220$Completeness <- (MelCompleteness220$Observed / MelCompleteness220$Predicted) * 100


write.csv(MelCompleteness30, file = paste(outputs, "csv/completeness/Melittidae30km.csv", sep = ""))
write.csv(MelCompleteness60, file = paste(outputs, "csv/completeness/Melittidae60km.csv", sep = ""))
write.csv(MelCompleteness110, file = paste(outputs, "csv/completeness/Melittidae110km.csv", sep = ""))
write.csv(MelCompleteness220, file = paste(outputs, "csv/completeness/Melittidae220km.csv", sep = ""))

#Cap at 100% for Mel pixels?
MelCompleteness30$Completeness[MelCompleteness30$Completeness > 100] <- 100
MelCompleteness60$Completeness[MelCompleteness60$Completeness > 100] <- 100
MelCompleteness110$Completeness[MelCompleteness110$Completeness > 100] <- 100
MelCompleteness220$Completeness[MelCompleteness220$Completeness > 100] <- 100

mean(MelCompleteness30$Completeness)
mean(MelCompleteness60$Completeness)
mean(MelCompleteness110$Completeness)
mean(MelCompleteness220$Completeness)

sd(MelCompleteness30$Completeness)
sd(MelCompleteness60$Completeness)
sd(MelCompleteness110$Completeness)
sd(MelCompleteness220$Completeness)

### ALL FAMILIES TOGETHER ###
#read in observed
AndObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full_OR.grd", sep = ""))
ApiObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full_OR.grd", sep = ""))
ColObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full_OR.grd", sep = ""))
HalObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full_OR.grd", sep = ""))
MegObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full_OR.grd", sep = ""))
MelObserved30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full_OR.grd", sep = ""))

AndObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full_OR.grd", sep = ""))
ApiObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Apidae/Apidae60_full_OR.grd", sep = ""))
ColObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Colletidae/Colletidae60_full_OR.grd", sep = ""))
HalObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Halictidae/Halictidae60_full_OR.grd", sep = ""))
MegObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full_OR.grd", sep = ""))
MelObserved60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Melittidae/Melittidae60_full_OR.grd", sep = ""))

AndObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full_OR.grd", sep = ""))
ApiObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Apidae/Apidae110_full_OR.grd", sep = ""))
ColObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Colletidae/Colletidae110_full_OR.grd", sep = ""))
HalObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Halictidae/Halictidae110_full_OR.grd", sep = ""))
MegObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full_OR.grd", sep = ""))
MelObserved110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Melittidae/Melittidae110_full_OR.grd", sep = ""))

AndObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full_OR.grd", sep = ""))
ApiObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Apidae/Apidae220_full_OR.grd", sep = ""))
ColObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Colletidae/Colletidae220_full_OR.grd", sep = ""))
HalObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Halictidae/Halictidae220_full_OR.grd", sep = ""))
MegObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full_OR.grd", sep = ""))
MelObserved220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Melittidae/Melittidae220_full_OR.grd", sep = ""))

#stack all families for each resolution
all30obs <- AndObserved30 + ApiObserved30 + ColObserved30 + HalObserved30 + MegObserved30 + MelObserved30
all60obs <- AndObserved60 + ApiObserved60 + ColObserved60 + HalObserved60 + MegObserved60 + MelObserved60
all110obs <- AndObserved110 + ApiObserved110 + ColObserved110 + HalObserved110 + MegObserved110 + MelObserved110
all220obs <- AndObserved220 + ApiObserved220 + ColObserved220 + HalObserved220 + MegObserved220 + MelObserved220

#verify res
res(all30obs)
res(all60obs)
res(all110obs)
res(all220obs)

#read in predicted
AndPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full.grd", sep = ""))
ApiPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Apidae/Apidae30_full.grd", sep = ""))
ColPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Colletidae/Colletidae30_full.grd", sep = ""))
HalPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Halictidae/Halictidae30_full.grd", sep = ""))
MegPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full.grd", sep = "")) # WHERE ARE NON *_OR.grd FILES?
MelPredict30 <- raster(paste(script3outputs, "AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd", sep = ""))

AndPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full.grd", sep = ""))
ApiPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Apidae/Apidae60_full.grd", sep = ""))
ColPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Colletidae/Colletidae60_full.grd", sep = ""))
HalPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Halictidae/Halictidae60_full.grd", sep = ""))
MegPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full.grd", sep = ""))
MelPredict60 <- raster(paste(script3outputs, "AAA_Family_rasters/60km/Melittidae/Melittidae60_full.grd", sep = ""))

AndPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full.grd", sep = ""))
ApiPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Apidae/Apidae110_full.grd", sep = ""))
ColPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Colletidae/Colletidae110_full.grd", sep = ""))
HalPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Halictidae/Halictidae110_full.grd", sep = ""))
MegPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full.grd", sep = ""))
MelPredict110 <- raster(paste(script3outputs, "AAA_Family_rasters/110km/Melittidae/Melittidae110_full.grd", sep = ""))

AndPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full.grd", sep = ""))
ApiPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Apidae/Apidae220_full.grd", sep = ""))
ColPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Colletidae/Colletidae220_full.grd", sep = ""))
HalPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Halictidae/Halictidae220_full.grd", sep = ""))
MegPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full.grd", sep = ""))
MelPredict220 <- raster(paste(script3outputs, "AAA_Family_rasters/220km/Melittidae/Melittidae220_full.grd", sep = ""))

#fix issues with NAs before stacking
AndPredict30[is.na(AndPredict30[])] = 0
ApiPredict30[is.na(ApiPredict30[])] = 0
ColPredict30[is.na(ColPredict30[])] = 0
HalPredict30[is.na(HalPredict30[])] = 0
MegPredict30[is.na(MegPredict30[])] = 0
MelPredict30[is.na(MelPredict30[])] = 0

AndPredict60[is.na(AndPredict60[])] = 0
ApiPredict60[is.na(ApiPredict60[])] = 0
ColPredict60[is.na(ColPredict60[])] = 0
HalPredict60[is.na(HalPredict60[])] = 0
MegPredict60[is.na(MegPredict60[])] = 0
MelPredict60[is.na(MelPredict60[])] = 0

AndPredict110[is.na(AndPredict110[])] = 0
ApiPredict110[is.na(ApiPredict110[])] = 0
ColPredict110[is.na(ColPredict110[])] = 0
HalPredict110[is.na(HalPredict110[])] = 0
MegPredict110[is.na(MegPredict110[])] = 0
MelPredict110[is.na(MelPredict110[])] = 0

AndPredict220[is.na(AndPredict220[])] = 0
ApiPredict220[is.na(ApiPredict220[])] = 0
ColPredict220[is.na(ColPredict220[])] = 0
HalPredict220[is.na(HalPredict220[])] = 0
MegPredict220[is.na(MegPredict220[])] = 0
MelPredict220[is.na(MelPredict220[])] = 0

#stack all predicted
all30 <- AndPredict30 + ApiPredict30 + ColPredict30 + HalPredict30 + MegPredict30 + MelPredict30
all60 <- AndPredict60 + ApiPredict60 + ColPredict60 + HalPredict60 + MegPredict60 + MelPredict60
all110 <- AndPredict110 + ApiPredict110 + ColPredict110 + HalPredict110 + MegPredict110 + MelPredict110
all220 <- AndPredict220 + ApiPredict220 + ColPredict220 + HalPredict220 + MegPredict220 + MelPredict220

#crop predicted to observed raster
all30 <- crop(all30, all30obs)
all60 <- crop(all60, all60obs)
all110 <- crop(all110, all110obs)
all220 <- crop(all220, all220obs)

#resample to continue the matching of rasters process
all30obs <- resample(all30obs, all30, method = "ngb")
all60obs <- resample(all60obs, all60, method = "ngb")
all110obs <- resample(all110obs, all110, method = "ngb")
all220obs <- resample(all220obs, all220, method = "ngb")

#mask both observed and predicted to the US
all30obs <- mask(all30obs, usaWGS)
all30obs <- mask(all30obs, nam)

all60obs <- mask(all60obs, usaWGS)
all60obs <- mask(all60obs, nam)

all110obs <- mask(all110obs, usaWGS)
all110obs <- mask(all110obs, nam)

all220obs <- mask(all220obs, usaWGS)
all220obs <- mask(all220obs, nam)

all30 <- mask(all30, usaWGS)
all30 <- mask(all30, nam)

all60 <- mask(all60, usaWGS)
all60 <- mask(all60, nam)

all110 <- mask(all110, usaWGS)
all110 <- mask(all110, nam)

all220 <- mask(all220, usaWGS)
all220 <- mask(all220, nam)

## PLOT ALL OBSERVED ##
plot(all30obs, main = "All Bees Observed Richness @ 30km x 30km", zlim = range(0, 466), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(all60obs, main = "All Bees Observed Richness @ 60km x 60km", zlim = range(0, 560), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(all110obs, main = "All Bees Observed @ 110km x 110km", zlim = range(0, 680), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(all220obs, main = "All Bees Observed @ 220km x 220km", zlim = range(0, 910), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

## PLOT ALL PREDICTED ##
plot(all30, main = "All Bees Predicted @ 30km x 30km", zlim = range(0, 1010), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(all60, main = "All Bees Predicted @ 60km x 60km", zlim = range(0, 1020), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(all110, main = "All Bees Predicted @ 110km x 110km", zlim = range(0, 1050), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(all220, main = "All Bees Predicted @ 220km x 220km", zlim = range(0, 1200), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

#make all into dfs
all30obs <- as.data.frame(all30obs, xy = TRUE)
all60obs <- as.data.frame(all60obs, xy = TRUE)
all110obs <- as.data.frame(all110obs, xy = TRUE)
all220obs <- as.data.frame(all220obs, xy = TRUE)

AllPredict30 <- as.data.frame(all30, xy = TRUE)
AllPredict60 <- as.data.frame(all60, xy = TRUE)
AllPredict110 <- as.data.frame(all110, xy = TRUE)
AllPredict220 <- as.data.frame(all220, xy = TRUE)

##remove all NAs (outside US, ocean, etc)
AllObserved30 <- na.omit(all30obs)
AllObserved60 <- na.omit(all60obs)
AllObserved110 <- na.omit(all110obs)
AllObserved220 <- na.omit(all220obs)

AllPredict30 <- na.omit(AllPredict30)
AllPredict60 <- na.omit(AllPredict60)
AllPredict110 <- na.omit(AllPredict110)
AllPredict220 <- na.omit(AllPredict220)


#write out all files (observed)
write.csv(AllObserved30, file = paste(outputs, "csv/observed/AllFamilies30km.csv", sep = ""))
write.csv(AllObserved60, file = paste(outputs, "csv/observed/AllFamilies60km.csv", sep = ""))
write.csv(AllObserved110, file = paste(outputs, "csv/observed/AllFamilies110km.csv", sep = ""))
write.csv(AllObserved220, file = paste(outputs, "csv/observed/AllFamilies220km.csv", sep = ""))



#write out all files (predicted)
write.csv(AllPredict30, file = paste(outputs, "csv/predicted/AllFamilies30km.csv", sep = ""))
write.csv(AllPredict60, file = paste(outputs, "csv/predicted/AllFamilies60km.csv", sep = ""))
write.csv(AllPredict110, file = paste(outputs, "csv/predicted/AllFamilies110km.csv", sep = ""))
write.csv(AllPredict220, file = paste(outputs, "csv/predicted/AllFamilies220km.csv", sep = ""))



#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
AllPredict30 <- read.csv(paste(outputs, "csv/predicted/AllFamilies30km.csv", sep = ""))
colnames(AllPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict30)[1] <- "Pixel" #make column names the same between dfs

AllPredict60 <- read.csv(paste(outputs, "csv/predicted/AllFamilies60km.csv", sep = ""))
colnames(AllPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict60)[1] <- "Pixel" #make column names the same between dfs

AllPredict110 <- read.csv(paste(outputs, "csv/predicted/AllFamilies110km.csv", sep = ""))
colnames(AllPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict110)[1] <- "Pixel" #make column names the same between dfs

AllPredict220 <- read.csv(paste(outputs, "csv/predicted/AllFamilies220km.csv", sep = ""))
colnames(AllPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict220)[1] <- "Pixel" #make column names the same between dfs


AllObserved30 <- read.csv(paste(outputs, "csv/observed/AllFamilies30km.csv", sep = ""))
colnames(AllObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved30)[1] <- "Pixel" #make column names the same between dfs

AllObserved60 <- read.csv(paste(outputs, "csv/observed/AllFamilies60km.csv", sep = ""))
colnames(AllObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved60)[1] <- "Pixel" #make column names the same between dfs

AllObserved110 <- read.csv(paste(outputs, "csv/observed/AllFamilies110km.csv", sep = ""))
colnames(AllObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved110)[1] <- "Pixel" #make column names the same between dfs

AllObserved220 <- read.csv(paste(outputs, "csv/observed/AllFamilies220km.csv", sep = ""))
colnames(AllObserved220)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved220)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved220)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved220)[1] <- "Pixel" #make column names the same between dfs

#make completeness spreadsheets
AllCompleteness30 <- merge(AllObserved30, AllPredict30, by = "Pixel")
AllCompleteness30 <- na.omit(AllCompleteness30) #this brings pixel # to 956 (US only)
AllCompleteness30 <- filter(AllCompleteness30, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

AllCompleteness60 <- merge(AllObserved60, AllPredict60, by = "Pixel")
AllCompleteness60 <- na.omit(AllCompleteness60) #this brings pixel # to 956 (US only)
AllCompleteness60 <- filter(AllCompleteness60, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

AllCompleteness110 <- merge(AllObserved110, AllPredict110, by = "Pixel")
AllCompleteness110 <- na.omit(AllCompleteness110) #this brings pixel # to 956 (US only)
AllCompleteness110 <- filter(AllCompleteness110, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)

AllCompleteness220 <- merge(AllObserved220, AllPredict220, by = "Pixel")
AllCompleteness220 <- na.omit(AllCompleteness220) #this brings pixel # to 956 (US only)
AllCompleteness220 <- filter(AllCompleteness220, Predicted > 0) #don't want lat/lon points if no predicted value (only want to keep in zeros that live in the "observed" column)


## Make completeness spreadsheets with Percent Complete column ##
AllCompleteness30$Completeness <- (AllCompleteness30$Observed / AllCompleteness30$Predicted) * 100
AllCompleteness60$Completeness <- (AllCompleteness60$Observed / AllCompleteness60$Predicted) * 100
AllCompleteness110$Completeness <- (AllCompleteness110$Observed / AllCompleteness110$Predicted) * 100
AllCompleteness220$Completeness <- (AllCompleteness220$Observed / AllCompleteness220$Predicted) * 100


write.csv(AllCompleteness30, file = paste(outputs, "csv/completeness/AllFamilies30km.csv", sep = ""))
write.csv(AllCompleteness60, file = paste(outputs, "csv/completeness/AllFamilies60km.csv", sep = ""))
write.csv(AllCompleteness110, file = paste(outputs, "csv/completeness/AllFamilies110km.csv", sep = ""))
write.csv(AllCompleteness220, file = paste(outputs, "csv/completeness/AllFamilies220km.csv", sep = ""))

#Cap at 100% completeness
AllCompleteness30$Completeness[AllCompleteness30$Completeness > 100] <- 100
AllCompleteness60$Completeness[AllCompleteness60$Completeness > 100] <- 100
AllCompleteness110$Completeness[AllCompleteness110$Completeness > 100] <- 100
AllCompleteness220$Completeness[AllCompleteness220$Completeness > 100] <- 100

mean(AllCompleteness30$Completeness)
mean(AllCompleteness60$Completeness)
mean(AllCompleteness110$Completeness)
mean(AllCompleteness220$Completeness)

sd(AllCompleteness30$Completeness)
sd(AllCompleteness60$Completeness)
sd(AllCompleteness110$Completeness)
sd(AllCompleteness220$Completeness)
