library(openxlsx)
library(ggplot2)
library(dplyr)

survivaldf <- read.xlsx("../4_suppl/Table S1 Laboratory acclimation.xlsx", sheet = 2,
                        fillMergedCells = TRUE, startRow = 2)

survm <- survivaldf %>% data.table() %>% 
  filter(X3 %in% c("alive ", "dead")) %>%
  melt(id = c("X1", "X2", "X3"), variable.name = "Depth", value.name = "n animals") %>%
  filter(Depth != "All")

names(survm)[1:3] <- c("Species", "Year", "Status")
survm$Depth <- as.numeric(gsub(".m", "", survm$Depth))

ggplot(survm, aes(x = Depth, y = `n animals`, fill = Status, label = `n animals`)) + 
  facet_grid (Year ~ Species) + 
  geom_bar(stat = "identity", position = "fill") + 
  geom_text(position = position_fill(vjust = .5)) + 
  scale_y_reverse() + 
  coord_flip() + 
  scale_y_continuous(labels = c(0, 25, 50, 75, 100)) +
  scale_x_reverse(breaks = c(1000, 750, 500, 300, 200, 150, 100, 50)) +
  theme_bw(base_size = 14) + ylab("% animals")

ggsave("survival.png")
