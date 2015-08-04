dir()

#tested for Bio-Rad CFX Manager output
#assumes that data were saved as csv
data <- read.csv("qPCR data", skip = 1, head=F)

#extract only the data we need
data<-data.frame(as.character(data$V6), as.character(data$V4), data$V8)
#restore proper names
names(data) <- c("Sample", "Target", "Cq")

#install reshape2 if not installed, and load it
if (!('reshape2' %in% installed.packages()[, 'Package'])) {
    install.packages('reshape2')}
library(reshape2)

#get median values for each biological replicate
data3 <- dcast(data = data, formula = Sample ~ Target, fun.aggregate = median)

#write the summarized data if you need
write.table(data3, "summarized_data.csv")

#now we need to apply experimental conditions
#construct a meaningful vector of values, eg
#data3$condition <- sapply(data3$sample, substr, start = 1, stop = length(data3$sample)-1)
#data3$condition <- factor(x = c(rep("mut", 6), rep("wt", 6)), levels = c("mut", "flip"))

#compute dCq
data3$dYFG1 <- data3$reference - data3$YFG1
#and so on for all genes you need

#produce a plot (uncomment the next line and dev.off() to save it as svg)
#svg("filename.svg", width = 4, height = 4)
boxplot(data3$dYFG1 ~ data3$condition, ylab="ΔCq", 
        boxlty=1, whisklty=1, staplelty=1, main='YFG1',
        las=1, outline = F)
stripchart(data3$dYFG1 ~ data3$condition, vertical=TRUE, add=TRUE, pch=19,
           jitter=0.05, method='jitter', cex=.8)
dev.off()

#test difference with Wilcoxon test 

#install coin if not installed earlier, and load it
if (!('coin' %in% installed.packages()[, 'Package'])) install.packages('coin')
library(coin)

#extract the data you need
#eg
#mydata <- data3[,c("5,6"")]

wilcox_test(data = mydata, YFP1 ~ condition)