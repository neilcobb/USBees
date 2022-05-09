library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(dplyr)

shape_files <- "../../inputs/shape_files/"
csv_files <- "../../inputs/csv_data/"
outputs <- "../../outputs/4_Stacking_Rasters/"
script2outputs <- "../../outputs/2_Range_Maps/"

usa <- readOGR(paste(shape_files, "USA", sep = ""))
globe <- readOGR(paste(shape_files, "Continents", sep = ""))
nam <- globe[globe$CONTINENT == "North America",]
nam <- crop(nam, extent(-165, -60, 8, 85))
usaWGS <- spTransform(usa, CRS(proj4string(nam)))


spList <- read.csv(paste(csv_files, "contiguousSpecies_high_Only.csv"), sep = "")

spList <- dplyr::select(spList, (-X)) #don't want that column


##crop lists by family
spListAnd <- spList[grepl("Andrenidae", spList$family),]
spListColl <- spList[grepl("Colletidae", spList$family),]
spListMeg <- spList[grepl("Megachilidae", spList$family),]
spListMel <- spList[grepl("Melittidae", spList$family),]
spListHal <- spList[grepl("Halictidae", spList$family),]
spListApi <- spList[grepl("Apidae", spList$family),]

#each time you run the code below
#you must change all family information
#and all resolution information
#for whatever specific combination you wish to stack


#create an initial raster to make the framework
i <- 1
p1 <- raster(paste(paste(paste(script2outputs, "Ranges/Apidae/220km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
p1[is.na(p1[])] <- 0
ensm <- p1


for (i in seq_len(nrow(spListApi))) {
  p <- raster(paste(paste(paste(script2outputs, "Ranges/Apidae/220km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  p[is.na(p[])] <- 0
  ensm <- ensm + p
}

Apidae220_Full <- mask(ensm, usaWGS)
box <- c(-125, -65, 25, 50)
plot(Apidae220_Full, ext = extent(box))
plot(usaWGS, add = TRUE)
plot(nam, add = TRUE)
writeRaster(Apidae220_Full, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_full.grd", sep = ""))

