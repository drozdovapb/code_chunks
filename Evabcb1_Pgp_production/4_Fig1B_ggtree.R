library(ggtree)
library(ggplot2)
library(ggimage)
##devtools::install_github("GuangchuangYu/treeio")
#library(treeio)

## read the tree
abcbf <- read.tree("Data/Fig1B_ABCBs_wref_ed.aln.treefile")

#abcbf$tip.label <- gsub("_rnaspades.fasta.transdecoder.pep.repr.faa.*", "", abcbf$tip.label)

abcbf_tree <-
ggtree(abcbf) + 
  geom_tiplab(aes(fontface = "italic")) + 
#  geom_text2(aes(subset=!isTip, label=node), hjust=1, col = "red") +
#  geom_text2(aes(subset=isTip, label=node), hjust=1, col = "red") +
#  geom_nodelab(color = "red3") + #supports; deal with them later
  xlim(x=0,4) + geom_treescale(x = 3, width = 1)


abcbf_tree

## aLRT > 70% or aBayes >0.7 => a red dot
label <- abcbf$node.label
## Get aLRT from newick and identify large values
alrt <- as.numeric(sub("/.*", "", label))
bigalrt <- alrt > 70 & !is.na(alrt)
## Get aBayes from newick and identify large values
bayes <- as.numeric(sub(".*/", "", label))
bigbayes <- bayes > 0.7 & !is.na(bayes)
## add red dots where appropriate
newlabel <- ifelse(bigalrt & bigbayes, "red3", "#00000000")
#abcbf$node.label <- newlabel

tips <- c(rep("Caenorhabditis", 2), rep("Drosophila melanogaster", 2), rep("Helicoverpa", 5), rep("Amphipoda", 32))
#tipsimg <- ggimage::phylopic_uid(tips)
#write.csv(tipsimg, "tipsimg.csv")
tipsimg <- read.csv("tipsimg.csv")



###add just a few silhouettes

phylopics <- data.frame(
  names = c("worm", "fly", "bollworm", "amphipod"), 
  uid = c("d6af4346-e56c-4f3d-84c7-fba921a293f1","31aba24a-a797-42bb-9601-5227d0dc8f75", "c224abfd-ee39-4923-98e5-c2606dcc56cb", "7f7262c6-5d75-45e3-a0da-5028dc44659f")
)

abcbf_tree + geom_nodepoint(col = newlabel) +
  geom_label(aes(x=3.75, y=19), label = "aBayes > 0.7 & \n aLRT > 70%", label.size=NA) + 
  geom_label(aes(x=3, y=19), label = intToUtf8(9679), col = "red3", label.size=NA) + 
  geom_cladelabel(30, 'Gammaridae', offset=1.6, offset.text=.05, extend = .5,
                  barsiz=1, color='darkgreen', angle=90, hjust='center') + 
  geom_cladelabel(29, 'Amphipoda', offset=1.7, offset.text=.05, extend = .5,
                  barsiz=1, color='blue4', angle=90, hjust='center') + 
  geom_hilight(node = 14, fill = 'darkgreen', alpha = .5, extend = 1.5) + 
#  geom_phylopic(image=phylopics$uid[1], color = "black", mapping = aes(x=2.2, y=1, node=1)) + 
  geom_tiplab(subset=1, image=phylopics$uid[1], color = "black", mapping = aes(x=2.2, y=1, node=1), geom="phylopic") + 
#  geom_phylopic(image=phylopics$uid[1], color = "black", mapping = aes(x=2.7, y=3)) + 
  geom_tiplab(subset=1, image=phylopics$uid[3], color = "black", mapping = aes(x=2.7, y=3, node=1), geom="phylopic") +
#  geom_phylopic(image=phylopics$uid[2], color = "black", mapping = aes(x=2.9, y=5)) + 
  geom_tiplab(subset=1, image=phylopics$uid[2], color = "black", mapping = aes(x=2.9, y=5, node=1), geom="phylopic") + 
#  geom_phylopic(image=phylopics$uid[3], color = "black", mapping = aes(x=3.1, y=7)) + 
  geom_tiplab(subset=1, image=phylopics$uid[3], color = "black", mapping = aes(x=3.1, y=7, node=1), geom="phylopic") +  
#  geom_phylopic(image=phylopics$uid[4], color = "black", mapping = aes(x=3, y=20)) 
 geom_tiplab(subset=1, image=phylopics$uid[4], color = "blue", mapping = aes(x=2.9, y=15, node=1), geom="phylopic")

ggsave(filename = "tree_pics.svg", width = 22, height = 12, units = "cm") 
  