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

temp<- paste(Data[,8],Data[,9],Data[,10],Data[,12],Data[,13],Data[,14],Data[,15])
RowsWithCoalComb <- grep("[Cc]oal.*[Cc]omb", temp)
DataCoal <- Data[RowsWithCoalComb,]

library(reshape2)
DataMelt <- melt(DataCoal, id=c("SCC","fips","Pollutant","type","year","Data.Category"), measure.vars=c("Emissions"), na.rm=TRUE)
DataCoalYear <- dcast (DataMelt, year ~ variable, sum)

par(mfrow=c(1,1),cex.axis=1)
png("plot4.png", width=480,height=480)
plot(DataCoalYear$year, DataCoalYear$Emissions, type="b", xlab="Year", ylab="Emission, tons", main="Total PM2.5 emission of coal combustion sources by year")
dev.off()
