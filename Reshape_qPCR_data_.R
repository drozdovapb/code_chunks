dir()

#let it be ST first
data <- read.csv("qPCR data")

#install.packages('reshape2')
library(reshape2)

data2 <- aggregate(Cq ~ Sample + Target, data, FUN = median)
data3 <- dcast(data2, formula =  Sample ~ Target, value.var = "Cq")

combo2$dTargetGene <- combo2$ReferenceGene - combo2$TargetGene

combo2