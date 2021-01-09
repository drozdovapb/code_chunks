library(ggplot2)
library(openxlsx)
library(ggbeeswarm)
library(ggpubr)
Sys.setlocale("LC_TIME", "C")
## if something throws an error uncomment and run:
# install.packages("packagename")

color_changes <- read.xlsx("data/Color_and_survival.xlsx", detectDates = T)

## Calculate color index (it's actually R/B)
color_changes$Red <- strtoi(as.hexmode(substr(color_changes$Pereon, 1, 2)), base = 16)
color_changes$Green <- strtoi(as.hexmode(substr(color_changes$Pereon, 3, 4)), base = 16)
color_changes$Blue <- strtoi(as.hexmode(substr(color_changes$Pereon, 5, 6)), base = 16)
color_changes$RtoB <- color_changes$Red/color_changes$Blue

### Some checks
## Before
## aab08c
strtoi(as.hexmode("aa"), base = 16)/strtoi(as.hexmode("8c"), base = 16)
##1.21
## Antennae af975c
strtoi(as.hexmode("af"), base = 16)/strtoi(as.hexmode("5c"), base = 16)
##1.90

## After
## Pereon: 385878 or 4c657b
strtoi(as.hexmode("38"), base = 16)/strtoi(as.hexmode("78"), base = 16)
strtoi(as.hexmode("4c"), base = 16)/strtoi(as.hexmode("7b"), base = 16)
## 0.61
## 6f716a
strtoi(as.hexmode("6f"), base = 16)/strtoi(as.hexmode("6a"), base = 16)
## 1.05


## The same (color index) for antennae
color_changes$ARed <- strtoi(as.hexmode(substr(color_changes$Antennae, 1, 2)), base = 16)
color_changes$AGreen <- strtoi(as.hexmode(substr(color_changes$Antennae, 3, 4)), base = 16)
color_changes$ABlue <- strtoi(as.hexmode(substr(color_changes$Antennae, 5, 6)), base = 16)
color_changes$ARtoB <- color_changes$ARed/color_changes$ABlue

## Final plotting for Fig. 1
pP <- 
ggplot(data = color_changes[color_changes$Date > "2020-07-01", ], aes(x=Date, y=RtoB)) + #, col = Color,)) + 
  #geom_boxplot() + geom_jitter(position = position_jitterdodge()) + 
  geom_boxplot(aes(group=Date)) + geom_beeswarm() + expand_limits(y=c(0,5))+
  ylab("R/B color index") +
  theme_bw(base_size = 14) + scale_color_manual(values = c("#0072B2", "#D55E00")) + #"#00BFC4", "#7CAE00"
  geom_smooth(method = "lm", col = "darkred") + ggtitle("Pereon color")

pA <- 
ggplot(data = color_changes[color_changes$Date > "2020-07-01", ], aes(x=Date, y=ARtoB)) + #, col = Color,)) + 
  #geom_boxplot() + geom_jitter(position = position_jitterdodge()) + 
  geom_boxplot(aes(group=Date)) + geom_beeswarm() + expand_limits(y=c(0,5))+
  ylab("R/B color index") +
  theme_bw(base_size = 14) + scale_color_manual(values = c("#0072B2", "#D55E00")) + #"#00BFC4", "#7CAE00"
  geom_smooth(method = "lm", col = "darkred") + ggtitle("Antennae color")

ggarrange(pP, pA)
ggsave("Fig2_color_changes.png", width = 8, height = 3)
ggsave("Fig2_color_changes.svg", width = 8, height = 3)

## And write out an updated table
write.xlsx(color_changes, "Color_changes_with_index_values.xlsx")

## Photos were added with Inkscape
