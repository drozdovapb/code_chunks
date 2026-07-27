library(ggtree)

tre <- read.tree("0_initial_seqs/Cyclidium_and_outgroups.fa.treefile")
#tre <- read.tree("1_trimsoft/Cyclidium_and_outgroups_trimsoft.fa.treefile")
#tre <- read.tree("3_trimNs_hard/Cyclidium_and_outgroups_trimNs.fa.treefile")

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


ggtree(tre) + 
  geom_tiplab() + 
  geom_nodelab(color="red3", size=4, nudge_x = -.001) + 
  geom_treescale() + 
  xlim(c(-0.1, 0.45)) + 
  geom_label(aes(x=.35, y=12), label = "aBayes > 0.7 & \n aLRT > 70%", label.size=NA) + 
  geom_label(aes(x=.30, y=12), label = intToUtf8(9679), col = "red3", label.size=NA) 
ggsave("tree0.svg", device="svg", width = 8, height = 5)
ggsave("tree0.png", device=png, width = 8, height = 5, units = 'in')
