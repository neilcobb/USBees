library(raster)
library(rgdal)
library(wesanderson)
library(sp)
library(rgeos)
library(viridis)
library(dplyr)

library(colorspace)
mycols4 <- rev(hcl.colors(100, "ag_GrnYl")) #using this one for now
mycols6 <- magma(100, alpha = 1, begin = 0, end = 1, direction = -1) ##currently using this one from viridis package

shape_files <- "../../inputs/shape_files/"
csv_files <- "../../inputs/csv_data/"
outputs <- "../../outputs/6_Completeness_Maps/"
script5outputs <- "../../outputs/5_Richness_Plots_Dataframes/csv/"

globe <- readOGR(paste(shape_files, "Continents", sep = ""))
nam <- globe[globe$CONTINENT == "North America",]
nam <- crop(nam, extent(-165, -60, 8, 85))
usa <- readOGR(paste(shape_files, "USA", sep = ""))
usaWGS <- spTransform(usa, CRS(proj4string(nam)))

### FOR 30km MAPS ###

div <- read.csv(paste(script5outputs, "AllFamilies30km.csv", sep = ""))
colnames(div)[3] <- "Longitude" # make column names the same between dfs
colnames(div)[4] <- "Latitude" # make column names the same between dfs

colnames(div)[6] <- "Longitude" # make column names the same between dfs
colnames(div)[7] <- "Latitude" # make column names the same between dfs

div$Completeness[div$Completeness > 100] <- 100

x <- raster(xmn = -125, xmx = -65, ymn = 25.5, ymx = 50.5, res = .33, crs = "+proj=longlat +datum=WGS84")

comp <- rasterize(div[, c("Longitude", "Latitude")], x, div[, "Completeness"], fun = max)
plot(comp, col = mycols4, zlim = range(0, 100), axes = FALSE, bty = "n")

comp2 <- mask(comp, usaWGS)

plot(comp2, interpolate = FALSE, add = FALSE, legend = TRUE, axes = FALSE, box = FALSE,
     col = mycols4, main = "All @ 30km x 30km Resolution", zlim = range(0, 100))
plot(usaWGS, bg = "transparent", add = TRUE)

### FOR 60km MAPS ###

div <- read.csv(paste(script5outputs, "AllFamilies60km.csv", sep = ""))
colnames(div)[3] <- "Longitude" # make column names the same between dfs
colnames(div)[4] <- "Latitude" # make column names the same between dfs

colnames(div)[6] <- "Longitude" # make column names the same between dfs
colnames(div)[7] <- "Latitude" # make column names the same between dfs

#div$Completeness[div$Completeness > 100] <- 100

x <- raster(xmn = -125, xmx = -65, ymn = 25.5, ymx = 50.5, res = .66, crs = "+proj=longlat +datum=WGS84")

comp <- rasterize(div[, c("Longitude", "Latitude")], x, div[, "Completeness"], fun = max)
plot(comp, col = mycols4, zlim = range(0, 100))


comp2 <- mask(comp, usaWGS)

plot(comp2, interpolate = FALSE, add = FALSE, legend = TRUE, axes = FALSE, box = FALSE,
     col = mycols4, main = "All Completeness @ 60km x 60km", zlim = range(0, 100))
plot(usaWGS, bg = "transparent", add = TRUE)

### FOR 110km MAPS ###

div <- read.csv(paste(script5outputs, "AllFamilies110km.csv", sep = ""))
colnames(div)[3] <- "Longitude" # make column names the same between dfs
colnames(div)[4] <- "Latitude" # make column names the same between dfs

colnames(div)[6] <- "Longitude" # make column names the same between dfs
colnames(div)[7] <- "Latitude" # make column names the same between dfs

#div$Completeness[div$Completeness > 100] <- 100

x <- raster(xmn = -125, xmx = -65, ymn = 25.5, ymx = 50.5, res = 1, crs = "+proj=longlat +datum=WGS84")

comp <- rasterize(div[, c("Longitude", "Latitude")], x, div[, "Completeness"], fun = max)
plot(comp, col = mycols4, zlim = range(0, 100))

comp2 <- mask(comp, usaWGS)

plot(comp2, interpolate = FALSE, add = FALSE, legend = TRUE, axes = FALSE, box = FALSE,
     col = mycols4, main = "All Completeness @ 110km x 110km", zlim = range(0, 100))
plot(usaWGS, bg = "transparent", add = TRUE)


### FOR 220km MAPS ###

div <- read.csv(paste(script5outputs, "AllFamilies220km.csv", sep = ""))
colnames(div)[3] <- "Longitude" # make column names the same between dfs
colnames(div)[4] <- "Latitude" # make column names the same between dfs

colnames(div)[6] <- "Longitude" # make column names the same between dfs
colnames(div)[7] <- "Latitude" # make column names the same between dfs

#div$Completeness[div$Completeness > 100] <- 100

x <- raster(xmn = -125, xmx = -65, ymn = 25.5, ymx = 50.5, res = 2, crs = "+proj=longlat +datum=WGS84")

comp <- rasterize(div[, c("Longitude", "Latitude")], x, div[, "Completeness"], fun = max)
plot(comp, col = mycols4, zlim = range(0, 100))

comp2 <- mask(comp, usaWGS)

plot(comp2, interpolate = FALSE, add = FALSE, legend = TRUE, axes = FALSE, box = FALSE,
     col = mycols4, main = "All Completeness @ 220km x 220km", zlim = range(0, 100))
plot(usaWGS, bg = "transparent", add = TRUE)
