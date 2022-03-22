options(stringsAsFactors = F)

library(ggplot2)
library(openxlsx)
library(reshape2)

data <- read.xlsx("Table S2 all_markers_Ofla_Oalb.xlsx", sheet = 1)

levels(data$Year) <- c("2015, field sampling", "2015, laboratory acclimation", "2016, field sampling")
data$Year <- factor(data$Year, c("2015, field sampling", "2016, field sampling", "2015, laboratory acclimation"))

data$Depth <- as.factor(data$`Depth,.m`)
###levels(data$Depth) <- rev(levels(data$Depth))

makeplot <- function(thesedata) {
  p <- ggplot(thesedata, aes(y = Value, x = Depth, fill=Species, col=Species)) + 
    theme_bw() + 
    scale_fill_manual(values = c("lightblue", "orange")) +
    scale_color_manual(values = c("red4", "black")) +
    #expand_limits(x=c(1100, 0)) +
    facet_grid(Year ~ Species) +
    theme(strip.text.x = element_text(face = "italic")) + 
    #theme(strip.text.y = element_text(angle = 270)) +  #it's the default option
    theme(text = element_text(size = 14)) +
    stat_summary_bin(fun = "median", geom = "bar", alpha=.8, col = "transparent") + 
    geom_point(cex = 0.3, alpha=.9, position = position_jitter(width = .1, h = 0)) + 
    coord_flip() + 
    ylab(label = thesedata$Units_en) + 
    ggtitle(thesedata$Parameter) + 
    theme(plot.title = element_text(hjust = 0.5)) + #center title 
    theme(legend.position="none") #remove legend just in case
  #    print(p)
#  ggsave(plot = p, device = "pdf", width = 20, height = 14.5, 
#         units = "cm", filename = paste0(thesedata$Parameter, ".pdf"))
  ggsave(plot = p, device = "png", width = 20, height = 14.5, 
         units = "cm", filename = paste0(thesedata$Parameter, ".png"))
}

for (i in 1:16) {
  data <- read.xlsx("Table S2 all_markers_Ofla_Oalb.xlsx", sheet = i)
  data$Depth <- as.factor(data$`Depth,.m`)
  a <- data[data$Species == "O. albinus" & data$Year %in% c("2015", "2016"), ]
  f <- data[data$Species == "O. flavus" & data$Year %in% c("2015", "2016"), ]
  print(unique(data$Parameter))
  print("albinus")
  print("2015")
  print(cor(a[a$Year == "2015", ]$`Depth,.m`, a[a$Year == "2015", ]$Value, method = "pearson", use = "complete.obs"))
  print("2016")
  print(cor(a[a$Year == "2016", ]$`Depth,.m`, a[a$Year == "2016", ]$Value, method = "pearson", use = "complete.obs"))
  print("flavus")
  print("2015")
  print(cor(f[f$Year == "2015", ]$`Depth,.m`, f[f$Year == "2015", ]$Value, method = "pearson", use = "complete.obs"))
  print("2016")
  print(cor(f[f$Year == "2016", ]$`Depth,.m`, f[f$Year == "2016", ]$Value, method = "pearson", use = "complete.obs"))
  
  data$Year <- factor(data$Year)
  levels(data$Year) <- c("2015, field", "2015, acclimation", 
                         "2016, field", "2016, acclimation")
  data$Parameter <- factor(data$Parameter)
  data$`Depth,.m` <- factor(data$`Depth,.m`)
  
  for (param in levels(data$Parameter)) {
    makeplot(thesedata = data[data$Parameter == param,])
  }
}
  
 
