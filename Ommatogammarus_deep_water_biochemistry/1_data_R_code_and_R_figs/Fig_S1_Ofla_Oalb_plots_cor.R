options(stringsAsFactors = F)

library(ggplot2)
library(openxlsx)
library(reshape2)

data <- read.xlsx("../4_suppl/Table S2 all_markers_Ofla_Oalb.xlsx", sheet = 1)

levels(data$Year) <- c("2015, field sampling", "2015, laboratory acclimation", "2016, field sampling")
data$Year <- factor(data$Year, c("2015, field sampling", "2016, field sampling", "2015, laboratory acclimation"))

data$Depth <- as.factor(data$`Depth,.m`)
data$Species <- factor(data$Species, levels = c("O. flavus", "O. albinus"))

###levels(data$Depth) <- rev(levels(data$Depth))

makeplot <- function(thesedata) {
  p <- ggplot(thesedata, aes(y = Value, x = Depth, fill=Species, col=Species)) + 
    theme_bw() + 
    scale_fill_manual(values = c("orange", "antiquewhite2")) +
    scale_color_manual(values = c("black", "red4")) +
    scale_x_discrete(limits = rev) + 
    #expand_limits(x=c(1100, 0)) +
    facet_grid(Year ~ Species) +
    theme(strip.text.x = element_text(face = "italic")) + 
    #theme(strip.text.y = element_text(angle = 270)) +  #it's the default option
    theme(text = element_text(size = 14)) +
    stat_summary_bin(fun = "median", geom = "bar", alpha=.8, col = "transparent") + 
    geom_point(cex = 0.3, alpha=.9, position = position_jitter(width = .1, h = 0)) + 
    coord_flip() + 
    ylab(label = thesedata$Units) + 
    xlab("Depth, m") + 
    ggtitle(thesedata$Parameter) + 
    theme(plot.title = element_text(hjust = 0.5, size =24)) + #center title + make larger
    theme(legend.position="none") #remove legend just in case
  return(p)
#  ggsave(plot = p, device = "png", width = 20, height = 14.5, 
#         units = "cm", filename = paste0(thesedata$Parameter, ".png"))
}

for (i in 1:16) {
  data <- read.xlsx("../4_suppl/Table S2 all_markers_Ofla_Oalb.xlsx", sheet = i)
  
  data <- data[complete.cases(data$Value), ]
  
  data$Depth <- as.factor(data$`Depth,.m`)
  data$Species <- factor(data$Species, levels = c("O. flavus", "O. albinus"))

  a <- data[data$Species == "O. albinus" & data$Year %in% c("2015", "2016"), ]
  f <- data[data$Species == "O. flavus" & data$Year %in% c("2015", "2016"), ]
  print(unique(data$Parameter))
  alb2015 <- cor(a[a$Year == "2015", ]$`Depth,.m`, a[a$Year == "2015", ]$Value, method = "pearson", use = "complete.obs")
  alb2016 <- cor(a[a$Year == "2016", ]$`Depth,.m`, a[a$Year == "2016", ]$Value, method = "pearson", use = "complete.obs")
  fla2015 <- cor(f[f$Year == "2015", ]$`Depth,.m`, f[f$Year == "2015", ]$Value, method = "pearson", use = "complete.obs")
  fla2016 <- cor(f[f$Year == "2016", ]$`Depth,.m`, f[f$Year == "2016", ]$Value, method = "pearson", use = "complete.obs")
  
  alb2015 <- round(alb2015, 2); print(alb2015)
  alb2016 <- round(alb2016, 2); print(alb2016)
  fla2015 <- round(fla2015, 2); print(fla2015)
  fla2016 <- round(fla2016, 2); print(fla2016)
  
  annot.df <- data.frame(Year = rep(c("2015, field", "2016, field"), 2),
                         Species = c(rep("O. albinus", 2), rep("O. flavus", 2)),
                         cor.value = c(alb2015, alb2016, fla2015, fla2016),
                         Depth = rep("50", 4),
                         Value = rep(0, 4))
  annot.df$cor.string <- paste0("r=", annot.df$cor.value)
  annot.df$Species <- factor(annot.df$Species, levels = c("O. flavus", "O. albinus"))
  annot.df$Year <- factor(annot.df$Year)

  data$Year <- factor(data$Year)
  levels(data$Year) <- c("2015, field", "2015, acclimation", 
                         "2016, field", "2016, acclimation")

  
  data$Parameter <- factor(data$Parameter)
  data$`Depth,.m` <- factor(data$`Depth,.m`)
  
  for (param in levels(data$Parameter)) {
    thesedata <- data[data$Parameter == param,]
    p <- makeplot(thesedata)
    
    annot.df$Value <- rep(max(p$data$Value, na.rm = TRUE)*0.94, 4)
    
    plab <- p + geom_text(data = annot.df, inherit.aes = FALSE,
                          aes(label = cor.string, x = Depth, y = Value), size = 5)
    
    
    
    ggsave(plot = plab, device = "png", width = 20, height = 17, 
             units = "cm", filename = paste0(param, ".png"))
    
  }
}
  
 
