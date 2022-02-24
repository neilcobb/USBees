library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(dplyr)
library(sf)

shape_files <- "../../inputs/shape_files/"
csv_files <- "../../inputs/csv_data/"
outputs <- "../../outputs/3_Observed_Richness/"

usa <- readOGR(paste(shape_files, "USA", sep = ""))
usa <- usa[usa$STATE_NAME != "Alaska",]
usa <- usa[usa$STATE_NAME != "Hawaii",]
globe <- readOGR(paste(shape_files, "Continents", sep = ""))
NAm <- globe[globe$CONTINENT == "North America",]
NAm <- crop(NAm, extent(-165, -60, 8, 85))
usaWGS <- spTransform(usa, CRS(proj4string(NAm)))


#using all North American records but just the US species list (so that border pixels aren't affected)
alldat <- read.csv(paste(csv_files, "NorAmer_highQual_only_ALLfamilies.csv"), sep = "")
spList <- read.csv(paste(csv_files, "contiguousSpecies_high_Only.csv"), sep = "")
spList <- dplyr::select(spList, (-X)) #don't want that column

##crop spLists
alldatAnd <- alldat[grepl("Andrenidae", alldat$family),]
alldatAnd <- dplyr::select(alldatAnd, c(-X, - X.1, - X.2)) # don't want that column
spListAnd <- spList[grepl("Andrenidae", spList$family),]

alldatColl <- alldat[grepl("Colletidae", alldat$family),]
alldatColl <- dplyr::select(alldatColl, c(-X, - X.1, - X.2))
spListColl <- spList[grepl("Colletidae", spList$family),]

alldatApi <- alldat[grepl("Apidae", alldat$family),]
alldatApi <- dplyr::select(alldatApi, c(-X, - X.1, - X.2))
spListApi <- spList[grepl("Apidae", spList$family),]

alldatHal <- alldat[grepl("Halictidae", alldat$family),]
alldatHal <- dplyr::select(alldatHal, c(-X, - X.1, - X.2))
spListHal <- spList[grepl("Halictidae", spList$family),]

alldatMel <- alldat[grepl("Melittidae", alldat$family),]
alldatMel <- dplyr::select(alldatMel, c(-X, - X.1, - X.2))
spListMel <- spList[grepl("Melittidae", spList$family),]

alldatMeg <- alldat[grepl("Megachilidae", alldat$family),]
alldatMeg <- dplyr::select(alldatMeg, c(-X, - X.1, - X.2))
spListMeg <- spList[grepl("Megachilidae", spList$family),]


#read in all bases
base30 <- raster(paste(shape_files, "base_rasters/base_30km.grd", sep = ""))
base60 <- raster(paste(shape_files, "base_rasters/base_60km.grd", sep = ""))
base110 <- raster(paste(shape_files, "base_rasters/base_110km.grd", sep = ""))
base220 <- raster(paste(shape_files, "base_rasters/base_220km.grd", sep = ""))

#create your blank r at 10km
r <- raster(ncol = 3600, nrow = 1800) #3600:1800 = 10km, 2160:1080 = 15km, 1080:540 = 30km, 540:270 = 60km, 360:180 = 110km

for (i in seq_len(nrow(spListMeg))) {
  sp <- filter(alldatMeg, finalName == paste(spListMeg[i, 1]))
  sp <- dplyr::select(sp, finalLongitude, finalLatitude)

  coordinates(sp) <- c(1, 2) #set coordinates
  projection(sp) <- "+proj=longlat +ellps=WGS84"

  r1 <- rasterize(sp, r, fun = "count", getCover = TRUE)
  r1[r1 > 0] <- 1
  r1[is.na(r1)] <- 0
  r1 <- crop(r1, usaWGS)

  writeRaster(r1, overwrite = TRUE, file = paste(paste(paste(outputs, "Observed_Richness/Megachilidae/10km", sep = ""), paste(spListMeg[i, 1]), sep = "/"), "raster.grd", sep = "_"))

  #resample for other 4 resolutions
  r30 <- aggregate(r1, fact = 3, fun = max)
  r60 <- aggregate(r1, fact = 6, fun = max)
  r110 <- aggregate(r1, fact = 10, fun = max)
  r220 <- aggregate(r1, fact = 20, fun = max)

  #write out each species
  writeRaster(r30, overwrite = TRUE, file = paste(paste(paste(outputs, "Observed_Richness/Megachilidae/30km", sep = ""), paste(spListMeg[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r60, overwrite = TRUE, file = paste(paste(paste(outputs, "Observed_Richness/Megachilidae/60km", sep = ""), paste(spListMeg[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r110, overwrite = TRUE, file = paste(paste(paste(outputs, "Observed_Richness/Megachilidae/110km", sep = ""), paste(spListMeg[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r220, overwrite = TRUE, file = paste(paste(paste(outputs, "Observed_Richness/Megachilidae/220km", sep = ""), paste(spListMeg[i, 1]), sep = "/"), "raster.grd", sep = "_"))

  #to stack, the bases need to be perfectly matched to your new aggregated ones
  base30 <- resample(base30, r30)
  base60 <- resample(base60, r60)
  base110 <- resample(base110, r110)
  base220 <- resample(base220, r220)

  #stack all species for all 4 resolutions and write them out below
  base30 <- base30 + r30
  base60 <- base60 + r60
  base110 <- base110 + r110
  base220 <- base220 + r220

}

writeRaster(base30, overwrite = TRUE, file = paste(outputs, "AAA_Family_rasters/30km/Megachilidae/Megachilidae30_full_OR.grd", sep = ""))
writeRaster(base60, overwrite = TRUE, file = paste(outputs, "AAA_Family_rasters/60km/Megachilidae/Megachilidae60_full_OR.grd", sep = ""))
writeRaster(base110, overwrite = TRUE, file = paste(outputs, "AAA_Family_rasters/110km/Megachilidae/Megachilidae110_full_OR.grd", sep = ""))
writeRaster(base220, overwrite = TRUE, file = paste(outputs, "AAA_Family_rasters/220km/Megachilidae/Megachilidae220_full_OR.grd", sep = ""))


