rm(list=ls()) ## never hurts to have a clean space

#install.packages("extrafont")
library("extrafont")
#font_import()
library(ggtree)

tr <- read.iqtree("Gla_RNAseq_Baikal_renamed.treefile")

## now get rid of unsupported labels (below 70% / 0.7)
label <- tr@phylo$node.label
alrt <- as.numeric(sub("/.*", "", label))
bigalrt <- alrt > 70 & !is.na(alrt)
##the first number
bayes <- as.numeric(sub(".*/", "", label))
bigbayes <- bayes > 0.7 & !is.na(bayes)
## subset
newlabel <- ifelse( bigalrt & bigbayes, label, "")
tr@phylo$node.label <- newlabel

###Short tree for fig. ???

newnewlabel <- ifelse(newlabel == "", "", intToUtf8(9968)) ##9679 is a circle; 9968 is a mountain ;)
tr@phylo$node.label <- newnewlabel

## coloring!
## all black
colors <- rep("black", length(tr@phylo$tip.label)) 
## Base blues
colors[(grepl("Gla", tr@phylo$tip.label))] <- "#009E73" ##bluish green
## Europe 
colors[(grepl("Europe", tr@phylo$tip.label))] <- "#E69F00" ##orange
## Shira 
colors[(grepl("Shira", tr@phylo$tip.label))] <- "#F0E442" ##yellow
## Tibet
colors[(grepl("SRX", tr@phylo$tip.label))] <- "#D55E00" ##vermillion
## Lake 14
colors[(grepl("Bolshie", tr@phylo$tip.label))] <- "#56B4E9" ##sky blue
## RNAseq
colors[(grepl("Sample", tr@phylo$tip.label))] <- "#0072B2" ##blue

t1 <- ggtree(tr, aes(x, y), ladderize = F, layout = "fan") + 
  geom_tree() + theme_tree()  + xlim(0, 0.25)
#  geom_treescale(offset=-2, x = 0, width = 0.1) + 

sh <- rep(19, length(tr@phylo$tip.label)) 
sh[(grepl("Dictyocoela", tr@phylo$tip.label))] <- 8
sh[(grepl("Pleistophora", tr@phylo$tip.label))] <- 8

ggtree(tr, aes(x, y), ladderize = F, layout = "fan") + 
  geom_tree() + theme_tree()  + xlim(0, 0.75) +
  geom_treescale(offset=-2, x = 0, width = 0.1) + 
  geom_point(data = t1$data[(t1$data$isTip), ], col = colors, alpha=1, size = 1, shape = sh) + 
  geom_tiplab(aes(angle=angle), col = colors, show.legend = T, size = 2) + 
  geom_text2(data = t1$data[(!t1$data$isTip), ], 
                        aes(subset=!isTip, label=tr@phylo$node.label), size = 1, 
                        family = "arial", col = "darkred") 


ggsave("circular_tree_wlabs.png", width=100, height=50, units = "cm", dpi = 300)
#ggsave("circular_tree_wlabs.svg", width=100, height=50, units = "cm")

ggtree(tr, aes(x, y), ladderize = F, layout = "fan") + 
  geom_tree() + theme_tree()  +#+ xlim(0, 0.75) +
  geom_treescale(offset=-2, x = 0, width = 0.1) + 
  #geom_tiplab(aes(angle=angle), col = colors, show.legend = T, size = 2) + 
  ## let's go without suppport, I can't see it anyway
  #geom_text2(data = t1$data[(!t1$data$isTip), ], 
  #           aes(subset=!isTip, label=tr@phylo$node.label), size = 2, 
  #           family = "arial", col = "darkred") +
  geom_point(data = t1$data[(t1$data$isTip), ], col = colors, alpha=1, size = 2, shape = sh) 


#t2 <- 
#t1 + geom_point(data = t1$data[(t1$data$isTip), ], col = colors, alpha=1, size = 1) 

ggsave("circular_tree.svg", width=40, height=40, units = "cm")
  
###


##Collapse RNAseq nodes?
# t1 + geom_text(aes(label=node), hjust=-.3, size =2) + xlim(0, .1)
# t1 + geom_point(data = t1$data[(t1$data$isTip), ], col = colors) + xlim(0, .1)
# tc <- collapse(t1, node = 133) 
# tc + geom_point(data = tc$data[(tc$data$isTip), ], col = colors)
## no, it doesn't really help





##and bigger view


tr <- read.iqtree("")






#ggsave(t1, file = "Gla_and_refs.png", device = "png", width = 30, height = 20, units = "cm")


## with support labels, but this is unreadable
#t2 <- t1 + geom_text2(data = t1$data[(!t1$data$isTip), ], 
#                      aes(subset=!isTip, label=tr@phylo$node.label), hjust=1, vjust = -0.3, size = 2, 
#                      family = "arial", col = "darkgrey") 

#t2


newnewlabel <- ifelse(newlabel == "", "", intToUtf8(9679))
tr@phylo$node.label <- newnewlabel


colors <- ifelse(grepl("Gla", tr@phylo$tip.label), 
                 ifelse(grepl("Lake_14", tr@phylo$tip.label), "green", "chartreuse4"), 
                 "black")


t1 <- ggtree(tr, aes(x, y), ladderize = F) + 
  geom_tree() + theme_tree() + 
  geom_treescale(offset=-2, x = 0, width = 0.1) + 
  geom_tiplab(size=2, family = "arial", col = colors, show.legend = T) + 
  xlim(0, 1.5) #+

t2 <- t1 + geom_text2(data = t1$data[(!t1$data$isTip), ], 
                      aes(subset=!isTip, label=tr@phylo$node.label), size = 3, 
                      family = "arial", col = "darkred") 

t3 <- 
t2 +  annotate("text", label = "Microsporidian isolates from G. lacustris from Lake 14", 
               x = 0.8, y = 70, size = 2.5, colour = "green", hjust = 0) + 
  annotate("text", label = "Other microsporidian isolates from G. lacustris", 
           x = 0.8, y = 68, size = 2.5, colour = "chartreuse4", hjust = 0) + 
  annotate("text", label = "Taxonomically defined microsporidian isolates", 
           x = 0.8, y = 66, size = 2.5, colour = "black", hjust = 0)


t2

t2 + geom_point(data = t1$data[(t1$data$isTip), ], col = "grey")

ggsave(t2, file = "Gla_and_refs.png", device = "png", width = 20, height = 18, units = "cm")
ggsave(t3, file = "Gla_and_refs.svg", device = "svg", width = 30, height = 20, units = "cm")

#t2 <- ggtree::flip(t1, 74, 136)
#t3 <- reroot(t2, 73)



ta <- ggtree(tr, aes(x, y), ladderize = F) + 
  #geom_tree() + theme_tree() + 
  geom_treescale(offset=-2, x = 0, width = 0.1) + 
  geom_tiplab(size=2, family = "arial", col = colors, show.legend = T) + 
  xlim(0, 1.5) #+

ta + geom_text2(data = t1$data[(!t1$data$isTip), ], 
                aes(subset=!isTip, label=tr@phylo$node.label), size = 3, 
                family = "arial", col = "darkred") 

