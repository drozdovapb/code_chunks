library(openxlsx)

#read data
setwd("D:/Rabochee/G. faciatus/??????? ?? ???? ??????????/???.??????/")
dataB <- read.xlsx("for R.xlsx", sheet=1)
#????????????? ???????????? ??. ??????? (?? ???????????)
dataB$Factor <- factor(dataB$Factor, levels=unique(dataB$Factor))
#look at the data
#str(data)
# View(data) 

#statistics here

library("PMCMR")

dunn <- function(parameter, data) {
    gi.met1.raw <- data[,c(parameter,"Factor")] #read.xlsx("??????? ???????? ???????.xlsx",sheet=3,rows=c(1,11:17),cols=1:7)
    gi.met1.raw
    colnames(gi.met1.raw) <- c("values", "groups")
    gi.met1.raw$groups <- relevel(gi.met1.raw$group, "5-6")
    kruskal.test(x=gi.met1.raw[,1], g=gi.met1.raw[,2])
    result <- dunn.test.control(gi.met1.raw[,1], gi.met1.raw[,2], p.adjust.method="hommel")
    print(result)
    return(result)
}
#Shira: no 5-6 => use 7 as the reference factor level
dunnS <- function(parameter, data) {
    gi.met1.raw <- data[,c(parameter,"Factor")] #read.xlsx("??????? ???????? ???????.xlsx",sheet=3,rows=c(1,11:17),cols=1:7)
    gi.met1.raw
    colnames(gi.met1.raw) <- c("values", "groups")
    gi.met1.raw$groups <- relevel(gi.met1.raw$group, "7")
    kruskal.test(x=gi.met1.raw[,1], g=gi.met1.raw[,2])
    result <- dunn.test.control(gi.met1.raw[,1], gi.met1.raw[,2], p.adjust.method="hommel")
    print(result)
    return(result)
}


result.CATB <- dunn("CAT", dataB)

#decide what is significantly different
find.signif <- function(result) {
    signif <- ifelse(result$p.value < 0.05, "*", "")
    signif <- c(signif[1:2], "", signif[3:length(signif)])
}

signifB <- find.signif(result.CATB)

#and how to color them
choose.color <- function(result, data, parameter) {
    bp <- boxplot(data[,parameter] ~ data$Factor, plot=F)
    which.control <- as.numeric(which(levels(droplevels(
        data$Factor[!is.na(data[,parameter])])) %in% c('5-6', '7')))
    median <- bp$stat[3,]
    median <- median[!is.na(median)]
    pval <- result$p.value
    #color <- ifelse(result$p.value > 0.05, "white", 
    #            ifelse(median > median[3], "lightgoldenrod1", "paleturquoise2"))
    if (which.control == 1) pval <- c(1, pval)
    if (which.control > 1) {
        pval <- c(pval[1:which.control-1], 1, 
                  pval[which.control:length(pval)])}
    color <- rep("white", length(median))
    for (i in (1:length(median))) {
        if (pval[i] < 0.05) {
            if(median[i] > median[which.control]) color[i] <- "lightgoldenrod1"
            else color[i] <- "paleturquoise2" }
    }
    color[which.control] <- "palegreen"
    
    #    color <- ifelse(result$p.value < 0.05, 
    #                    ifelse(median > median[3], "lightgoldenrod1", "paleturquoise2") 
    #                    )
    #if ('5-6' %in% levels(data$Factor)) { 
    #    which.control <- as.numeric(which(levels(droplevels(
    #      data$Factor[!is.na(data[,parameter])])) %in% c('5-6', '7'))) #} 
    #else (which.control <- which(levels(data$Factor) == '7'))
    #    if (which.control == 1) color <- c("palegreen", color)
    #    if (which.control > 1) {
    #      color <- c(color[1:which.control-1], "palegreen", 
    #                 color[which.control:length(color)])}
    return(color)
}


colorB <- choose.color(result.CATB, dataB, "CAT")
colorL <- choose.color(result.CATL, dataL, "CAT")
colorF <- choose.color(result.CATF, dataF, "CAT")
colorS <- choose.color(result.CATS, dataS, "CAT")
colorI <- choose.color(result.CATI, dataI, "CAT")

#install ggplot2 if you don't have it
if (!"ggplot2" %in% installed.packages()) install.packages("ggplot2")
#load ggplot2
library(ggplot2)
#install.packages("extrafont")
#library(extrafont)
#font_import()
#cond_data <- data[match.fun("==")(data[,"Factor"], level),]

myplot <- function(population, parameter, rus_for_y,
                   data, color, signif, mintemp=1, max_y = 2000) {
    maxtemp <- length(signif)+mintemp-1
    bp <- boxplot(data[,parameter] ~ data$Factor, plot=F, range=100500)
    upper.whisker <- bp$stats[5,]
    upper.whisker <- upper.whisker[!is.na(upper.whisker)]
    place.for.asterisk <- upper.whisker + max_y * 0.05
    g <- ggplot(data, aes(y=data[,parameter], x=Factor)) +
        stat_boxplot(geom='errorbar', width=0.25, coef=100500) +
        geom_boxplot(outlier.size = 0, fill=color) +
        xlab("???????????, ?C") +
        ylab(rus_for_y) + ylim(1, max_y) +
        geom_text(data=data.frame(), aes(x=mintemp:maxtemp, 
                                         #y=max(data[,parameter], na.rm = T)*1.05,
                                         y=place.for.asterisk,
                                         size=12), label=signif, show.legend=F) +
        geom_text(aes(x=8.5, y=max_y * 0.95), 
                  family="serif", label=population) +
        theme_classic() +
        theme(panel.grid.major.y=element_line(color="darkgrey", size=0.4, linetype = 2),
              text = element_text(family="serif"),
              axis.text.x = element_text(size=7.5, colour = "black"), 
              axis.text.y = element_text(size=9, colour = "black"),
              axis.title = element_text(size=10)) 
    print(g)
    #ylim(0, 10) 
    #+ ylab("slkdjfdslkfjsldfj") #custom y label 
    
    return(g)
}

pB <- myplot("??????", "CAT", "?????????? ????????, ????/?? ?????", dataB, colorB, signifB)

blank <- ggplot() + theme_minimal()

#plist <- list(pB, pL, pF, pS, pI)
library(gridExtra)
#install.packages('gridExtra')

#And finally, save pictures
#png("CAT_Gme.png", width = 8.5, height = 21, units = "cm", res=300)
#grid.arrange(pL, pB, pF,  ncol = 1)
#dev.off()
