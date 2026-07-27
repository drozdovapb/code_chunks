library(ggtree)
library(ggplot2) ## yes, it needs to be loaded separately for annotate()

tre <- read.tree("2_CAd_16_w_Paraphysomonas.aln.trim.fa.treefile")

## aLRT > 70% or aBayes >0.7 => a red dot
label <- tre$node.label
## Get aLRT from newick and identify large values
alrt <- as.numeric(sub("/.*", "", label))
bigalrt <- alrt > 70 & !is.na(alrt)
## Get aBayes from newick and identify large values
bayes <- as.numeric(sub(".*/", "", label))
bigbayes <- bayes > 0.7 & !is.na(bayes)
## add red dots where appropriate
newlabel <- ifelse(bigalrt & bigbayes, intToUtf8(9679), "")
tre$node.label <- newlabel

tr <- ggtree(tre) + 
  geom_tiplab() + 
  geom_nodelab(color="red3", size=4, nudge_x = -.001) + 
  geom_treescale(width = .02) + 
  xlim(c(-0.1, 0.45)) + 
  annotate(geom = "text", x=.01, y=10, label = "aBayes > 0.7 & \n aLRT > 70%") + 
  annotate(geom="text", x=.001, y=10, label = intToUtf8(9679), col = "red3") 

ggtree(tre) + geom_text(aes(label = node), col="red") + geom_tiplab()

tr

ggsave("tree_16m_draft.svg", device=svg, width = 8, height = 4)
#ggsave("tree0.png", device=png, width = 8, height = 5, units = 'in')
