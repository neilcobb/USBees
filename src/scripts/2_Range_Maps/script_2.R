library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(dplyr)

shape_files <- "../../inputs/shape_files/"
csv_files <- "../../inputs/csv_data/"
outputs <- "../../outputs/2_Range_Maps/"

usa <- readOGR(paste(shape_files, "USA", sep = ""))
globe <- readOGR(paste(shape_files, "Continents", sep = ""))
nam <- globe[globe$CONTINENT == "North America",]
nam <- crop(nam, extent(-165, -60, 8, 85))
usaWGS <- spTransform(usa, CRS(proj4string(nam)))

alldat <- read.csv(paste(csv_files, "NorAmer_highQual_only_ALLfamilies.csv"), sep = "")
spListAll <- read.csv(paste(csv_files, "contiguousSpecies_high_Only.csv"), sep = "")

pref <- read.csv(paste(csv_files, "species_needs_corrected.csv"), sep = "")

#read in landfire layers
ag <- raster(paste(shape_files, "Landfire10km_mask/km10/agri", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
ag <- projectRaster(ag, crs = "+proj=longlat +datum=WGS84 +no_def")
an <- raster(paste(shape_files, "Landfire10km_mask/km10/an_gram", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
an <- projectRaster(an, crs = "+proj=longlat +datum=WGS84 +no_def")
ba <- raster(paste(shape_files, "Landfire10km_mask/km10/bare", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
ba <- projectRaster(ba, crs = "+proj=longlat +datum=WGS84 +no_def")
dc <- raster(paste(shape_files, "Landfire10km_mask/km10/dec_clos", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
dc <- projectRaster(dc, crs = "+proj=longlat +datum=WGS84 +no_def")
do <- raster(paste(shape_files, "Landfire10km_mask/km10/dec_open", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
do <- projectRaster(do, crs = "+proj=longlat +datum=WGS84 +no_def")
dsh <- raster(paste(shape_files, "Landfire10km_mask/km10/dec_shrub", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
dsh <- projectRaster(dsh, crs = "+proj=longlat +datum=WGS84 +no_def")
dsp <- raster(paste(shape_files, "Landfire10km_mask/km10/dec_sparse", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
dsp <- projectRaster(dsp, crs = "+proj=longlat +datum=WGS84 +no_def")
dv <- raster(paste(shape_files, "Landfire10km_mask/km10/developed", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
dv <- projectRaster(dv, crs = "+proj=longlat +datum=WGS84 +no_def")
ec <- raster(paste(shape_files, "Landfire10km_mask/km10/ev_clos1", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
ec <- projectRaster(ec, crs = "+proj=longlat +datum=WGS84 +no_def")
ed <- raster(paste(shape_files, "Landfire10km_mask/km10/ev_dwaf", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
ed <- projectRaster(ed, crs = "+proj=longlat +datum=WGS84 +no_def")
eo <- raster(paste(shape_files, "Landfire10km_mask/km10/ev_open", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
eo <- projectRaster(eo, crs = "+proj=longlat +datum=WGS84 +no_def")
esh <- raster(paste(shape_files, "Landfire10km_mask/km10/ev_shrub", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
esh <- projectRaster(esh, crs = "+proj=longlat +datum=WGS84 +no_def")
esp <- raster(paste(shape_files, "Landfire10km_mask/km10/ev_sparse", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
esp <- projectRaster(esp, crs = "+proj=longlat +datum=WGS84 +no_def")
mc <- raster(paste(shape_files, "Landfire10km_mask/km10/mix_close", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
mc <- projectRaster(mc, crs = "+proj=longlat +datum=WGS84 +no_def")
md <- raster(paste(shape_files, "Landfire10km_mask/km10/mix_dwaf", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
md <- projectRaster(md, crs = "+proj=longlat +datum=WGS84 +no_def")
mo <- raster(paste(shape_files, "Landfire10km_mask/km10/mix_open", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
mo <- projectRaster(mo, crs = "+proj=longlat +datum=WGS84 +no_def")
msh <- raster(paste(shape_files, "Landfire10km_mask/km10/mix_shrub", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
msh <- projectRaster(msh, crs = "+proj=longlat +datum=WGS84 +no_def")
msp <- raster(paste(shape_files, "Landfire10km_mask/km10/mix_sparse", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
msp <- projectRaster(msp, crs = "+proj=longlat +datum=WGS84 +no_def")
pg <- raster(paste(shape_files, "Landfire10km_mask/km10/per_gram", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
pg <- projectRaster(pg, crs = "+proj=longlat +datum=WGS84 +no_def")
pgg <- raster(paste(shape_files, "Landfire10km_mask/km10/per_gramgras", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
pgg <- projectRaster(pgg, crs = "+proj=longlat +datum=WGS84 +no_def")
pgs <- raster(paste(shape_files, "Landfire10km_mask/km10/per_gramstep", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
pgs <- projectRaster(pgs, crs = "+proj=longlat +datum=WGS84 +no_def")
sv <- raster(paste(shape_files, "Landfire10km_mask/km10/sparseveg", sep = ""), crs = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
sv <- projectRaster(sv, crs = "+proj=longlat +datum=WGS84 +no_def")


#crop the North American records so that it's only records for the US species
alldat_other <- anti_join(alldat, spListAll, by = "finalName") # 86k records for species not in US period
alldat <- anti_join(alldat, alldat_other, by = "finalName") #good, 2.15 mil records for Nor America that involve the 3159 US species


#step 1 is having subset of data that have 3 or more unique coordinates
#first create list of unique coords per species
alldat2 <- alldat
alldat2$coords <- paste(alldat2$finalLatitude, alldat2$finalLongitude,
                       sep = ", ") #combine coords into one column

alldat2 <- alldat2 %>%
  group_by(finalName) #group by species

#add column with how many unique lat/lons for each species
alldat2 <- alldat2 %>% mutate(
  unique <- length(unique(coords)))

#condense that, and then make list of species that are 2 or under
#and another that is the remaining ones that do have "enough coords"
#keep the ones that have "enough coords" called spList for convenience
perSpecies_df <- count(alldat2, finalName, unique)
perSpecies_df <- perSpecies_df %>% arrange(unique)
sp_tooFewCoords <- subset(perSpecies_df, unique <= 2)
spList <- anti_join(spListAll, sp_tooFewCoords, by = "finalName") #good ones with enough coords
sp_tooFewCoords <- anti_join(spListAll, spList, by = "finalName") #run again, includes family
sp_tooFewCoords <- dplyr::select(sp_tooFewCoords, - X)

#there are an an additional 43 species with not enough unique points
# because there are only 1 or 2 unique coords in the US!!
#the rest are in North America
#add them to the "too few coords" dataframe
additional43 <- read.csv(paste(csv_data, "43_additional_lacking_uniq_points.csv", sep = ""))
sp_tooFewCoords <- rbind(sp_tooFewCoords, additional43)


##crop lists by family (first, the ones that have ENOUGH coords)
alldatAnd <- alldat[grepl("Andrenidae", alldat$family),]
alldatAnd <- dplyr::select(alldatAnd, (-X)) #don't want that column
spListAnd <- spList[grepl("Andrenidae", spList$family),]
spListAnd <- dplyr::select(spListAnd, (-X)) #don't want that column

alldatColl <- alldat[grepl("Colletidae", alldat$family),]
alldatColl <- dplyr::select(alldatColl, (-X))
spListColl <- spList[grepl("Colletidae", spList$family),]
spListColl <- dplyr::select(spListColl, (-X))

alldatMeg <- alldat[grepl("Megachilidae", alldat$family),]
alldatMeg <- dplyr::select(alldatMeg, (-X))
spListMeg <- spList[grepl("Megachilidae", spList$family),]
spListMeg <- dplyr::select(spListMeg, (-X))

alldatMel <- alldat[grepl("Melittidae", alldat$family),]
alldatMel <- dplyr::select(alldatMel, (-X))
spListMel <- spList[grepl("Melittidae", spList$family),]
spListMel <- dplyr::select(spListMel, (-X))

alldatHal <- alldat[grepl("Halictidae", alldat$family),]
alldatHal <- dplyr::select(alldatHal, (-X))
spListHal <- spList[grepl("Halictidae", spList$family),]
spListHal <- dplyr::select(spListHal, (-X))

alldatApi <- alldat[grepl("Apidae", alldat$family),]
alldatApi <- dplyr::select(alldatApi, (-X))
spListApi <- spList[grepl("Apidae", spList$family),]
spListApi <- dplyr::select(spListApi, (-X))


#make individual family dfs for this subset too (NOT ENOUGH cords to make MCP)
#461 total
sp_tooFewCoordsAnd <- sp_tooFewCoords[grepl("Andrenidae", sp_tooFewCoords$family),]
sp_tooFewCoordsColl <- sp_tooFewCoords[grepl("Colletidae", sp_tooFewCoords$family),]
sp_tooFewCoordsMeg <- sp_tooFewCoords[grepl("Megachilidae", sp_tooFewCoords$family),]
sp_tooFewCoordsMel <- sp_tooFewCoords[grepl("Melittidae", sp_tooFewCoords$family),] #none
sp_tooFewCoordsHal <- sp_tooFewCoords[grepl("Halictidae", sp_tooFewCoords$family),]
sp_tooFewCoordsApi <- sp_tooFewCoords[grepl("Apidae", sp_tooFewCoords$family),]



#step 2 is to read in the bases
base30 <- raster(paste(shape_files, "base_rasters/base_30km.grd", sep = ""))
base60 <- raster(paste(shape_files, "base_rasters/base_60km.grd", sep = ""))
base110 <- raster(paste(shape_files, "base_rasters/base_110km.grd", sep = ""))
base220 <- raster(paste(shape_files, "base_rasters/base_220km.grd", sep = ""))

#create your blank r at 10km
r <- raster(ncol = 3600, nrow = 1800) #3600:1800 = 10km, 2160:1080 = 15km, 1080:540 = 30km, 540:270 = 60km, 360:180 = 110km


#step 3 is to run by family using the MCP code
#change output directories, spList, and alldat each time
#depending on the family you are running for
#example below is for Apidae

for (i in seq_len(nrow(spListApi))) {
  sp <- filter(alldatApi, finalName == paste(spListApi[i, 1])) #column 1 is final name
  sp <- dplyr::select(sp, finalLongitude, finalLatitude)

  ch <- chull(sp)
  coords <- sp[c(ch, ch[1]),] #closed polygon

  pols <- SpatialPolygons(list(Polygons(list(Polygon(coords)), 1)), proj4string = CRS("+proj=longlat +datum=WGS84"))

  r1 <- rasterize(pols, r, getCover = TRUE)
  r1[r1 > 0] <- 1
  r1 <- crop(r1, usaWGS)

  ppsub2 <- pref %>%
    filter(finalName == paste(spListApi[i, 1])) %>%
    filter(Pct > 10) #only keep if LF pref is over 10% of points

  #7 is the column for LF type abbreviation, that's why it keeps being used
  #stack() grids of landfire_keepers
  if (nrow(ppsub2) == 1) {
    mask <- get(ppsub2[1, 7])
  } else if (nrow(ppsub2) == 2) {
    mask <- merge(get(ppsub2[1, 7]), get(ppsub2[2, 7]))
  } else if (nrow(ppsub2) == 3) {
    mask <- merge(get(ppsub2[1, 7]), get(ppsub2[2, 7]), get(ppsub2[3, 7]))
  } else if (nrow(ppsub2) == 4) {
    mask <- merge(get(ppsub2[1, 7]), get(ppsub2[2, 7]), get(ppsub2[3, 7]), get(ppsub2[4, 7]))
  } else if (nrow(ppsub2) == 5) {
    mask <- merge(get(ppsub2[1, 7]), get(ppsub2[2, 7]), get(ppsub2[3, 7]), get(ppsub2[4, 7]), get(ppsub2[5, 7]))
  } else if (nrow(ppsub2) == 7) {
    mask <- merge(get(ppsub2[1, 7]), get(ppsub2[2, 7]), get(ppsub2[3, 7]), get(ppsub2[4, 7]), get(ppsub2[5, 7]), get(ppsub2[7, 7]))
  } else if (nrow(ppsub2) == 7) {
    mask <- merge(get(ppsub2[1, 7]), get(ppsub2[2, 7]), get(ppsub2[3, 7]), get(ppsub2[4, 7]), get(ppsub2[5, 7]), get(ppsub2[7, 7]), get(ppsub2[7, 7]))
  }

  mask1 <- resample(mask, r1) #ensure that resolution and extents match

  spRangeN <- mask(r1, mask1)
  writeRaster(spRangeN, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/10km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))

  #sample up from 10x10 km to make the other four resolutions
  r30 <- aggregate(spRangeN, fact = 3, fun = max) #fact = factor of increase
  r30[is.na(r30[])] <- 0

  r60 <- aggregate(spRangeN, fact = 6, fun = max)
  r60[is.na(r60[])] <- 0

  r110 <- aggregate(spRangeN, fact = 10, fun = max)
  r110[is.na(r110[])] <- 0

  r220 <- aggregate(spRangeN, fact = 20, fun = max)
  r220[is.na(r220[])] <- 0

  #write out each species
  writeRaster(r30, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/30km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r60, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/60km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r110, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/110km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r220, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/220km", sep = ""), paste(spListApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))

  #to stack, the bases need to be perfectly matched to your new aggregated ones
  base30 <- resample(base30, r30)
  base60 <- resample(base60, r60)
  base110 <- resample(base110, r110)
  base220 <- resample(base220, r220)

  #now stack all of the species for each resolution, and write out the final file
  base30 <- base30 + r30
  base60 <- base60 + r60
  base110 <- base110 + r110
  base220 <- base220 + r220
}

writeRaster(base30, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_A.grd", sep = ""))
writeRaster(base60, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_A.grd", sep = ""))
writeRaster(base110, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_A.grd", sep = ""))
writeRaster(base220, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_A.grd", sep = ""))


#Next, need to run a different type of range code
#For the ~461 that don't have enough unique coords to make a MCP
#for this method, just shading in the 1 or 2 pixels that a point falls in

#NOTE: it's going to override a total of 43 species that you already ran above
#BUT really, their rasters ended up empty because not enough unique points in the US

#step 4 is to read in the bases again so that they are fresh
base30 <- raster(paste(shape_files, "base_rasters/base_30km.grd", sep = ""))
base60 <- raster(paste(shape_files, "base_rasters/base_60km.grd", sep = ""))
base110 <- raster(paste(shape_files, "base_rasters/base_110km.grd", sep = ""))
base220 <- raster(paste(shape_files, "base_rasters/base_220km.grd", sep = ""))

#create your blank r at 10km
r <- raster(ncol = 3600, nrow = 1800) #3600:1800 = 10km, 2160:1080 = 15km, 1080:540 = 30km, 540:270 = 60km, 360:180 = 110km


#still running them at 10km And then scaling up
#(even though no masking is occurring)
#make sure you use the sp_tooFewCoords variation of the dataframe
#and change each time depending on family
for (i in seq_len(nrow(sp_tooFewCoordsApi))) {
  log_sciname <- sp_tooFewCoordsApi[i, 1]

  sp <- filter(alldatApi, finalName == paste(sp_tooFewCoordsApi[i, 1])) #column 1 is final name
  sp <- dplyr::select(sp, finalLongitude, finalLatitude)

  coordinates(sp) <- c(1, 2) #set coordinates

  projection(sp) <- "+proj=longlat +ellps=WGS84"

  r <- raster(ncol = 3600, nrow = 1800) #2160:1080 = 15km, 1080:540 = 30km, 540:270 = 60km, 360:180 = 110km, 180:90 = 220km
  r1 <- rasterize(sp, r, fun = "count", getCover = TRUE)
  r1[r1 > 0] <- 1
  r1[is.na(r1)] <- 0
  r1 <- crop(r1, usaWGS)

  writeRaster(r1, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/10km", sep = ""), paste(sp_tooFewCoordsApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))

  r30 <- aggregate(r1, fact = 3, fun = max) #fact = factor of increase
  r60 <- aggregate(r1, fact = 6, fun = max)
  r110 <- aggregate(r1, fact = 10, fun = max)
  r220 <- aggregate(r1, fact = 20, fun = max)

  writeRaster(r30, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/30km", sep = ""), paste(sp_tooFewCoordsApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r60, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/60km", sep = ""), paste(sp_tooFewCoordsApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r110, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/110km", sep = ""), paste(sp_tooFewCoordsApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))
  writeRaster(r220, overwrite = TRUE, file = paste(paste(paste(outputs, "Ranges/Apidae/220km", sep = ""), paste(sp_tooFewCoordsApi[i, 1]), sep = "/"), "raster.grd", sep = "_"))

  #to stack, the bases need to be perfectly matched to your new aggregated ones
  base30 <- resample(base30, r30)
  base60 <- resample(base60, r60)
  base110 <- resample(base110, r110)
  base220 <- resample(base220, r220)

  #now stack all of the species for each res, And write them out below
  base30 <- base30 + r30
  base60 <- base60 + r60
  base110 <- base110 + r110
  base220 <- base220 + r220
}

writeRaster(base30, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_B.grd", sep = ""))
writeRaster(base60, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_B.grd", sep = ""))
writeRaster(base110, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_B.grd", sep = ""))
writeRaster(base220, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_B.grd", sep = ""))


#step 6 need to stack the two created stacks for each family
#looking above, will see that those with enough coords was labeled "A"
#vs too few coords labeled "B"
#can instead choose to stack all individual rasters using "stacking code" provided
#if not, continue using this method beloww

Apidae30_A <- raster(paste(outputs, "Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_A.grd", sep = ""))
Apidae30_B <- raster(paste(outputs, "Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_B.grd", sep = ""))
Apidae30_Full <- Apidae30_A + Apidae30_B
writeRaster(Apidae30_Full, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/30km/Apidae/Apidae30_full.grd", sep = ""))

Apidae60_A <- raster(paste(outputs, "Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_A.grd", sep = ""))
Apidae60_B <- raster(paste(outputs, "Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_B.grd", sep = ""))
Apidae60_Full <- Apidae60_A + Apidae60_B
writeRaster(Apidae60_Full, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/60km/Apidae/Apidae60_full.grd", sep = ""))

Apidae110_A <- raster(paste(outputs, "Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_A.grd", sep = ""))
Apidae110_B <- raster(paste(outputs, "Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_B.grd", sep = ""))
Apidae110_Full <- Apidae110_A + Apidae110_B
writeRaster(Apidae110_Full, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/110km/Apidae/Apidae110_full.grd", sep = ""))

Apidae220_A <- raster(paste(outputs, "Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_A.grd", sep = ""))
Apidae220_B <- raster(paste(outputs, "Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_B.grd", sep = ""))
Apidae220_Full <- Apidae220_A + Apidae220_B
writeRaster(Apidae220_Full, overwrite = TRUE, file = paste(outputs, "Ranges/AAA_Family_rasters/220km/Apidae/Apidae220_full.grd", sep = ""))


#Melittidae is different, only have grd file A!
#so just rename A to be the Full
Melittidae30_A <- raster(paste(output, "Ranges/AAA_Family_rasters/30km/Melittidae/Melittidae30_A.grd", sep = ""))
Melittidae30_Full <- Melittidae30_A
writeRaster(Melittidae30_Full, overwrite = TRUE, file = paste(output, "Ranges/AAA_Family_rasters/30km/Melittidae/Melittidae30_full.grd", sep = ""))

Melittidae60_A <- raster(paste(output, "Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae60_A.grd", sep = ""))
Melittidae60_Full <- Melittidae60_A
writeRaster(Melittidae60_Full, overwrite = TRUE, file = paste(output, "Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae60_full.grd", sep = ""))

Melittidae110_A <- raster(paste(output, "Ranges/AAA_Family_rasters/60km/Melittidae/Melittidae110_A.grd", sep = ""))
Melittidae110_Full <- Melittidae110_A
writeRaster(Melittidae110_Full, overwrite = TRUE, file = paste(output, "Ranges/AAA_Family_rasters/110km/Melittidae/Melittidae110_full.grd", sep = ""))

Melittidae220_A <- raster(paste(output, "Ranges/AAA_Family_rasters/220km/Melittidae/Melittidae220_A.grd", sep = ""))
Melittidae220_Full <- Melittidae220_A
writeRaster(Melittidae220_Full, overwrite = TRUE, file = paste(output, "Ranges/AAA_Family_rasters/220km/Melittidae/Melittidae220_full.grd", sep = ""))
