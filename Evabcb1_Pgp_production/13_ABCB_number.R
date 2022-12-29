library(openxlsx)
library(ggplot2)

## we cannot work with the sum of ABCs

abc_res <- read.xlsx("../suppl/Table S1_2022-10-12.xlsx", startRow = 2)

abc_res$`Geographic.origin.(for.Gammaroidea.only)`


#ggplot(abc_res[abc_res$Complete > 75, ], aes(Complete, ABCBF)) + geom_point(aes(color = `Geographic.origin.(for.Gammaroidea.only)`)) +
#  geom_smooth(method = "lm") + stat_cor(method = "spearman") + 
#  theme_bw(base_size = 14)



good_assemblies <- abc_res[abc_res$Complete > 85, ]

library(reshape2)

good_assembliesM <- melt(good_assemblies, id.vars = c("Species.Name"),
                         measure.vars = ,c("ABCA", "ABCBF", "ABCBH", "ABCC", "ABCD", "ABCE", "ABCF", "ABCG", "ABCH"),
                         variable.name = "ABC.class")
good_assembliesM <- good_assembliesM[good_assembliesM$value > 0,]


good_assembliesM$Species.Name <- factor(good_assembliesM$Species.Name, 
                                        levels = c("Helicoverpa armigera", "Drosophila melanogaster",
                                                   "Hyalella azteca", 
                                                   "Echinogammarus berilloni",
                                                   "Gammarus fossarum", "Gammarus minus", "Gammarus pulex", "Gammarus wautieri", "Marinogammarus marinus",
                                                   "Eogammarus possjeticus", 
                                                   "Eulimnogammarus cruentus", "Eulimnogammarus verrucosus",
                                                   "Linevichella vortex", "Macropereiopus parvus",
                                                   "Ommatogammarus albinus", "Oxyacanthus flavus",
                                                   "Pachyschesis branchialis"))


ggplot(good_assembliesM, aes(x = ABC.class, y = Species.Name)) + 
  geom_tile(aes(fill = value), color = "white", lwd = 0.5) + 
#  scale_fill_gradient(low = "lightblue", high = "blue4", guide = "legend", breaks = c(1,2,4,8,16), name = "# transcripts") +
  scale_fill_gradient(low = "lightblue", high = "blue4", guide = "legend", breaks = 1:16, name = "# transcripts") +
  theme_minimal(base_size = 14) + 
  theme(axis.text.y = element_text(face = "italic"), axis.text.x = element_text(angle = 30, hjust = 0.5), panel.grid.major = element_blank()) +
  xlab("") + ylab("") + 
  scale_x_discrete(position = "top")
ggsave("Nabcs.svg", height = 5, width = 8)
ggsave("Nabcs.png", height = 5, width = 8)

hist(good_assembliesM$value, breaks = 16)
## In Inkscape: 90% width.