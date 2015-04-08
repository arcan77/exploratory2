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

DataMelt <- melt (Data, id=c("SCC","fips","Pollutant","type","year","Data.Category"), measure.vars=c("Emissions"), na.rm=TRUE)
yearDataTypes <- dcast (DataMelt, year + type ~ variable, sum)

#Making ggplot with faced linear formulas
lm_eqn = function(df){
    m = lm(Emissions ~ year, df);
    eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
                     list(a = format(coef(m)[1], digits = 2), 
                          b = format(coef(m)[2], digits = 2), 
                          r2 = format(summary(m)$r.squared, digits = 3)))
    as.character(as.expression(eq));                 
}

library(plyr)
eq <- ddply(yearDataTypes,.(type),lm_eqn)

library(ggplot2)
png("plot3.png", width=480,height=480)
g <- ggplot(yearDataTypes, aes(year,Emissions))
g + geom_point(aes(color=type), alpha=0.8, size=4)+
    #geom_path()+
    facet_wrap(~ type, ncol=2, nrow=2,scales = "free")+
    labs(x = "Year", y="Emissions, tons", title="PM2.5 emission for POINT type")+
    geom_smooth(size=0.5, method="lm")+
    theme_bw(base_family="Verdana", base_size=10)
    #geom_text(aes(x = 2004,label=V1), parse = TRUE,size=4, data=eq,inherit.aes=FALSE)
dev.off()
