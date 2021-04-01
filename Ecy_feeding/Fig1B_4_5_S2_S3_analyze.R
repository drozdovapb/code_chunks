Sys.setlocale("LC_TIME", "C")
library(openxlsx)
library(ggplot2)
library(ggbeeswarm)
library(reshape2)
library(ggpubr)
library(coin)

## survival
surv1 <- read.xlsx("data/survival_1st_feeding_experiment.xlsx", detectDates = T) 
surv1m <- melt(surv1, id.vars = "Date", value.name = "Number of animals", variable.name = "Feed")

psurv1 <- 
ggplot(surv1m, aes(x=Date, y=`Number of animals`, col = Feed)) + 
  geom_line() + geom_point() + expand_limits(y=0) +
  theme_bw(base_size = 16) + 
  scale_color_manual(values = c("orange", "chartreuse4")) + 
  scale_x_date(date_breaks = "month", date_labels = "%b %d")
#ggsave("figs/surv1.png", width=6, height=4)  

surv2 <- read.xlsx("data/survival_amplexuses_2nd_feeding_experiment.xlsx", detectDates = T) 
surv2m <- melt(surv2, id.vars = "Date", value.name = "Number of animals", variable.name = "Feed")

psurv2 <-
ggplot(surv2m[complete.cases(surv2m$`Number of animals`),], 
       aes(x=Date, y=`Number of animals`, col = Feed)) + 
  geom_line() + geom_point() + expand_limits(y=0) +
  theme_bw(base_size = 16) + 
  scale_color_manual(values = c("chartreuse4", "grey", "orange"))
#ggsave("surv2.png", width=6, height=4)  

ggarrange(psurv1 + theme(legend.position = "none"), 
          psurv2,
          nrow=1, ncol=2, widths = c(0.66, 1),
          labels = c("A", "B"))
ggsave("FigS2_survival.png", width = 8, height = 4)


ampl2 <- read.xlsx("data/survival_amplexuses_2nd_feeding_experiment.xlsx", detectDates = T, sheet = 2) 
ampl2m <- melt(ampl2, id.vars = "Date", value.name = "Number of amplexuses", variable.name = "Feed")
ggplot(ampl2m, 
       aes(x=Date, y=`Number of amplexuses`, col = Feed)) + 
  geom_line() + geom_point() + expand_limits(y=0) +
  theme_bw(base_size = 16) + 
  scale_color_manual(values = c("chartreuse4", "grey", "orange"))
#ggsave("ampl2.png", width=6, height=4)  

##carotenoid content
#####
carot <- read.xlsx("data/carotenoids_feed.xlsx")
carot$Feed <- sapply(carot$Sample, function(x) {strsplit(x, split="_")[[1]][1]})
ggplot(carot, aes(x=Feed, y=`Carotenoids,.ppm_corrected`, col=Feed)) +
  geom_boxplot() + geom_point() + expand_limits(y=0) +
  theme_bw(base_size = 14) + 
  ylab("Carotenoids, ppm") +
  scale_color_manual(values = c("chartreuse4", "grey", "orange"))
ggsave("Fig1B_carot_feed.svg", width=4, height=4)  


## Color
###### 

## First experiment
col1 <- read.xlsx("data/color_1st_feeding_experiment.xlsx")

## Pereon, first experiment
col1$Red <- strtoi(as.hexmode(substr(col1$Pereon, 1, 2)), base = 16)
col1$Green <- strtoi(as.hexmode(substr(col1$Pereon, 3, 4)), base = 16)
col1$Blue <- strtoi(as.hexmode(substr(col1$Pereon, 5, 6)), base = 16)
col1$RtoB <- col1$Red/col1$Blue
pcol1P <-
ggplot(col1, aes(Feed, Red/Blue, col=Feed)) + geom_boxplot() + 
  geom_beeswarm() + expand_limits(y=c(0,5)) + ggtitle("Pereon color") + 
  scale_color_manual(values = c("chartreuse4", "orange")) +
  ylab("R/B color index") +
  theme_bw(base_size = 14) + theme(legend.position = 'none')

## Antennae, first experiment
col1$RedA <- strtoi(as.hexmode(substr(col1$Antennae, 1, 2)), base = 16)
col1$GreenA <- strtoi(as.hexmode(substr(col1$Antennae, 3, 4)), base = 16)
col1$BlueA <- strtoi(as.hexmode(substr(col1$Antennae, 5, 6)), base = 16)
col1$RtoBA <- col1$RedA/col1$BlueA

pcol1A <-
  ggplot(col1, aes(Feed, RedA/BlueA, col=Feed)) + geom_boxplot() + 
  geom_beeswarm() + expand_limits(y=c(0,5)) + ggtitle("Antennae color") + 
  scale_color_manual(values = c("chartreuse4", "orange")) +
  ylab("R/B color index") +
  stat_compare_means(method = "wilcox.test", label = "p.signif", label.x = 1.5, label.y = 4.6) +
  theme_bw(base_size = 14) + theme(legend.position = 'none')

write.xlsx(col1, "data/color_1st_feeding_experiment_with_index.xlsx")

## Second experiment
col2 <- read.xlsx("data/color_2nd_feeding_experiment.xlsx")

## Pereon, second experiment
col2$Red <- strtoi(as.hexmode(substr(col2$Pereon, 1, 2)), base = 16)
col2$Green <- strtoi(as.hexmode(substr(col2$Pereon, 3, 4)), base = 16)
col2$Blue <- strtoi(as.hexmode(substr(col2$Pereon, 5, 6)), base = 16)
col2$RtoB <- col2$Red/col2$Blue
pcol2P <-
  ggplot(col2, aes(Feed, Red/Blue, col=Feed)) + geom_boxplot() + 
  geom_beeswarm() + expand_limits(y=c(0,5)) + ggtitle("Pereon color") + 
  scale_color_manual(values = c("chartreuse4", "grey", "orange")) +
  ylab("R/B color index") +
  theme_bw(base_size = 14) 

pairwise.wilcox.test(col2$Red/col2$Blue, col2$Feed, p.adjust.method = "holm")$p.value
## no significant p values


## Antennae, second experiment
col2$RedA <- strtoi(as.hexmode(substr(col2$Antennae, 1, 2)), base = 16)
col2$GreenA <- strtoi(as.hexmode(substr(col2$Antennae, 3, 4)), base = 16)
col2$BlueA <- strtoi(as.hexmode(substr(col2$Antennae, 5, 6)), base = 16)
col2$RtoBA <- col2$RedA/col2$BlueA

## calculate the adjusted p-values beforehand...
adj_pvals <- pairwise.wilcox.test(col2$RedA/col2$BlueA, col2$Feed, p.adjust.method = "holm")$p.value

adj_df <- compare_means(data=col2, formula = RtoBA ~ Feed, method = "wilcox.test", p.adjust.method = "holm")

pcol2A <-
  ggplot(col2, aes(Feed, RedA/BlueA, col=Feed)) + geom_boxplot() + 
  geom_beeswarm() + expand_limits(y=c(0,5)) + ggtitle("Antennae color") + 
  scale_color_manual(values = c("chartreuse4", "grey", "orange")) +
  ylab("R/B color index") +
  stat_pvalue_manual(adj_df, y.position = 4.5, step.increase = -0.1, label = "p.signif", hide.ns = TRUE) +
  theme_bw(base_size = 14) 



# ggarrange(pcol1P, pcol2P, nrow=1, widths = c(0.5, 1), labels = c("A", "B"))
# ggsave("color_pereon.png", width = 8, height = 3)
# ggarrange(pcol1A, pcol2A, nrow=1, widths = c(0.5, 1), labels = c("A", "B"))
# ggsave("color_antennae.png", width = 8, height = 3)


ggarrange(pcol1P, pcol2P, pcol1A, pcol2A, ncol=2, nrow=2, widths = c(0.5, 1, 0.5, 1), labels = c("A", "B", "C", "D"))
## Figure 4 color exp 
ggsave("Fig4_color_exp.png", width = 8, height = 6)
ggsave("Fig4_color_exp.svg", width = 8, height = 6)

## Carotenoid content
#####
#and 1st exp
carot1 <- read.xlsx("data/carotenoids_weight_1st_feeding_experiment.xlsx")
carot1$Feed <- ifelse(grepl("T", carot1$Sample), yes = "TC", no = "BFM")
pcarot1 <- 
ggplot(carot1, aes(x=Feed, y=`Carotenoids,.ppm_corrected`, col=Feed)) +
  geom_boxplot() + geom_jitter(width =.05) + expand_limits(y=c(0, 80)) +
  theme_bw(base_size = 14) + 
  scale_color_manual(values = c("chartreuse4", "orange")) +
  scale_y_continuous(n.breaks = 6) +
  ylab("Carotenoid content, ppm")
#ggsave("carot1.png", width=6, height=4)  

pweight1 <- 
ggplot(carot1, aes(x=Feed, y=Sample.weight*1000, col=Feed)) +
  geom_boxplot() + geom_jitter(width = .05) + expand_limits(y= c(0,.06)) +
  theme_bw(base_size = 14) + 
  scale_color_manual(values = c("chartreuse4", "orange")) +
  #geom_signif(comparisons = list(c("BFM", "TC")), map_signif_level=TRUE, test = "wilcox.test") +  NS
  ylab("Sample weight, mg")

#and 2nd exp
carot2 <- read.xlsx("data/carotenoids_weight_2nd_feeding_experiment.xlsx")
carot2$Feed <- sapply(carot2$Sample, function(x) {strsplit(x, split="_")[[1]][2]})
pcarot2 <- 
ggplot(carot2, aes(x=Feed, y=`Carotenoids,.ppm_corrected`, col=Feed)) +
  geom_boxplot() + geom_jitter(width = .05) + expand_limits(y= c(0,80)) +
  theme_bw(base_size = 14) + 
  scale_color_manual(values = c("chartreuse4", "grey", "orange")) +
  scale_y_continuous(n.breaks = 6) +
  ylab("Carotenoid content, ppm")
#ggsave("carot2.png", width=6, height=4)  

pweight2 <- 
ggplot(carot2, aes(x=Feed, y=Sample.weight*1000, col=Feed)) +
  geom_boxplot() + geom_jitter(width = .05) + expand_limits(y= c(0,60)) +
  theme_bw(base_size = 14) + 
  scale_color_manual(values = c("chartreuse4", "grey", "orange")) +
  #geom_signif(comparisons = list(c("BFM", "TC"), c("BFM", "DG"), c("DG", "TC")), 
  #            map_signif_level=TRUE, test = "wilcox.test") + ### 3 times NS
  ylab("Sample weight, mg")


ggarrange(pweight1 + theme(legend.position = 'none'), pweight2, widths = c(0.66, 1))
ggsave("FigS4_weight.png", width = 8, height = 4)

## metabolites
metab1 <- read.xlsx("data/lactate_glycogen_glucose_1st_feeding_exp.xlsx")
metab1m <- melt(metab1, id.vars = c("Ecy_labels", "Feed", "Date", "Sample"))
# ggplot(metab1m, aes(x=Feed, y=`value`, col = Feed)) + 
#   facet_wrap(~variable) +
#   geom_line() + geom_point() + expand_limits(y=0) +
#   theme_bw(base_size = 16) + 
#   scale_color_manual(values = c("orange", "chartreuse4"))

metab1m_glu <- metab1m[metab1m$variable == "Glucose,.umol.g-1", ]
pglu1 <- 
ggplot(metab1m_glu, aes(x=Feed, y=`value`, col = Feed)) + 
#  facet_wrap(~variable) +
  geom_boxplot() + geom_jitter(width = .1) + expand_limits(y=c(0, 3)) +
  theme_bw(base_size = 14) + 
  ylab("Glucose, umol/g") +
  scale_color_manual(values = c("chartreuse4", "orange"))
wilcox.test(metab1m_glu$value ~ metab1m_glu$Feed)

metab1m_gly <- metab1m[metab1m$variable == "Glycogen.glucose.corrected,.umol.g-1", ]
pgly1 <- 
ggplot(metab1m_gly, aes(x=Feed, y=`value`, col = Feed)) + 
  #  facet_wrap(~variable) +
  geom_boxplot() + geom_jitter(width = .1) + expand_limits(y=c(0,9)) +
  theme_bw(base_size = 14) + 
  ylab("Glycogen, umol/g") +
  scale_color_manual(values = c("chartreuse4", "orange")) +
  scale_y_continuous(n.breaks = 6) +
  stat_compare_means(method = "wilcox.test", label = "p.signif", label.x = 1.5, label.y = 8)
  
wilcox.test(metab1m_gly$value ~ metab1m_gly$Feed)

metab1m_lac <- metab1m[metab1m$variable == "Lactate,.umol.g-1", ]
plac1 <- 
ggplot(metab1m_lac, aes(x=Feed, y=`value`, col = Feed)) + 
  #  facet_wrap(~variable) +
  geom_boxplot() + geom_jitter(width = .1) + expand_limits(y=c(0, 1)) +
  theme_bw(base_size = 14) + 
  ylab("Lactate, umol/g") +
  scale_color_manual(values = c("orange", "chartreuse4"))
wilcox.test(metab1m_lac$value ~ metab1m_lac$Feed)

metab2 <- read.xlsx("data/lactate_glycogen_glucose_2nd_feeding_exp.xlsx")
metab2m <- melt(metab2, id.vars = c("Ecy_labels", "Feed", "Date", "Sample"))
# ggplot(metab1m, aes(x=Feed, y=`value`, col = Feed)) + 
#   facet_wrap(~variable) +
#   geom_line() + geom_point() + expand_limits(y=0) +
#   theme_bw(base_size = 16) + 
#   scale_color_manual(values = c("orange", "chartreuse4"))

metab2m_glu <- metab2m[metab2m$variable == "Glucose,.umol.g-1", ]
pglu2 <- 
ggplot(metab2m_glu, aes(x=Feed, y=`value`, col = Feed)) + 
  #  facet_wrap(~variable) +
  geom_boxplot() + geom_jitter(width = .1) + expand_limits(y=c(0, 3)) +
  theme_bw(base_size = 14) + 
  ylab("Glucose, umol/g") +
  scale_color_manual(values = c("chartreuse4", "grey", "orange"))
pairwise.wilcox.test(metab2m_glu$value, metab2m_glu$Feed)

adj_df <- compare_means(data=metab2m_glu, formula = value ~ Feed, method = "wilcox.test", p.adjust.method = "holm")
adj_df$p.signif <- c("ns", "*", "*")

pglu2 <-
  pglu2 + stat_pvalue_manual(adj_df, y.position = 2.9, step.increase = 0.1, label = "p.signif", hide.ns = TRUE)


metab2m_gly <- metab2m[metab2m$variable == "Glycogen.glucose.corrected,.umol.g-1", ]
pgly2 <-
ggplot(metab2m_gly, aes(x=Feed, y=`value`, col = Feed)) + 
  #  facet_wrap(~variable) +
  geom_boxplot() + geom_jitter(width = .1) + expand_limits(y=c(0, 9)) +
  scale_y_continuous(n.breaks = 6) +
  theme_bw(base_size = 14) + 
  ylab("Glycogen, umol/g") +
  scale_color_manual(values = c("chartreuse4", "grey", "orange"))

## just double checking that compare_means computes the same...
pairwise.wilcox.test(metab2m_gly$value, metab2m_gly$Feed)
adj_df <- compare_means(data=metab2m_gly, formula = value ~ Feed, method = "wilcox.test", p.adjust.method = "holm")
 
pgly2 <-
pgly2 + stat_pvalue_manual(adj_df, y.position = 8.5, step.increase = 0.1, label = "p.signif", hide.ns = TRUE)


metab2m_lac <- metab2m[metab2m$variable == "Lactate,.umol.g-1", ]
plac2 <- 
ggplot(metab2m_lac, aes(x=Feed, y=`value`, col = Feed)) + 
  #  facet_wrap(~variable) +
  geom_boxplot() + geom_jitter(width = .1) + expand_limits(y=c(0, 1)) +
  theme_bw(base_size = 14) + 
  ylab("Lactate, umol/g") +
  scale_color_manual(values = c("chartreuse4", "grey", "orange"))


ggarrange(pcarot1 + theme(legend.position = "none") + ylab("Carotenoids, ppm") + xlab(""), 
          pcarot2 + ylab("Carotenoids, ppm") + xlab(""),
          pgly1 + theme(legend.position = "none") + xlab(""), pgly2 + xlab(""), 
          pglu1 + theme(legend.position = "none"), pglu2,
          nrow=3, ncol=2, widths = c(0.66, 1.1),
          labels = c("A", "B", "C", "D", "E", "F"))
ggsave("Fig5_carotenoids_glucose_glycogen.png", width = 8, height = 7.5)
ggsave("Fig5_carotenoids_glucose_glycogen.svg", width = 8, height = 7.5)

# ggarrange(plac1 + theme(legend.position = "none"), plac2, nrow=1, widths = c(0.66, 1.1))
# ggsave("lactate.png", width = 8, height = 3)

