library(openxlsx)

qPCRdat <- read.xlsx("TableSN_Quantification Cq Results.xlsx")

## QC: no template controls
NTC <- qPCRdat[qPCRdat$Content == "NTC", ]
NTC$Cq
## only rpl2 above 30 (28.15)

## QC: no RT controls
NRT <- qPCRdat[qPCRdat$Content == "NRT", ]
NRT$Cq
## all over 25

## QC: standards
Std <- qPCRdat[qPCRdat$Content == "Std", ]
Std$Cq
## ## TODO primer efficiency here!

library(ggplot2)
ggplot(Std, aes(`Cq`, `Log.Starting.Quantity`)) + geom_point() + 
  geom_smooth(method = "lm")

lmcoef <- summary(lm(Cq~Log.Starting.Quantity, data = Std))$coef[2,1]
efficiency <- (10^(-1/lmcoef)-1)*100

qPCRdat <- qPCRdat[qPCRdat$Content == "Unkn", ]
## average Cq values
library(dplyr)
qPCRmeans <- qPCRdat %>% group_by(Target, Sample) %>% summarize(meanCq = mean(Cq))

library(tidyr)
qPCRmeanss <- spread(data = qPCRmeans, key = Target, value = meanCq)
qPCRmeanss$refgenes <- sqrt(qPCRmeanss$rap2l * qPCRmeanss$RPL32)
qPCRmeanss <- qPCRmeanss[, c("Sample", "abcb1", "mdr49", "mdr50", "mdr65", "refgenes")]

qPCRmeans <- gather(qPCRmeanss, Target, Cq, refgenes, abcb1:mdr65)


qPCRmeansn <-  spread(data = qPCRmeans, key = Target, value = Cq)
qPCRmeansn$abcb1_RE <- 2**(qPCRmeansn$refgenes - qPCRmeansn$abcb1)
qPCRmeansn$mdr49_RE <- 2**(qPCRmeansn$refgenes - qPCRmeansn$mdr49)
qPCRmeansn$mdr50_RE <- 2**(qPCRmeansn$refgenes - qPCRmeansn$mdr50)
qPCRmeansn$mdr65_RE <- 2**(qPCRmeansn$refgenes - qPCRmeansn$mdr65)

qPCRg <- gather(qPCRmeansn, key = "Target", value = "Relative expression", 
       "abcb1_RE", "mdr49_RE", "mdr50_RE", "mdr65_RE", -Sample)

library(ggplot2)
library(scales) # to access break formatting functions
#install.packages("ggbreak")
library(ggbreak) 

ggplot(qPCRg, aes(x = Target, fill = Sample, y = `Relative expression`)) + 
  geom_bar(stat = "identity", position = "dodge", width = 0.75) + 
  scale_y_break(c(0.001, 0.75), scales = 0.5) + 
  scale_fill_manual(values = c("grey", "green4", "red4"), labels = c("control", "EvAbcb1", "Abcb1-mScarlet-I")) + 
  theme_bw(base_size = 16) + theme(legend.position = 'bottom')
#  geom_point() + 
#  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
#                labels = trans_format("log10", math_format(10^.x)))

ggsave("qPCR.svg", width = 13, height = 10, units = "cm")
ggsave("qPCR.png", width = 15, height = 10, units = "cm")

