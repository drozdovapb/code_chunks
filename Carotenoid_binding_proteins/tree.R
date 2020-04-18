library(ggtree)

#read the tree
alltr <- read.iqtree("CBPs.best.trim.fas.treefile")


## now get rid of unsupported labels (below 70% / 0.7)
label <- alltr@phylo$node.label
alrt <- as.numeric(sub("/.*", "", label))
bigalrt <- alrt > 70 & !is.na(alrt)
bayes <- as.numeric(sub(".*/", "", label))
bigbayes <- bayes > 0.7 & !is.na(bayes)
## subset
newlabel <- ifelse( bigalrt & bigbayes, label, "")
alltr@phylo$node.label <- newlabel

## and replace real number with dots
newnewlabel <- ifelse(newlabel == "", "", intToUtf8(9679)) ##9679 is a circle; 9968 is a mountain
alltr@phylo$node.label <- newnewlabel
##empty tree
p_empty <- ggtree(alltr) + geom_treescale(width = 1) 
##tree with labels
p_labs <- p_empty + geom_text2(data = p_empty$data[(!p_empty$data$isTip), ], 
aes(subset=!isTip, label=p_empty$data$label[44:84]), size = 3, 
family = "arial", col = "red") + xlim(0, 12)
p_labs_names <- p_labs + geom_tiplab(align = F,
label = sub("_", " ", p_labs$data$label[which(p_labs$data$isTip == TRUE)]))
##save the file as svg
ggsave("p_labs_names.svg", width = 9, height = 9)
