## boxplots
options(stringsAsFactors = T)

library(ggplot2)
library(openxlsx)
library(reshape2)
library(gridExtra)
library(ggpubr)
library(data.table)
#remotes::install_github("thegeologician/ggprovenance")
library(ggprovenance)

## Read data 
###### 
### Read all the data in one data frame
alldata <- read.xlsx("./all_markers_Ofla_Oalb_noIDs.xlsx", sheet = 1)
for (i in 2:13) {
  tempdata <- read.xlsx("./all_markers_Ofla_Oalb_noIDs.xlsx", sheet = i) 
  alldata <- rbind(alldata, tempdata)
}
  
  
  alldata$Year <- factor(alldata$Year)
  alldata$Parameter <- factor(alldata$Parameter, levels = c(
    "Glucose", "Glycogen Glucose corrected", "LDH",
    "ATP ", "ADP ", "AMP", "AEC",
    "CAT", "GST", "POD", 
    "Heptane, diene conjugates", "Heptane, triene conjugates", "Heptane, Schiff bases", 
    "Isopropanole, diene conjugates", "Isopropanole, triene conjugates", "Isopropanole, Schiff bases"))
  
  ## again, exchange flavus <-> albinus?
  alldata$Species <- factor(alldata$Species, levels = c("O. flavus", "O. albinus"))
  
  
  levels(alldata$Parameter) <- c(
    "Glucose", "Glycogen", "LDH",
    "ATP", "ADP", "AMP", "AEC",
    "CAT", "GST", "POD", 
    "DC, neutral lipids", "TC, neutral lipids", "SB, neutral lipids", 
    "DC, phospholipids", "TC, phospholipids", "SB, phospholipids")

    alldata$`Depth,.m` <- factor(alldata$`Depth,.m`)
  
  
  

    ## Former Figure 3 + supplementary
    ##### 

    ## doesn't work... never mind
#    symnum.args <- list(cutpoints = c(0, 0.0001, 0.001, 0.01, 0.05, 1), 
#                        symbols = c("****", "***", "**", "*", "ns"))
plot3data <- droplevels(alldata[!(alldata$Parameter=="AEC") & alldata$Year %in% c(2015, 2016),])
pd = position_jitterdodge(dodge.width = 0.75, jitter.width = 0.3)

plot3data <- data.table(plot3data)
plot3data[, y_max := max(Value, na.rm = T)*1.2 , by = Parameter]
plot3data[, y_min := max(Value, na.rm = T)*(-0.5) , by = Parameter]

plots3_to_6 <- function(plot3data) { 
  p <- 
      ggplot(plot3data, 
             aes(x = Species, y = Value, ymin = 0, fill=Year)) +
      geom_boxplot(outlier.alpha = 0, alpha = 0.5) + #because we are plotting all points anyway!!! 
      geom_point(size = 1, alpha = 0.5, aes(fill = Year, group = Year, col = `Depth,.m`, shape = `Depth,.m`), 
                  position = position_jitterdodge(jitter.width = 0.5)) + 
      scale_fill_manual(values = c("grey", "white")) +
#      scale_color_manual(values = c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
    scale_color_manual(values = c("deepskyblue", "deepskyblue", "deepskyblue", 
                                  "cornflowerblue", "cornflowerblue", "cornflowerblue", "darkblue", "darkblue")) +
    scale_shape_manual(values = c(3, 8, 19, 3, 8, 19, 8, 19)) +
    facet_wrap( ~ Parameter, ncol = 3, scales = "free") + 
      theme_bw(base_size = 14) + 
      theme(strip.text.x = element_text(size=12),
            axis.text.x = element_text(face = "italic"), 
            legend.text = element_text(size = 10),
            legend.title = element_text(size = 12)) +
    xlab("") + ylab("") + labs(col = "Depth, m", shape = "Depth, m") +
    geom_blank(aes(y=y_max)) + geom_blank(aes(y=y_min)) + 
  geom_hline(yintercept = 0, linetype = "dotted") +
#  scale_y_continuous(breaks = prettyBreaks(range = c(0, y_max))) 
  scale_y_continuous(breaks = function(x) prettyBreaks(range = c(0, max(x) * 1.2), n.major = 4))
#    scale_y_continuous(breaks = scales::pretty_breaks(min.y = .01, n = 5))
#scale_y_continuous(expand = c(0, 0, 0.05, 0)) 

  padjSpecies <- data.frame(Parameter = rep(levels(plot3data$Parameter), each = 2), pval = NA, ymin = NA, ymax = NA,
                            xmin=rep(c(0.9,1.3), length(levels(plot3data$Parameter))), 
                                     xmax=rep(c(1.7,2.1), length(levels(plot3data$Parameter))), 
                            coord=rep(c(1.05, 1.75), length(levels(plot3data$Parameter))))
  m <- 0
  for (i in levels(plot3data$Parameter)) {
    print(levels(plot3data$Parameter[i]))
    for (j in levels(plot3data$Year)) {
      m <- m+1
      tempdata <- plot3data[plot3data$Parameter == i & 
                              plot3data$Year == j, ]
      pw <- wilcox.test(tempdata$Value ~ tempdata$Species)$p.value
      print(pw)
      padjusted <- p.adjust(pw, method = "holm", n = 4)
      print(padjusted)
      padjSpecies$pval[m] <- ifelse(padjusted < 0.05, formatC(padjusted, digits = 1),
                                    "ns")
      padjSpecies$ymin[m] <- min(tempdata$y_min)
      padjSpecies$ymax[m] <- max(tempdata$y_max) * (1 + (as.numeric(j)-2014)/5)
    }}
  padjSpecies

  p <- 
  p + geom_signif(data = padjSpecies, aes(xmin = xmin, xmax = xmax, 
                                           y_position = ymax*.8, annotations = ""), 
                   inherit.aes = F, manual = T, tip_length = c(.075, .075)) + 
    geom_text(data = padjSpecies, aes(x=coord, 
                                            y = ymax*.9, label = pval), 
                    inherit.aes = F)

  ## upper brackets

    
  padjYear <- data.frame(Parameter = rep(levels(plot3data$Parameter), each = 2), pval = NA, ymin = NA, 
                              coord=rep(c(1, 2), length(levels(plot3data$Parameter))))
    
  m <- 0
  for (i in levels(plot3data$Parameter)) {
    print(levels(plot3data$Parameter[i]))
    for (j in levels(plot3data$Species)) {
      m <- m+1
      tempdata <- plot3data[plot3data$Parameter == i & 
                              plot3data$Species == j, ]
      pw <- wilcox.test(tempdata$Value ~ tempdata$Year)$p.value
      print(pw)
      padjusted <- p.adjust(pw, method = "holm", n = 4)
      print(padjusted)
      padjYear$pval[m] <- ifelse(padjusted < 0.05, formatC(padjusted, digits = 1),
                                 "ns")
      padjYear$ymin[m] <- min(tempdata$y_min)
    }}
  padjYear
  
  p <- 
    p + geom_signif(data = padjYear, aes(xmin = coord-.2, xmax = coord+.2, 
                                            y_position = ymin*0.5, annotations = ""), 
                    inherit.aes = F, manual = T, tip_length = c(-0.075, -0.075)) + 
    geom_text(data = padjYear, aes(x=coord, 
                                      y = ymin*.7, label = pval), 
              inherit.aes = F)
 
    print(p) 
    return(p)
}


plots3_to_6(droplevels(plot3data[plot3data$Parameter %in% c("Glucose", "Glycogen", "LDH", 
                                                            "ATP", "ADP", "AMP"), ]))
ggsave("Fig2_15_energy_only_catch_adj.png", width = 260, height = 150, units = "mm")


plots3_to_6(droplevels(plot3data[plot3data$Parameter %in% c("CAT", "GST", "POD",
                      "DC, neutral lipids", "TC, neutral lipids", "SB, neutral lipids",
                      "DC, phospholipids", "TC, phospholipids", "SB, phospholipids"), ]))
ggsave("Fig3_15_oxygen_only_catch_adj.png", width = 260, height = 225, units = "mm")


# ## save data for Fig. 3
# plot2data <- p2$data[[1]][, c("middle", "PANEL", "group")]
# names(plot2data)[1] <- "median"
# plot2data$Species <- ifelse(plot2data$group == 1, "O. flavus", "O. albinus")
# write.xlsx(plot2data, "Fig3_data.xlsx")
# 
# ##check the correction of the p-value! ## no longer needed
# #glycogen <- 
# #alldata[alldata$Parameter == "Glycogen" & 
# #          alldata$Year %in% c("2015", "2016"), 
# #        c("Value", "Species")]
# #wilcox.test(glycogen$Value ~ glycogen$Species)

#####
#### Figure 4    
##now we need acclimation & year
    
    alldata$Condition <- factor(
      ifelse(substr(alldata$Year, 5, 7) == "_C", "acclimation", "sampling"), 
      levels = c("sampling", "acclimation"))
    alldata$Year <- factor(as.numeric(substr(alldata$Year, 1, 4)))
    

ddata <- alldata[alldata$Parameter %in% c("CAT", "GST", "POD") & (
  alldata$Species=="O. albinus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(200, 300) |
  alldata$Species=="O. albinus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(500) |
  alldata$Species=="O. flavus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(100, 150, 300) |
  alldata$Species=="O. flavus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(100, 150, 200) 
  ),
]

## Figure 6. Energy 


ddata <- alldata[alldata$Parameter %in% c(
  "Glucose", "Glycogen", "LDH"
) & (
  alldata$Species=="O. albinus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(200, 300) |
    alldata$Species=="O. flavus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(100, 150, 300) |
    alldata$Species=="O. albinus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(500) & alldata$Parameter == "LDH" |
    alldata$Species=="O. flavus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(100, 150, 200)   & alldata$Parameter == "LDH"
),  ]


ddata$PParameter <- paste0(ddata$Parameter, " (", ddata$Year, ")")

p6 <-   
  ggplot(ddata, 
         aes(x = Year, y = Value, fill = Species, col = Condition)) +
  expand_limits(y=0) +
  geom_boxplot(outlier.alpha = .1) + 
  #geom_jitter(width = .2, size = 1, aes(col = `Depth,.m`)) + 
  #scale_color_manual(values = c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
  facet_wrap( ~ PParameter, scales = "free", nrow = 1) + 
  ylab("") +
  theme_bw(base_size = 12)  + 
  scale_fill_manual(values = c("orange", "beige")) + 
  guides(fill = guide_legend(label.theme = element_text(face = "italic", size = 10))) +
  scale_color_manual(values = c("green4", "black")) #+ 
## too hard to define stat_compare_means in here

p6

## to get parameters
p6b <- ggplot_build(p6)  
p6b$data

## just calculate
padjvect.w.o <- c()
ddata$SpeciesYearEnzyme <- paste0(ddata$Species, ddata$Year, ddata$Parameter)
for (i in unique(ddata$SpeciesYearEnzyme)) {
  print(i)
  tempdata <- ddata[ddata$SpeciesYearEnzyme == i, ]
  #print(tempdata)
  p <- wilcox.test(tempdata$Value ~ tempdata$Condition)$p.value
  print(p)
  ncompar <- ifelse(grepl("LDH", i), 4, 2)
  print(ncompar)
  padjusted <- p.adjust(p, method = "holm", n = ncompar)
  print(padjusted)
  padjvect.w.o <- c(padjvect.w.o, padjusted)
}

padjvect <- padjvect.w.o[c(5, 6, 7, 8, 1, 3, 2, 4)]

##fortunately, no difference between correction for 2 and 6!

signif.df <- data.frame(p.adj = padjvect,
                        signif = ifelse(padjvect > 0.05, "", 
                                        ifelse(padjvect > 0.01, "*", 
                                               ifelse(padjvect > 0.001, "**", "***"))),  #formatC(p.adj, digits = 1)
                        PParameter = c(rep("Glucose (2015)", 2), rep("Glycogen (2015)", 2), 
                                       rep("LDH (2015)", 2), rep("LDH (2016)", 2)),
                        xstart = p6b$data[[2]]$xmin[seq(2, 16, 2)],
                        ypos = c(0.6, 0.6, 7.5, 5, 250, 300, 450, 550),
                        Species = NA)

p6 + geom_text(data = signif.df, aes(x = xstart, y = ypos, label = signif), 
               inherit.aes = F, size = 7)+ #+ 
  geom_text(aes(x=x, y=y, label=lab), inherit.aes = F,
            data=data.frame(x=c(1,1,1,1), y=c(.1,1,823,823), lab=c(""), PParameter = "LDH (2015)",
                            vjust=1))
p6t <- 
  p6 + geom_text(data = signif.df, aes(x = xstart, y = ypos, label = signif), 
                 inherit.aes = F, size = 7)+ #+ 
  geom_text(aes(x=x, y=y, label=lab), inherit.aes = F,
            data=data.frame(x=c(1,1,1,1), y=c(.1,1,823,823), lab=c(""), PParameter = "LDH (2015)",
                            vjust=1))


#p4
#p4b <- ggplot_build(p4)  
#ggsave("Fig6_Energy_common_depths_2comparisons.png", width = 260, height = 100, units = "mm")
#ggsave("Fig6_Energy_common_depths_2comparisons.svg", width = 260, height = 100, units = "mm")

## save the data
plot6data <- p6b$data[[2]][, c("middle", "PANEL", "group")]
names(plot6data)[1] <- "median"
plot6data$Species <- ifelse(plot6data$group == 1, "O. flavus", "O. albinus")
write.xlsx(plot6data, "Fig6_data.xlsx")



## Adenylates
ddata <- alldata[alldata$Parameter %in% c(
  "AMP", "ADP", "ATP", "AEC"
) & (
  alldata$Species=="O. albinus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(200, 300) |
    alldata$Species=="O. flavus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(100, 150, 300)
),
]


p7 <-   
  ggplot(ddata, 
         aes(x = Year, y = Value, fill = Species, col = Condition)) +
  expand_limits(y=0) +
  geom_boxplot(outlier.alpha = .1) + 
  #geom_jitter(width = .2, size = 1, aes(col = `Depth,.m`)) + 
  #scale_color_manual(values = c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
  facet_wrap( ~ Parameter, scales = "free", nrow = 1) + 
  ylab("") + #because they are in different units, actually
  theme_bw(base_size = 12)  + 
  scale_fill_manual(values = c("orange", "beige")) + 
  guides(fill = guide_legend(label.theme = element_text(face = "italic", size = 10))) +
  scale_color_manual(values = c("green4", "black")) #+ 
## too hard to define stat_compare_means in here

p7

## to get parameters
p7b <- ggplot_build(p7)  
p7b$data

## just calculate
padjvect.w.o <- c()
ddata$SpeciesYearEnzyme <- paste0(ddata$Species, ddata$Year, ddata$Parameter)
for (i in unique(ddata$SpeciesYearEnzyme)) {
  print(i)
  tempdata <- ddata[ddata$SpeciesYearEnzyme == i, ]
  #print(tempdata)
  p <- wilcox.test(tempdata$Value ~ tempdata$Condition)$p.value
  padjusted <- p.adjust(p, method = "holm", n = 2)
  print(padjusted)
  padjvect.w.o <- c(padjvect.w.o, padjusted)
}

padjvect <- padjvect.w.o
#stat_compare_means(aes(group = SpeciesYearEnzyme ~ Condition), label = "p.signif", method = "wilcox.test")


signif.df <- data.frame(p.adj = padjvect,
                        signif = ifelse(padjvect > 0.05, "", 
                                        ifelse(padjvect > 0.01, "*", 
                                               ifelse(padjvect > 0.001, "**", "***"))),  #formatC(p.adj, digits = 1)
                        Parameter = c(rep("ATP", 2), rep("ADP", 2), rep("AMP", 2), rep("AEC", 2)),
                        xstart = p7b$data[[2]]$xmin[seq(2, 16, 2)],
                        ypos = c(2, 1.8, 0.4, 0.42, 0.3, 0.28, 0.95, 0.85),
                        Species = NA)

p7 + geom_text(data = signif.df, aes(x = xstart, y = ypos, label = signif), 
               inherit.aes = F, size = 7)
#p4
#p4b <- ggplot_build(p4)  
ggsave("Fig7_Adenylates_common_depths_2comparisons.png", width = 260, height = 100, units = "mm")
ggsave("Fig7_Adenylates_common_depths_2comparisons.svg", width = 260, height = 100, units = "mm")

## save the data
plot7data <- p7b$data[[2]][, c("middle", "PANEL", "group")]
names(plot7data)[1] <- "median"
plot7data$Species <- ifelse(plot7data$group == 1, "O. flavus", "O. albinus")
write.xlsx(plot7data, "Fig7_data.xlsx")  

p7t <- 
p7 + geom_text(data = signif.df, aes(x = xstart, y = ypos, label = signif), 
               inherit.aes = F, size = 7) #+ theme(legend.position = 'None')

p67 <- grid.arrange(p6t, p7t)
ggsave("Fig4_Energy_Adenylates_common_depths.svg", p67, width = 260, height = 200, units = "mm")
###



###FIGURE 5 NEW

ddata <- alldata[alldata$Parameter %in% c(
  "CAT", "GST", "POD"
) & (
  alldata$Species=="O. albinus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(200, 300) |
    alldata$Species=="O. albinus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(500) |
    alldata$Species=="O. flavus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(100, 300) |
    alldata$Species=="O. flavus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(100, 150, 200) 
),
]



  p4 <-   
  ggplot(ddata, 
           aes(x = Year, y = Value, fill = Species, col = Condition)) +
      expand_limits(y=0) +
      geom_boxplot(outlier.alpha = .1) + 
      #geom_jitter(width = .2, size = 1, aes(col = `Depth,.m`)) + 
      #scale_color_manual(values = c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
      facet_wrap( ~ Parameter, scales = "free") + 
      ylab("nkat/mg protein") +
      theme_bw(base_size = 12)  + 
      scale_fill_manual(values = c("orange", "beige")) + 
      guides(fill = guide_legend(label.theme = element_text(face = "italic", size = 10))) +
      scale_color_manual(values = c("green4", "black")) #+ 
    ## too hard to define stat_compare_means in here
  
  p4
  
  ## to get parameters
  p4b <- ggplot_build(p4)  
  p4b$data
  
  ## just calculate
  padjvect.w.o <- c()
  ddata$SpeciesYearEnzyme <- paste0(ddata$Species, ddata$Year, ddata$Parameter)
  for (i in unique(ddata$SpeciesYearEnzyme)) {
    print(i)
    tempdata <- ddata[ddata$SpeciesYearEnzyme == i, ]
    #print(tempdata)
    p <- wilcox.test(tempdata$Value ~ tempdata$Condition)$p.value
    print(p)
    padjusted <- p.adjust(p, method = "holm", n = 4)
    print(padjusted)
    padjvect.w.o <- c(padjvect.w.o, padjusted)
  }
  
  padjvect <- padjvect.w.o[c(9, 11, 10, 12, 5, 7, 6, 8, 1, 3, 2, 4)]
      #stat_compare_means(aes(group = SpeciesYearEnzyme ~ Condition), label = "p.signif", method = "wilcox.test")
  
  
  signif.df <- data.frame(p.adj = padjvect,
                          signif = ifelse(padjvect > 0.05, "", 
                                          ifelse(padjvect > 0.01, "*", 
                                                 ifelse(padjvect > 0.001, "**", "***"))),  #formatC(p.adj, digits = 1)
                          Parameter = c(rep("CAT", 4), rep("GST", 4), rep("POD", 4)),
                          xstart = p4b$data[[2]]$xmin[seq(2, 24, 2)],
                          ypos = c(1250, 800, 1250, 1600, 20, 8, 20, 13.5, 0.08, 0.05, 0.1, 0.13),
                          Species = NA)
  
p4t <-  p4 + geom_text(data = signif.df, aes(x = xstart, y = ypos, label = signif), 
                 inherit.aes = F, size = 7) + theme(axis.title.x=element_blank(),
                                                    #axis.text.x=element_blank(),axis.ticks.x=element_blank(),
                                                    )
  #p4
  #p4b <- ggplot_build(p4)  
  #ggsave("Fig4_AOS_common_depths_4comparisons.png", width = 260, height = 100, units = "mm")
  #ggsave("Fig4_AOS_common_depths_4comparisons.svg", width = 260, height = 100, units = "mm")

  
  plot4data <- p4b$data[[2]][, c("middle", "PANEL", "group")]
  names(plot4data)[1] <- "median"
  plot4data$Species <- ifelse(plot4data$group == 1, "O. flavus", "O. albinus")
  write.xlsx(plot4data, "Fig4_data.xlsx")
  
#  ggsave("Fig4_AOS_common_depths_12comparisons.png", width = 260, height = 130, units = "mm")
#  ggsave("Fig4_AOS_common_depths_12comparisons.svg", width = 260, height = 130, units = "mm")
 
  
  #geom_text(data = data.frame(x = 0.75, y = 20, label = "*", Parameter = "GST"), 
  #          aes(x=x, y=y, label=label), 
   #         inherit.aes = F, size = 7) + 
   # geom_text(data = data.frame(x = 2.25, y = 0.125, label = "**", Parameter = "POD"), 
  #            aes(x=x, y=y, label=label), 
  #            inherit.aes = F, size = 7) + 
  #  geom_text(data = data.frame(x = 1.25, y = 0.125, label = "**", Parameter = "GST"), 
  #            aes(x=x, y=y, label=label), 
  #            inherit.aes = F, size = 7)
  
  

## Figure 5
## Lipid peroxidation & enzymes
    
ddata <- alldata[alldata$Parameter %in% c(
#  "CAT", "GST", "POD",
  "DC, neutral lipids", "TC, neutral lipids", "SB, neutral lipids", 
  "DC, phospholipids", "TC, phospholipids", "SB, phospholipids"
  ) & (
      alldata$Species=="O. albinus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(200, 300) |
        alldata$Species=="O. albinus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(500) |
        alldata$Species=="O. flavus" & alldata$Year == "2015" & alldata$`Depth,.m` %in% c(100, 300) |
        alldata$Species=="O. flavus" & alldata$Year == "2016" & alldata$`Depth,.m` %in% c(100, 150, 200) 
    ),
    ]

      p5 <-   
        ggplot(ddata, 
               aes(x = Year, y = Value, fill = Species, col = Condition)) +
        expand_limits(y=0) +
        geom_boxplot(outlier.alpha = .1) + 
        #geom_jitter(width = .2, size = 1, aes(col = `Depth,.m`)) + 
        #scale_color_manual(values = c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
        facet_wrap( ~ Parameter, scales = "free") + 
        ylab("a.u.") +
        theme_bw(base_size = 12)  + 
        scale_fill_manual(values = c("orange", "beige")) + 
        guides(fill = guide_legend(label.theme = element_text(face = "italic", size = 10))) +
        scale_color_manual(values = c("green4", "black")) #+ 
      ## too hard to define stat_compare_means in here

    p5

  ## to get parameters
  p5b <- ggplot_build(p5)  
  p5b$data

  ## just calculate
  padjvect.w.o <- c()
  ddata$SpeciesYearEnzyme <- paste0(ddata$Species, ddata$Year, ddata$Parameter)
  for (i in unique(ddata$SpeciesYearEnzyme)) {
    print(i)
    tempdata <- ddata[ddata$SpeciesYearEnzyme == i, ]
    #print(tempdata)
    p <- wilcox.test(tempdata$Value ~ tempdata$Condition)$p.value
    padjusted <- p.adjust(p, method = "holm", n = 4)
    print(padjusted)
    padjvect.w.o <- c(padjvect.w.o, padjusted)
  }

## manually
  
  ## if we think there are just 4 multiple comparisons
p5t <-  
  p5 + geom_text(data = data.frame(x = 2.25, y = 1.25, label = "*", Parameter = "DC, neutral lipids"), 
                 aes(x=x, y=y, label=label), 
               inherit.aes = F, size = 7) 

#  ggsave("Fig5_LPO_common_depths_4comparisons.png", width = 260, height = 200, units = "mm")
#  ggsave("Fig5_LPO_common_depths_4comparisons.svg", width = 260, height = 200, units = "mm")
  
#  ggsave("Fig5_LPO_common_depths_12comparisons.png", p5, width = 260, height = 200, units = "mm")
#  ggsave("Fig5_AOS_common_depths_12comparisons.svg", p5, width = 260, height = 200, units = "mm")

    plot5data <- p5b$data[[2]][, c("middle", "PANEL", "group")]
  names(plot5data)[1] <- "median"
  plot5data$Species <- ifelse(plot5data$group == 1, "O. flavus", "O. albinus")
  write.xlsx(plot5data, "Fig5_data.xlsx")
  
p45t <- grid.arrange(p4t, p5t, heights = c(1/3, 2/3))
ggsave("Fig 5.png", p45t, width = 260, height = 300, units = "mm")
