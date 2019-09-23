library(reshape2)
peptides <- read.delim("/home/drozdovapb/Research/Projects/cyaneus_proteome/MQ_results/peptides.txt")

str(peptides)
id.cols <- grepl("Identification.type.", names(peptides))

cnt <- apply(peptides[, id.cols], MARGIN = 2, FUN = function(x) x != "")

head(cnt)
row.names(cnt) <- peptides$Sequence

cnts <- as.data.frame(t(cnt))
cnts$samples <- substr(names(peptides[ , id.cols]), 1, 25)

cntsm <- melt(cnts, id.vars = "samples")
cntsm1 <- dcast(cntsm, formula = samples + variable ~ value)
cntsm1$found <- cntsm1$"TRUE" > 0  

#and finally, here's the number of peptides per sample!
cntsm2 <- dcast(cntsm1, formula = samples ~ found)
# min, max, mean, etc... 
min(cntsm2$"TRUE")
max(cntsm2$"TRUE")
mean(cntsm2$"TRUE")
sd(cntsm2$"TRUE")
