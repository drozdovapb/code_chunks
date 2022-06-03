## necessary packages
library(openxlsx)
library(ggplot2)
library(forcats)
#library(cowplot) ##maybe helps with svg? Nope. It doesn't 
library(png)
library(svglite)
#install.packages("png")

## read data
datadepth <- read.xlsx("./Table S1_Depth distribution_Table MD.xlsx", sheet = 1)
#datadepth$`Depth,.m`<- as.factor(datadepth$`Depth,.m`)


### first, depths as numbers 
##Species <-> levels in 
datadepth$Species <- factor(datadepth$Species, levels = c("O. flavus", "O. albinus"))
ggplot(datadepth, aes(y = `Approx..number.of.animals`, x = `Depth,.m`, fill=Species, col=Species)) + 
  theme_bw() + 
  scale_fill_manual(values = c("orange", "beige")) +
  scale_color_manual(values = c("black", "red4")) +
  geom_bar(stat = "identity") +
  #geom_point(cex = 0.3, alpha=.9, position = position_jitter(width = .1, h = 0)) + 
  xlab("Depth, m") +
  scale_x_reverse(breaks = c(1000, 750, 500, 300, 200, 150, 100, 50)) +
  coord_flip()   +
  ylab(label = "Number of animals") +
  facet_grid(Year ~ Species, drop = T, scales = "free", space = "free") + #, space = "free", scales = "free") +
  theme(strip.text.x = element_text(face = "italic", size = 12), 
    legend.position="none", panel.grid.minor.y=element_blank())

ggsave("Fig1_catch.png", width = 20, height = 10, units = "cm")
ggsave("Fig1_catch.svg", width = 20, height = 10, units = "cm")
## Then, the photos were added in Inkscape