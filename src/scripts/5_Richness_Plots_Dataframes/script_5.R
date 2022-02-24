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
NAm <- globe[globe$CONTINENT == "North America", ]
NAm <- crop(NAm, extent(-165, -60, 8, 85))
usaWGS <- spTransform(usa, CRS(proj4string(NAm)))


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
MegObserved30 <- mask(MegObserved30, NAm)

MegObserved60 <- mask(MegObserved60, usaWGS)
MegObserved60 <- mask(MegObserved60, NAm)

MegObserved110 <- mask(MegObserved110, usaWGS)
MegObserved110 <- mask(MegObserved110, NAm)

MegObserved220 <- mask(MegObserved220, usaWGS)
MegObserved220 <- mask(MegObserved220, NAm)

MegPredict30 <- mask(MegPredict30, usaWGS)
MegPredict30 <- mask(MegPredict30, NAm)

MegPredict60 <- mask(MegPredict60, usaWGS)
MegPredict60 <- mask(MegPredict60, NAm)

MegPredict110 <- mask(MegPredict110, usaWGS)
MegPredict110 <- mask(MegPredict110, NAm)

MegPredict220 <- mask(MegPredict220, usaWGS)
MegPredict220 <- mask(MegPredict220, NAm)

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

#write out all files (predicted)
write.csv(MegObserved30, file = paste(outputs, "csv/observed/Megachilidae30km.csv", sep = ""))
write.csv(MegObserved60, file = paste(outputs, "csv/observed/Megachilidae60km.csv", sep = ""))
write.csv(MegObserved110, file = paste(outputs, "csv/observed/Megachilidae110km.csv", sep = ""))
write.csv(MegObserved220, file = paste(outputs, "csv/observed/Megachilidae220km.csv", sep = ""))

#write out all files (observed)
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
AndObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full_OR.grd")
AndObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full_OR.grd")
AndObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full_OR.grd")
AndObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full_OR.grd")

#read in predicted
AndPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full.grd")
AndPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full.grd")
AndPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full.grd")
AndPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full.grd")

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
AndObserved30 <- mask(AndObserved30, NAm)

AndObserved60 <- mask(AndObserved60, usaWGS)
AndObserved60 <- mask(AndObserved60, NAm)

AndObserved110 <- mask(AndObserved110, usaWGS)
AndObserved110 <- mask(AndObserved110, NAm)

AndObserved220 <- mask(AndObserved220, usaWGS)
AndObserved220 <- mask(AndObserved220, NAm)

AndPredict30 <- mask(AndPredict30, usaWGS)
AndPredict30 <- mask(AndPredict30, NAm)

AndPredict60 <- mask(AndPredict60, usaWGS)
AndPredict60 <- mask(AndPredict60, NAm)

AndPredict110 <- mask(AndPredict110, usaWGS)
AndPredict110 <- mask(AndPredict110, NAm)

AndPredict220 <- mask(AndPredict220, usaWGS)
AndPredict220 <- mask(AndPredict220, NAm)

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

#write out all files (predicted)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
write.csv(AndObserved30, file = "Observed_Andrenidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
write.csv(AndObserved60, file = "Observed_Andrenidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
write.csv(AndObserved110, file = "Observed_Andrenidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
write.csv(AndObserved220, file = "Observed_Andrenidae220.csv")

#write out all files (observed)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
write.csv(AndPredict30, file = "Predicted_Andrenidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
write.csv(AndPredict60, file = "Predicted_Andrenidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
write.csv(AndPredict110, file = "Predicted_Andrenidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
write.csv(AndPredict220, file = "Predicted_Andrenidae220.csv")


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
AndPredict30 <- read.csv("Predicted_Andrenidae30.csv")
colnames(AndPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
AndPredict60 <- read.csv("Predicted_Andrenidae60.csv")
colnames(AndPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
AndPredict110 <- read.csv("Predicted_Andrenidae110.csv")
colnames(AndPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
AndPredict220 <- read.csv("Predicted_Andrenidae220.csv")
colnames(AndPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(AndPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(AndPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(AndPredict220)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
AndObserved30 <- read.csv("Observed_Andrenidae30.csv")
colnames(AndObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(AndObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
AndObserved60 <- read.csv("Observed_Andrenidae60.csv")
colnames(AndObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(AndObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
AndObserved110 <- read.csv("Observed_Andrenidae110.csv")
colnames(AndObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(AndObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(AndObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(AndObserved110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
AndObserved220 <- read.csv("Observed_Andrenidae220.csv")
colnames(AndObserved220)[4] <- "Observed" #make column names the same between dfs
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


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Spreadsheets for Completeness")
write.csv(AndCompleteness30, file = "Andrenidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Spreadsheets for Completeness")
write.csv(AndCompleteness60, file = "Andrenidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Spreadsheets for Completeness")
write.csv(AndCompleteness110, file = "Andrenidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Spreadsheets for Completeness")
write.csv(AndCompleteness220, file = "Andrenidae220.csv")

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
ApiObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_full_OR.grd")
ApiObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_full_OR.grd")
ApiObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_full_OR.grd")
ApiObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_full_OR.grd")

#read in predicted
ApiPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_full.grd")
ApiPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_full.grd")
ApiPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_full.grd")
ApiPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_full.grd")

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
ApiObserved30 <- mask(ApiObserved30, NAm)

ApiObserved60 <- mask(ApiObserved60, usaWGS)
ApiObserved60 <- mask(ApiObserved60, NAm)

ApiObserved110 <- mask(ApiObserved110, usaWGS)
ApiObserved110 <- mask(ApiObserved110, NAm)

ApiObserved220 <- mask(ApiObserved220, usaWGS)
ApiObserved220 <- mask(ApiObserved220, NAm)

ApiPredict30 <- mask(ApiPredict30, usaWGS)
ApiPredict30 <- mask(ApiPredict30, NAm)

ApiPredict60 <- mask(ApiPredict60, usaWGS)
ApiPredict60 <- mask(ApiPredict60, NAm)

ApiPredict110 <- mask(ApiPredict110, usaWGS)
ApiPredict110 <- mask(ApiPredict110, NAm)

ApiPredict220 <- mask(ApiPredict220, usaWGS)
ApiPredict220 <- mask(ApiPredict220, NAm)

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
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
write.csv(ApiObserved30, file = "Observed_Apidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
write.csv(ApiObserved60, file = "Observed_Apidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
write.csv(ApiObserved110, file = "Observed_Apidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
write.csv(ApiObserved220, file = "Observed_Apidae220.csv")

#write out all files (predicted)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
write.csv(ApiPredict30, file = "Predicted_Apidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
write.csv(ApiPredict60, file = "Predicted_Apidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
write.csv(ApiPredict110, file = "Predicted_Apidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
write.csv(ApiPredict220, file = "Predicted_Apidae220.csv")

#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
ApiPredict30 <- read.csv("Predicted_Apidae30.csv")
colnames(ApiPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
ApiPredict60 <- read.csv("Predicted_Apidae60.csv")
colnames(ApiPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
ApiPredict110 <- read.csv("Predicted_Apidae110.csv")
colnames(ApiPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
ApiPredict220 <- read.csv("Predicted_Apidae220.csv")
colnames(ApiPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(ApiPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiPredict220)[1] <- "Pixel" #make column names the same between dfs


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
ApiObserved30 <- read.csv("Observed_Apidae30.csv")
colnames(ApiObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
ApiObserved60 <- read.csv("Observed_Apidae60.csv")
colnames(ApiObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
ApiObserved110 <- read.csv("Observed_Apidae110.csv")
colnames(ApiObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(ApiObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(ApiObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(ApiObserved110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
ApiObserved220 <- read.csv("Observed_Apidae220.csv")
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


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Spreadsheets for Completeness")
write.csv(ApiCompleteness30, file = "Apidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Spreadsheets for Completeness")
write.csv(ApiCompleteness60, file = "Apidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Spreadsheets for Completeness")
write.csv(ApiCompleteness110, file = "Apidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Spreadsheets for Completeness")
write.csv(ApiCompleteness220, file = "Apidae220.csv")

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
CollObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Colletidae/Colletidae30_full_OR.grd")
CollObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Colletidae/Colletidae60_full_OR.grd")
CollObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Colletidae/Colletidae110_full_OR.grd")
CollObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Colletidae/Colletidae220_full_OR.grd")

#read in predicted
CollPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Colletidae/Colletidae30_full.grd")
CollPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Colletidae/Colletidae60_full.grd")
CollPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Colletidae/Colletidae110_full.grd")
CollPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Colletidae/Colletidae220_full.grd")

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
CollObserved30 <- mask(CollObserved30, NAm)

CollObserved60 <- mask(CollObserved60, usaWGS)
CollObserved60 <- mask(CollObserved60, NAm)

CollObserved110 <- mask(CollObserved110, usaWGS)
CollObserved110 <- mask(CollObserved110, NAm)

CollObserved220 <- mask(CollObserved220, usaWGS)
CollObserved220 <- mask(CollObserved220, NAm)

CollPredict30 <- mask(CollPredict30, usaWGS)
CollPredict30 <- mask(CollPredict30, NAm)

CollPredict60 <- mask(CollPredict60, usaWGS)
CollPredict60 <- mask(CollPredict60, NAm)

CollPredict110 <- mask(CollPredict110, usaWGS)
CollPredict110 <- mask(CollPredict110, NAm)

CollPredict220 <- mask(CollPredict220, usaWGS)
CollPredict220 <- mask(CollPredict220, NAm)

## PLOT ALL OBSERVED ##
plot(CollObserved30, main = "Colletidae Observed Richness @ 30km x 30km", zlim = range(0, 35), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollObserved60, main = "Colletidae Observed Richness @ 60km x 60km", zlim = range(0, 35), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollObserved110, main = "Colletidae Observed @ 110km x 110km", zlim = range(0, 40), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)

plot(CollObserved220, main = "Colletidae Observed @ 220km x 220km", zlim = range(0, 45), axes = FALSE, box = FALSE)
plot(usaWGS, add = TRUE)
#plot(NAm, add= T)

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


#write out all files (predicted)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
write.csv(CollObserved30, file = "Observed_Colletidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
write.csv(CollObserved60, file = "Observed_Colletidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
write.csv(CollObserved110, file = "Observed_Colletidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
write.csv(CollObserved220, file = "Observed_Colletidae220.csv")



#write out all files (observed)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
write.csv(CollPredict30, file = "Predicted_Colletidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
write.csv(CollPredict60, file = "Predicted_Colletidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
write.csv(CollPredict110, file = "Predicted_Colletidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
write.csv(CollPredict220, file = "Predicted_Colletidae220.csv")


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
CollPredict30 <- read.csv("Predicted_Colletidae30.csv")
colnames(CollPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
CollPredict60 <- read.csv("Predicted_Colletidae60.csv")
colnames(CollPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
CollPredict110 <- read.csv("Predicted_Colletidae110.csv")
colnames(CollPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
CollPredict220 <- read.csv("Predicted_Colletidae220.csv")
colnames(CollPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(CollPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(CollPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(CollPredict220)[1] <- "Pixel" #make column names the same between dfs


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
CollObserved30 <- read.csv("Observed_Colletidae30.csv")
colnames(CollObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
CollObserved60 <- read.csv("Observed_Colletidae60.csv")
colnames(CollObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
CollObserved110 <- read.csv("Observed_Colletidae110.csv")
colnames(CollObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(CollObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(CollObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(CollObserved110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
CollObserved220 <- read.csv("Observed_Colletidae220.csv")
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


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Spreadsheets for Completeness")
write.csv(CollCompleteness30, file = "Colletidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Spreadsheets for Completeness")
write.csv(CollCompleteness60, file = "Colletidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Spreadsheets for Completeness")
write.csv(CollCompleteness110, file = "Colletidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Spreadsheets for Completeness")
write.csv(CollCompleteness220, file = "Colletidae220.csv")

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
HalObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Halictidae/Halictidae30_full_OR.grd")
HalObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Halictidae/Halictidae60_full_OR.grd")
HalObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Halictidae/Halictidae110_full_OR.grd")
HalObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Halictidae/Halictidae220_full_OR.grd")

#read in predicted
HalPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Halictidae/Halictidae30_full.grd")
HalPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Halictidae/Halictidae60_full.grd")
HalPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Halictidae/Halictidae110_full.grd")
HalPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Halictidae/Halictidae220_full.grd")

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
HalObserved30 <- mask(HalObserved30, NAm)

HalObserved60 <- mask(HalObserved60, usaWGS)
HalObserved60 <- mask(HalObserved60, NAm)

HalObserved110 <- mask(HalObserved110, usaWGS)
HalObserved110 <- mask(HalObserved110, NAm)

HalObserved220 <- mask(HalObserved220, usaWGS)
HalObserved220 <- mask(HalObserved220, NAm)

HalPredict30 <- mask(HalPredict30, usaWGS)
HalPredict30 <- mask(HalPredict30, NAm)

HalPredict60 <- mask(HalPredict60, usaWGS)
HalPredict60 <- mask(HalPredict60, NAm)

HalPredict110 <- mask(HalPredict110, usaWGS)
HalPredict110 <- mask(HalPredict110, NAm)

HalPredict220 <- mask(HalPredict220, usaWGS)
HalPredict220 <- mask(HalPredict220, NAm)

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
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
write.csv(HalObserved30, file = "Observed_Halictidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
write.csv(HalObserved60, file = "Observed_Halictidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
write.csv(HalObserved110, file = "Observed_Halictidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
write.csv(HalObserved220, file = "Observed_Halictidae220.csv")


#write out all files (predicted)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
write.csv(HalPredict30, file = "Predicted_Halictidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
write.csv(HalPredict60, file = "Predicted_Halictidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
write.csv(HalPredict110, file = "Predicted_Halictidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
write.csv(HalPredict220, file = "Predicted_Halictidae220.csv")


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
HalPredict30 <- read.csv("Predicted_Halictidae30.csv")
colnames(HalPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
HalPredict60 <- read.csv("Predicted_Halictidae60.csv")
colnames(HalPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
HalPredict110 <- read.csv("Predicted_Halictidae110.csv")
colnames(HalPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
HalPredict220 <- read.csv("Predicted_Halictidae220.csv")
colnames(HalPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(HalPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(HalPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(HalPredict220)[1] <- "Pixel" #make column names the same between dfs


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
HalObserved30 <- read.csv("Observed_Halictidae30.csv")
colnames(HalObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
HalObserved60 <- read.csv("Observed_Halictidae60.csv")
colnames(HalObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
HalObserved110 <- read.csv("Observed_Halictidae110.csv")
colnames(HalObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(HalObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(HalObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(HalObserved110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
HalObserved220 <- read.csv("Observed_Halictidae220.csv")
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


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Spreadsheets for Completeness")
write.csv(HalCompleteness30, file = "Halictidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Spreadsheets for Completeness")
write.csv(HalCompleteness60, file = "Halictidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Spreadsheets for Completeness")
write.csv(HalCompleteness110, file = "Halictidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Spreadsheets for Completeness")
write.csv(HalCompleteness220, file = "Halictidae220.csv")

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
MelObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Melittidae/Melittidae30_full_OR.grd")
MelObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae60_full_OR.grd")
MelObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Melittidae/Melittidae110_full_OR.grd")
MelObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Melittidae/Melittidae220_full_OR.grd")

#read in predicted
MelPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd")
MelPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae60_full.grd")
MelPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Melittidae/Melittidae110_full.grd")
MelPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Melittidae/Melittidae220_full.grd")

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
MelObserved30 <- mask(MelObserved30, NAm)

MelObserved60 <- mask(MelObserved60, usaWGS)
MelObserved60 <- mask(MelObserved60, NAm)

MelObserved110 <- mask(MelObserved110, usaWGS)
MelObserved110 <- mask(MelObserved110, NAm)

MelObserved220 <- mask(MelObserved220, usaWGS)
MelObserved220 <- mask(MelObserved220, NAm)

MelPredict30 <- mask(MelPredict30, usaWGS)
MelPredict30 <- mask(MelPredict30, NAm)

MelPredict60 <- mask(MelPredict60, usaWGS)
MelPredict60 <- mask(MelPredict60, NAm)

MelPredict110 <- mask(MelPredict110, usaWGS)
MelPredict110 <- mask(MelPredict110, NAm)

MelPredict220 <- mask(MelPredict220, usaWGS)
MelPredict220 <- mask(MelPredict220, NAm)

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
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
write.csv(MelObserved30, file = "Observed_Melittidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
write.csv(MelObserved60, file = "Observed_Melittidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
write.csv(MelObserved110, file = "Observed_Melittidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
write.csv(MelObserved220, file = "Observed_Melittidae220.csv")



#write out all files (predicted)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
write.csv(MelPredict30, file = "Predicted_Melittidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
write.csv(MelPredict60, file = "Predicted_Melittidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
write.csv(MelPredict110, file = "Predicted_Melittidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
write.csv(MelPredict220, file = "Predicted_Melittidae220.csv")


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
MelPredict30 <- read.csv("Predicted_Melittidae30.csv")
colnames(MelPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
MelPredict60 <- read.csv("Predicted_Melittidae60.csv")
colnames(MelPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
MelPredict110 <- read.csv("Predicted_Melittidae110.csv")
colnames(MelPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
MelPredict220 <- read.csv("Predicted_Melittidae220.csv")
colnames(MelPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(MelPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(MelPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(MelPredict220)[1] <- "Pixel" #make column names the same between dfs


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
MelObserved30 <- read.csv("Observed_Melittidae30.csv")
colnames(MelObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
MelObserved60 <- read.csv("Observed_Melittidae60.csv")
colnames(MelObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
MelObserved110 <- read.csv("Observed_Melittidae110.csv")
colnames(MelObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(MelObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(MelObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(MelObserved110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
MelObserved220 <- read.csv("Observed_Melittidae220.csv")
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


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Spreadsheets for Completeness")
write.csv(MelCompleteness30, file = "Melittidae30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Spreadsheets for Completeness")
write.csv(MelCompleteness60, file = "Melittidae60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Spreadsheets for Completeness")
write.csv(MelCompleteness110, file = "Melittidae110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Spreadsheets for Completeness")
write.csv(MelCompleteness220, file = "Melittidae220.csv")

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
AndObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full_OR.grd")
ApiObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_full_OR.grd")
ColObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Colletidae/Colletidae30_full_OR.grd")
HalObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Halictidae/Halictidae30_full_OR.grd")
MegObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full_OR.grd")
MelObserved30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Melittidae/Melittidae30_full_OR.grd")

AndObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full_OR.grd")
ApiObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_full_OR.grd")
ColObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Colletidae/Colletidae60_full_OR.grd")
HalObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Halictidae/Halictidae60_full_OR.grd")
MegObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full_OR.grd")
MelObserved60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae60_full_OR.grd")

AndObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full_OR.grd")
ApiObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_full_OR.grd")
ColObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Colletidae/Colletidae110_full_OR.grd")
HalObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Halictidae/Halictidae110_full_OR.grd")
MegObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full_OR.grd")
MelObserved110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Melittidae/Melittidae110_full_OR.grd")

AndObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full_OR.grd")
ApiObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_full_OR.grd")
ColObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Colletidae/Colletidae220_full_OR.grd")
HalObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Halictidae/Halictidae220_full_OR.grd")
MegObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full_OR.grd")
MelObserved220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Melittidae/Melittidae220_full_OR.grd")

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
AndPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Andrenidae/Andrenidae30_full.grd")
ApiPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_full.grd")
ColPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Colletidae/Colletidae30_full.grd")
HalPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Halictidae/Halictidae30_full.grd")
MegPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full.grd")
MelPredict30 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd")

AndPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Andrenidae/Andrenidae60_full.grd")
ApiPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_full.grd")
ColPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Colletidae/Colletidae60_full.grd")
HalPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Halictidae/Halictidae60_full.grd")
MegPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full.grd")
MelPredict60 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae60_full.grd")

AndPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Andrenidae/Andrenidae110_full.grd")
ApiPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_full.grd")
ColPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Colletidae/Colletidae110_full.grd")
HalPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Halictidae/Halictidae110_full.grd")
MegPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full.grd")
MelPredict110 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Melittidae/Melittidae110_full.grd")

AndPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Andrenidae/Andrenidae220_full.grd")
ApiPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_full.grd")
ColPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Colletidae/Colletidae220_full.grd")
HalPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Halictidae/Halictidae220_full.grd")
MegPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full.grd")
MelPredict220 <- raster("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Melittidae/Melittidae220_full.grd")

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
all30obs <- mask(all30obs, NAm)

all60obs <- mask(all60obs, usaWGS)
all60obs <- mask(all60obs, NAm)

all110obs <- mask(all110obs, usaWGS)
all110obs <- mask(all110obs, NAm)

all220obs <- mask(all220obs, usaWGS)
all220obs <- mask(all220obs, NAm)

all30 <- mask(all30, usaWGS)
all30 <- mask(all30, NAm)

all60 <- mask(all60, usaWGS)
all60 <- mask(all60, NAm)

all110 <- mask(all110, usaWGS)
all110 <- mask(all110, NAm)

all220 <- mask(all220, usaWGS)
all220 <- mask(all220, NAm)

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
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
write.csv(AllObserved30, file = "Observed_AllBees30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
write.csv(AllObserved60, file = "Observed_AllBees60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
write.csv(AllObserved110, file = "Observed_AllBees110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
write.csv(AllObserved220, file = "Observed_AllBees220.csv")



#write out all files (predicted)
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
write.csv(AllPredict30, file = "Predicted_AllBees30.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
write.csv(AllPredict60, file = "Predicted_AllBees60.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
write.csv(AllPredict110, file = "Predicted_AllBees110.csv")
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
write.csv(AllPredict220, file = "Predicted_AllBees220.csv")


#fix column names in Predicted
#read in the same ones you just wrote out so that pixel number is included
setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Predicted Values")
AllPredict30 <- read.csv("Predicted_AllBees30.csv")
colnames(AllPredict30)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict30)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict30)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Predicted Values")
AllPredict60 <- read.csv("Predicted_AllBees60.csv")
colnames(AllPredict60)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict60)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict60)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Predicted Values")
AllPredict110 <- read.csv("Predicted_AllBees110.csv")
colnames(AllPredict110)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict110)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict110)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Predicted Values")
AllPredict220 <- read.csv("Predicted_AllBees220.csv")
colnames(AllPredict220)[4] <- "Predicted" #make column names the same between dfs
colnames(AllPredict220)[3] <- "Latitude" #make column names the same between dfs
colnames(AllPredict220)[2] <- "Longitude" #make column names the same between dfs
colnames(AllPredict220)[1] <- "Pixel" #make column names the same between dfs


setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/30km/Dataframes of Observed Values")
AllObserved30 <- read.csv("Observed_AllBees30.csv")
colnames(AllObserved30)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved30)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved30)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved30)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/60km/Dataframes of Observed Values")
AllObserved60 <- read.csv("Observed_AllBees60.csv")
colnames(AllObserved60)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved60)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved60)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved60)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/110km/Dataframes of Observed Values")
AllObserved110 <- read.csv("Observed_AllBees110.csv")
colnames(AllObserved110)[4] <- "Observed" #make column names the same between dfs
colnames(AllObserved110)[3] <- "Latitude" #make column names the same between dfs
colnames(AllObserved110)[2] <- "Longitude" #make column names the same between dfs
colnames(AllObserved110)[1] <- "Pixel" #make column names the same between dfs

setwd("/Users/paige/Dropbox/Symbiota_database/Gap_analysis copy/Ranges/AAA_Family_rasters/220km/Dataframes of Observed Values")
AllObserved220 <- read.csv("Observed_AllBees220.csv")
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


write.csv(AllCompleteness30, file = paste(outputs, "csv/AllBees30km.csv", sep = ""))
write.csv(AllCompleteness60, file = paste(outputs, "csv/AllBees60km.csv", sep = ""))
write.csv(AllCompleteness110, file = paste(outputs, "csv/AllBees110km.csv", sep = ""))
write.csv(AllCompleteness220, file = paste(outputs, "csv/AllBees220km.csv", sep = ""))

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
