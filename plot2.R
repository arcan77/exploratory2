# Downloading and unzipping initial archive
tempfile <- tempfile()
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
download.file(url, tempfile, method="curl")
unzip(tempfile)  # unzip our archive
unlink(tempfile) #delete temporary file

setwd("exdata-data-NEI_data")
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

NEI$Pollutant <- as.factor(NEI$Pollutant)
NEI$type <- as.factor(NEI$type)
NEI$SCC <- as.factor(NEI$SCC)

Data <- merge(NEI,SCC, by.x="SCC", by.y="SCC", all=TRUE)

library(reshape2)
DataMelt <- melt (Data, id=c("SCC","fips","Pollutant","type","year","Data.Category"), measure.vars=c("Emissions"), na.rm=TRUE)
yearDataFips <- dcast (DataMelt, year + fips ~ variable, sum)
library(dplyr)
yearDataBaltimore <- filter(yearDataFips, fips=="24510")

png("plot2.png", width=480,height=480)
plot(yearDataBaltimore$year, yearDataBaltimore$Emissions, type="b", xlab="Year", ylab="Emission, tons", main="Total PM2.5 emission in the Baltimore City by year")
dev.off()
