library(openxlsx)
library(ggplot2)
library(ggbeeswarm)
library(ggpubr)
library(coin) ## for the pairwise wilcox test

d <- read.xlsx("data/Gradient_color_and_carotenoids.xlsx", sheet=1) 
##d <- d[d$`Keep.(not.smeary)` == "T", ]
## reorder levels
d$Color <- factor(d$Color, levels = c("b", "db", "g", "o"))

## Pereon color
d$Red <- strtoi(as.hexmode(substr(d$Pereon, 1, 2)), base = 16)
d$Green <- strtoi(as.hexmode(substr(d$Pereon, 3, 4)), base = 16)
d$Blue <- strtoi(as.hexmode(substr(d$Pereon, 5, 6)), base = 16)
d$RtoB <- d$Red/d$Blue

## Antennae color
d$ARed <- strtoi(as.hexmode(substr(d$Anntennae, 1, 2)), base = 16)
d$AGreen <- strtoi(as.hexmode(substr(d$Anntennae, 3, 4)), base = 16)
d$ABlue <- strtoi(as.hexmode(substr(d$Anntennae, 5, 6)), base = 16)
d$ARtoB <- d$ARed/d$ABlue

## Pereon color in different groups
pPereonColorBoxplots <- 
ggplot(d, aes(Color, Red/Blue, col=Color)) + geom_boxplot() + geom_beeswarm() + 
  scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
  ggtitle("Pereon color") + theme_bw(base_size = 14) + #+ ggtitle("Цвет переона") +
  #ylab("Цветовой индекс R/B") + xlab("Цветовая морфа") +
  ylab("R/B color index") + xlab("Color morph") + #xlab("") +
  expand_limits(y=0) + theme(plot.title=element_text(hjust = 0.5)) +
  theme(legend.position = 'none')
pPereonColorBoxplots
# ggsave("4_morphs_colors.png", width = 6, height = 4)
# ggsave("4_morphs_colors.svg", width = 6, height = 4)

## Carotenoid content in different groups
pCarotenoidBoxplots <- 
ggplot(d, aes(x=Color, y = `Carotenoids,.ppm`)) + 
  geom_boxplot(aes(col=Color), outlier.colour = NA) +
  geom_jitter(aes(col=Color), width=0.1) +
  scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
  theme_bw(base_size = 14) + 
  ggtitle("Carotenoids") + #ggtitle("Цвет переона") +
  #ylab("Содержание каротиноидов, ppm") + xlab("Цветовая морфа") +
  ylab("Carotenoid content, ppm") + xlab("Color morph") +  
  expand_limits(y=0) + theme(plot.title=element_text(hjust = 0.5))
pCarotenoidBoxplots
# ggsave("4_morphs_carotenoids.png", width = 6, height = 4)
# ggsave("4_morphs_carotenoids.svg", width = 6, height = 4)

## Antennae color
pAntennaeColorBoxplots <- 
  ggplot(d, aes(Color, ARed/ABlue, col=Color)) + geom_boxplot() + geom_beeswarm() + 
  scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
  ggtitle("Antennae color") + theme_bw(base_size = 14) + #+ ggtitle("Цвет переона") +
  #ylab("Цветовой индекс R/B") + xlab("Цветовая морфа") +
  ylab("R/B color index") + xlab("Color morph") + # xlab("") +
  expand_limits(y=0) + theme(plot.title=element_text(hjust = 0.5)) +
  theme(legend.position = 'none')
pAntennaeColorBoxplots

ggarrange(pPereonColorBoxplots, pAntennaeColorBoxplots, pCarotenoidBoxplots,
          nrow = 1, labels = c("A", "B", "C"), widths = c(1, 1, 1.4))
ggsave("FigS1_color_morphs.png", width = 8, height = 4)

# ggplot(d, aes(x=Color_morph, y = `Carotenoids,.ppm`)) + 
#   geom_boxplot(aes(col=Color_morph), outlier.colour = NA) +
#   geom_jitter(aes(col=Color), width=0.1) +
#   scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
#   ggtitle("Carotenoids") +
#   expand_limits(y=0) +
#   theme_bw()

## We also have proteins
# ggplot(d, aes(x=Color, y = `15.kDa,.%`)) + 
#   geom_boxplot(aes(col=Color), outlier.colour = NA) +
#   geom_jitter(aes(col=Color), width=0.1) +
#   scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
#   ggtitle("15 kDa") +
#   expand_limits(y=0) +
#   theme_bw()
# 
# ggplot(d, aes(x=Color, y = `25.kDa,.%`)) + 
#   geom_boxplot(aes(col=Color), outlier.colour = NA) +
#   geom_jitter(aes(col=Color), width=0.1) +
#   scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
#   ggtitle("25 kDa") +
#   expand_limits(y=0) +
#   theme_bw()

## The main figure
## Carotenoids vs Pereon color
## only in blue animas
CarotP <- 
ggplot(d[d$Color != "o",], aes(x=Red/Blue, y = `Carotenoids,.ppm`), col="#009966") + geom_point() + 
  expand_limits(y=0) + 
  ggtitle("Carotenoids") + xlab("R/B color index") + ylab("Carotenoid content, ppm") +
  theme_bw() + geom_smooth(method = "lm")

## 25 kDa protein vs pereon color
## only in blue animas
CarotS <- 
ggplot(d[d$Color != "o",], aes(x=Red/Blue, y = `25.kDa,.%`), col="#009966") + geom_point() + 
  expand_limits(y=c(0, 25)) + 
  ggtitle("25 kDa protein") + xlab("R/B color index") + ylab("Relative protein amount, %") +
  theme_bw() + geom_smooth(method = "lm")

## 15 kDa protein vs pereon color
## only in blue animas
CarotL <- 
ggplot(d[d$Color != "o",], aes(x=Red/Blue, y = `15.kDa,.%`), col="#009966") + geom_point() + 
  expand_limits(y=c(0, 25)) + 
  ggtitle("15 kDa protein") + xlab("R/B color index") + ylab("Relative protein amount, %") +
  theme_bw() + geom_smooth(method = "lm")

summary(lm(RtoB ~ `Carotenoids,.ppm`, data = d[d$Color !="o", ]))
summary(glm(RtoB ~ `Carotenoids,.ppm`, data = d[d$Color !="o", ]))
summary(glm(`15.kDa,.%` ~ RtoB, data = d[d$Color !="o", ]))
summary(glm(`25.kDa,.%` ~ RtoB, data = d[d$Color !="o", ]))

summary(glm(RtoB ~ `Carotenoids,.ppm` + `15.kDa,.%` + `25.kDa,.%`, data = d[d$Color !="o", ]))

ggarrange(CarotP, CarotL, CarotS, nrow=T, labels = c("A", "B", "C"))
ggsave("Fig3_gradient.png")
ggsave("Fig3_gradient.svg")

## Antennae!
A1 <- 
ggplot(d[d$Color != "o",], aes(x=ARed/ABlue, y = `Carotenoids,.ppm`), col="#009966") + geom_point() + 
  #scale_color_manual(values = c("#00BFC4", "#009966", "#7CAE00", "#D55E00")) + 
  expand_limits(y=0) + ggtitle("Caroteinods ~ Antennae color") + 
  theme_bw() + geom_smooth(method = "lm")

A2 <- 
ggplot(d[d$Color != "o",], aes(x=ARed/ABlue, y = `15.kDa,.%`), col="#009966") + geom_point() + 
  expand_limits(y=0) + ggtitle("15 kDa protein ~ Antennae color") + 
  theme_bw() + geom_smooth(method = "lm")

A3 <- 
ggplot(d[d$Color != "o",], aes(x=ARed/ABlue, y = `25.kDa,.%`), col="#009966") + geom_point() + 
  expand_limits(y=0) + ggtitle("25 kDa protein ~ Antennae color") + 
  theme_bw() + geom_smooth(method = "lm")
ggarrange(A1, A2, A3, nrow=T, labels = c("A", "B", "C"))

ggsave("FigS1_gradient_antennae.png")

summary(lm(data = d[d$Color != "o",], formula = `Carotenoids,.ppm` ~ ARtoB))
summary(lm(data = d[d$Color != "o",], formula = `15.kDa,.%` ~ ARtoB))
summary(lm(data = d[d$Color != "o",], formula = `25.kDa,.%` ~ ARtoB))

# ggplot(d[d$Color != "o",], aes(x=Red/Blue, y = `Carotenoids,.ppm`)) + #,col=Color)) 
#        geom_point() + 
#   expand_limits(y=0) + ggtitle("Pereon color, blue only") + 
#   theme_bw() + geom_smooth(method = "lm")
# 
# summary(lm(data = d[d$Color != "o",], formula = `Carotenoids,.ppm` ~ RtoB))
# #summary(lm(data = d[d$Color != "o",], formula = scale(`Carotenoids,.ppm`) ~ scale(RtoB)))

pairwise.wilcox.test(d$RtoB, d$Color)

db <- d[d$Color != "o",]
cor(db$`Carotenoids,.ppm`, db$RtoB, method = "spearman")

summary(lm(data = , formula = `Carotenoids,.ppm` ~ RtoB))


ggplot(d[d$Color != "o.",], aes(x=ARtoB, y = `Carotenoids,.ppm`)) + #,col=Color)) 
  geom_point() + 
  expand_limits(y=0) + ggtitle("Antennae color, blue only") + 
  theme_bw() + geom_smooth(method = "lm")

summary(lm(data = d[d$Color != "o",], formula = `Carotenoids,.ppm` ~ ARtoB))
