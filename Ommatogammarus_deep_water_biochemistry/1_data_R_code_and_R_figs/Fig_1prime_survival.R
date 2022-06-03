library(openxlsx)
library(ggplot2)
library(dplyr)
library(reshape2)
library(data.table)
library(ggpattern)

survivaldf <- read.xlsx("../4_suppl/Table S1 Laboratory acclimation.xlsx", sheet = 2,
                        fillMergedCells = TRUE, startRow = 2)

survm <- survivaldf %>% data.table() %>% 
  filter(X3 %in% c("alive", "dead")) %>%
  melt(id = c("X1", "X2", "X3"), variable.name = "Depth", value.name = "n animals") %>%
  filter(Depth != "All")

names(survm)[1:3] <- c("Species", "Year", "Status")
survm$Depth <- as.numeric(gsub(".m", "", survm$Depth))

survm$Species <- factor(survm$Species, levels = c("O. flavus", "O. albinus"))

survm$Combination <- factor(paste(survm$Species, survm$Status), levels = c("O. flavus dead", "O. flavus alive",
                                                                           "O. albinus dead", "O. albinus alive"))

ggplot(survm, aes(x = Depth, y = `n animals`, label = `n animals`)) + 
  facet_grid (Year ~ Species) + 
  geom_bar(stat = "identity", position = "fill", aes(fill = Combination, col = Combination)) + 
  geom_text(position = position_fill(vjust = .5), size = 2.8) + #col = Species 
  scale_y_reverse() + 
  coord_flip() + 
  expand_limits(y = 1.1) + 
  scale_y_continuous(breaks = c(0, .25, .5, .75, 1), labels = c(0, 25, 50, 75, 100)) +
  scale_alpha_manual(values = c(1, .1)) + 
  scale_fill_manual(values = c("grey", "orange", "grey", "beige")) +
  scale_color_manual(values = c("black", "black", "red4", "red4")) +
  scale_x_reverse(breaks = c(1000, 750, 500, 300, 200, 150, 100, 50)) +
  theme_bw(base_size = 12) + ylab("% animals") + 
  theme(strip.text.x = element_text(face = "italic", size = 12)) 

ggsave("Fig 1 prime survival.svg", width = 8, height = 5)
ggsave("Fig 1 prime survival.png", width = 8, height = 5)
