## necessary packages
library(openxlsx)
library(ggplot2)
library(forcats)
#library(cowplot) ##maybe helps with svg? Nope. It doesn't 
library(png)
library(svglite)
#install.packages("png")

#remotes::install_github("coolbutuseless/ggpattern")
#library(ggpattern)

## read data
datadepth <- read.xlsx("./Table S1_Depth distribution_Table MD.xlsx", sheet = 1)
#datadepth$`Depth,.m`<- as.factor(datadepth$`Depth,.m`)


### first, depths as numbers 
##Species <-> levels in 
datadepth$Species <- factor(datadepth$Species, levels = c("O. flavus", "O. albinus"))

#datadepth[datadepth$Year == "2015", "Approx..number.of.animals"] %>% "*"(-1) %>%


# datadepth$numberwithyears <- datadepth$Approx..number.of.animals
# datadepth[datadepth$Year == "2015", "numberwithyears"] <- 
#   datadepth[datadepth$Year == "2015", "Approx..number.of.animals"] * (-1)


# ggplot(datadepth, aes(y = numberwithyears, x = `Depth,.m`, fill=Species, col=Species)) + 
#   theme_bw() + 
#   scale_fill_manual(values = c("orange", "beige")) +
#   scale_color_manual(values = c("black", "red4")) +
#   geom_bar(stat = "identity") +
#   #geom_point(cex = 0.3, alpha=.9, position = position_jitter(width = .1, h = 0)) + 
#   xlab("Depth, m") +
#   scale_x_reverse(breaks = c(1000, 750, 500, 300, 200, 150, 100, 50)) +
#   coord_flip()   +
#   ylab(label = "Number of animals") +
#   facet_grid( ~ Species, drop = T, scales = "free", space = "free") + #, space = "free", scales = "free") +
#   theme(strip.text.x = element_text(face = "italic", size = 12), 
#     legend.position="none", panel.grid.minor.y=element_blank())
# 
# ggsave("Fig1_catch_pyramids_species.png", width = 20, height = 10, units = "cm")
#ggsave("Fig1_catch.svg", width = 20, height = 10, units = "cm")
## Then, the photos were added in Inkscape

datadepth$numberwithspecies <- datadepth$Approx..number.of.animals

datadepth[datadepth$Species == "O. flavus", "numberwithspecies"] <- 
  datadepth[datadepth$Species == "O. flavus", "Approx..number.of.animals"] * (-1)

ggplot(datadepth, aes(y = numberwithspecies, x = `Depth,.m`, fill=Species, col=Species)) + 
  theme_bw(base_size = 12) + 
  scale_fill_manual(values = c("orange", "beige")) +
  scale_color_manual(values = c("black", "red4")) +
  geom_bar(stat = "identity", aes(col = Species)) +
  #geom_point(cex = 0.3, alpha=.9, position = position_jitter(width = .1, h = 0)) + 
  xlab("Depth, m") +
  scale_x_reverse(breaks = c(1000, 750, 500, 300, 200, 150, 100, 50)) +
  coord_flip()   +
  ylab(label = "Number of animals") +
  scale_y_continuous(breaks = c(-750, -500, -250, 0, 250, 500),
                     labels = c("750", "500", "250", "0", "250", "500")) + 
  facet_grid(Year  ~ ., drop = T, scales = "free", space = "free") + #, space = "free", scales = "free") +
  theme(strip.text.x = element_text(face = "italic", size = 12),
        strip.text.y = element_text(size = 12),
         panel.grid.minor.y=element_blank(), legend.position="none")
#        legend.position = c(.15,.15),
#        legend.text = element_text(face = "italic", size = 12),
#        legend.background = element_rect(fill = "lightgrey"))

#ggsave("Fig1_catch_pyramids_years.png", width = 20, height = 10, units = "cm")
ggsave("Fig1_catch_pyramids_years.svg", width = 20, height = 10, units = "cm")
