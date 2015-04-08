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
RowsWithMotor <- grep("[Mm]otor.*[Vv]ehicle", temp)
DataMotor <- Data[RowsWithMotor ,]
DataMotor <- filter(DataMotor, DataMotor$fips %in% c("24510","06037"))


library(reshape2)
DataMelt <- melt(DataMotor, id=c("SCC","fips","Pollutant","type","year","Data.Category"), measure.vars=c("Emissions"), na.rm=TRUE)
DataMotorBaltimoreLA <- dcast (DataMelt, year + fips ~ variable, sum)

DataMotorBaltimoreLA$fips <- factor(DataMotorBaltimoreLA$fips, levels=c("06037", "24510"), labels=c("Los Angeles", "Baltimore"))
png("plot6.png", width=480,height=480)
g <- ggplot(aes(year, Emissions), data=DataMotorBaltimoreLA,group = fips)
g + geom_point(aes(color=fips), alpha=0.8, size=4)+
    #geom_path()+
    facet_wrap(~fips ,scales = "free",ncol=1,nrow=2)+
    labs(x = "Year", y="Emissions, tons", title="PM2.5 emission of motor vehicles")+
    geom_smooth(size=0.5, method="lm")+
    theme_bw(base_family="Verdana", base_size=10)+
    theme(legend.title=element_blank())
dev.off()


#png("plot6.png", width=480,height=480)
#par(mfrow=c(1,1),cex.axis=1, cex=0.8)
#with(DataMotorBaltimoreLA, plot(year, Emissions, xlab="Year", ylab="Emission, tons", main="PM2.5 emission of motor vehicles", type="n"))
#with(DataMotorBaltimoreLA[DataMotorBaltimoreLA$fips=="24510",], lines(year, Emissions, col="red",type="b", xlab="Year", ylab="Emission, tons", main="PM2.5 emission"))
#with(DataMotorBaltimoreLA[DataMotorBaltimoreLA$fips=="06037",], lines(year, Emissions, col="blue",type="b", xlab="Year", ylab="Emission, tons", main="PM2.5 emission"))
#legend("center", legend=c("Los Angeles","Baltimore"), lty=1, col=c("blue","red"))
#dev.off()