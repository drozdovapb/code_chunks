setwd("/media/drozdovapb/big/Research/Projects/cyaneus_proteome/MQ_results/2018-02-all-combined-mq1.6/")

source("./eBayes_functions.R")

#   GO TERMS
#annotation <- read.delim("../EcyBCdTP1_cor_renamed_found.annot", header=F)
annotation <- read.delim("../EcyBCdTP1_cor_renamed_found.csv")
#names(annotation) <- c("protein", "GO", "description")
##Blast2GO reports with underscores while I had semicolons
##let's replace back
#annotation$Protein.IDs <- unlist(lapply( "_", gsub, ";", annotation$protein))

#No, let's just create unique names (should be 2526 of them)
annotation$Protein.IDs <- unlist(lapply( "_clen.*", gsub, "", annotation$SeqName))
#annotation$Protein.IDs[1]
annotation$Protein.IDs <- unlist(lapply( "aalen_", gsub, "aalen=", annotation$Protein.IDs))
annotation$Protein.IDs <- unlist(lapply( "_", gsub, ",", annotation$Protein.IDs))
#and return %
annotation$Protein.IDs <- unlist(lapply( ",complete", gsub, "%,complete", annotation$Protein.IDs))
annotation$Protein.IDs <- unlist(lapply( ",partial", gsub, "%,partial", annotation$Protein.IDs))
#length(unique(annotation$Protein.IDs))==length(unique(annotation$SeqName)) #works

allproteins <- readLines("../EcyBCdTP1_cor_proteins_found.txt") #these are Protein Groups!!!

proteinGroups <- read.delim("proteinGroups_with_sums.csv")
goodProteins <- proteinGroups[proteinGroups$Peptides > 1 &
                              proteinGroups$Only.identified.by.site == "" & 
                              proteinGroups$Potential.contaminant ==  "" & 
                                proteinGroups$Reverse ==  "" ,]
#now replace

#

#let's construct a data frame
allannotated <- data.frame(Protein.IDs <- allproteins, 
                           GO <- "", description <- "")
#fix the names

names(allannotated) <- c("Protein.IDs", "GO", "description")
allannotated$GO <- as.character(allannotated$GO)
allannotated$description <- as.character(allannotated$description)

#fix ids #bad idea, I need those
#allannotated$Proteins.IDs <- unlist(lapply( "=", gsub, "_", allannotated$Proteins.IDs))
#allannotated$Proteins.IDs <- unlist(lapply( ",", gsub, "_", allannotated$Proteins.IDs))
#allannotated$Proteins.IDs <- unlist(lapply( "%", gsub, "", allannotated$Proteins.IDs))
#allannotated$Proteins.IDs <- unlist(lapply( ";", gsub, "_", allannotated$Proteins.IDs))

for (num_pr in 1:length(annotation$Protein.IDs)) { #for each row in the annotated proteins
#for (num_pr in 1:48) { #for each row in the annotated proteins #this line is for testing
    num_pr_gr <- grep(annotation$Protein.IDs[num_pr], allannotated$Protein.IDs)
    #if not here yet
    if(!(grepl(annotation$GO.IDs[num_pr], allannotated$GO[num_pr_gr]))) {
        allannotated$GO[num_pr_gr] <- paste0(allannotated$GO[num_pr_gr], ";", 
                                             annotation$GO.IDs[num_pr]) }
    if(!(grepl(annotation$InterPro.GO.IDs[num_pr], allannotated$GO[num_pr_gr]))) {
        allannotated$GO[num_pr_gr] <- paste0(allannotated$GO[num_pr_gr], ";", 
                                             annotation$InterPro.GO.IDs[num_pr]) }
    #and description
    allannotated$description[num_pr_gr] <- 
        paste0(allannotated$description[num_pr_gr], ";", annotation$Description[num_pr])
        }
#Works for ~30 seconds. Acceptable


allannotated <- allannotated[allannotated$Protein.IDs %in% goodProteins$Protein.IDs,]

write.csv(allannotated, "annotation.csv")


































#read the data
dat <- read.delim("proteinGroups_with_sums.csv")

data <- dat[dat$Peptides > 1 & 
        dat$Only.identified.by.site == "" & 
        dat$Potential.contaminant ==  "" & 
        dat$Reverse ==  "" ,]

dd <- merge(data, allannotated, by = "Protein.IDs")
columns_keep <- names(dd)[
  names(dd) %in% c("Protein.IDs", "description", "Intensity") | 
    startsWith(names(dd), "sum_")]

dd_inten <- dd[,columns_keep]
dd_inten <- dd_inten[order(dd_inten$Intensity, decreasing = T),]

write.xlsx(dd_inten, "annotated_intensities.xlsx")


cmf <- data[,(names(data) == "Protein.IDs" | 
                  startsWith(names(data), "sum_MK") | 
                  startsWith(names(data), "sum_FK"))]
chf <- data[,(names(data) == "Protein.IDs" | 
                  startsWith(names(data), "sum_FK") | 
                  startsWith(names(data), "sum_FHS"))]
chm <- data[,(names(data) == "Protein.IDs" | 
                  startsWith(names(data), "sum_MK") | 
                  startsWith(names(data), "sum_MHS"))]
ch <- data[,(names(data) == "Protein.IDs" | 
                 startsWith(names(data), "sum_"))]

#merge with annotation
cmf <- merge(allannotated, cmf, by = "Protein.IDs", all.y= TRUE , all.x = FALSE)
chf <- merge(allannotated, chf, by = "Protein.IDs", all.y= TRUE , all.x = FALSE)
chm <- merge(allannotated, chm, by = "Protein.IDs", all.y= TRUE , all.x = FALSE)
ch <- merge(allannotated, ch, by = "Protein.IDs", all.y= TRUE , all.x = FALSE)

#Here we finally start counting
#Look at the data
logcmf <- explore.and.log(cmf, which(startsWith(names(cmf), "sum")))
#MK_N!
logchf <- explore.and.log(chf, which(startsWith(names(chf), "sum")))
#looks good!
logchm <- explore.and.log(chm, which(startsWith(names(chm), "sum")))
#many problems!
logch <- explore.and.log(ch, which(startsWith(names(ch), "sum")))
#many problems!

#No normalization procedure was able to fix the problem with MK_N!
#Example!
normvalues <- normalizeBetweenArrays(logcmf)
boxplot(normvalues, las=2, cex.axis=0.7, main="Log_cmf")
normvalues <- normalizeBetweenArrays(logchf)
boxplot(normvalues, las=2, cex.axis=0.7, main="Log_chf")
normvalues <- normalizeBetweenArrays(logchm)
boxplot(normvalues, las=2, cex.axis=0.7, main="Log_chm")
normvalues <- normalizeBetweenArrays(logch)
boxplot(normvalues, las=2, cex.axis=0.7, main="Log_ch")

cmf.only.one <- show.only.in.one(cmf, gr1cols = which(startsWith(names(cmf), "sum_F")), 
                                      gr2cols = which(startsWith(names(cmf), "sum_M")))
chf.only.one <- show.only.in.one(chf, gr1cols = which(startsWith(names(chf), "sum_FK")), 
                                      gr2cols = which(startsWith(names(chf), "sum_FHS")))
chm.only.one <- show.only.in.one(chm, gr1cols = which(startsWith(names(chm), "sum_MK")), 
                                      gr2cols = which(startsWith(names(chm), "sum_MHS")))
ch.only.one <- show.only.in.one(ch, gr1cols = which(startsWith(names(ch), "sum_MK") | startsWith(names(ch), "sum_FK")), 
                                 gr2cols = which(startsWith(names(ch), "sum_MHS") | startsWith(names(ch), "sum_FHS")))


write.xlsx(cmf.only.one, file = "./proteinGroups_males_vs_females_control_only_in_one.xlsx")
write.xlsx(chf.only.one, file = "./proteinGroups_females_control_vs_HS_only_in_one.xlsx")
write.xlsx(chm.only.one, file = "./proteinGroups_males_control_vs_HS_only_in_one.xlsx")
write.xlsx(ch.only.one, file = "./proteinGroups_all_control_vs_HS_only_in_one.xlsx")

#From now on we analyze only the proteins existing in all samples
#Remove zeros and log values 
#(by the way, log transformation explicitly tells us whether removing zeros worked fine)

LFQ_cols <- which(startsWith(names(cmf), "sum"))
logcmf.nz <- log2(removezeros(cmf, LFQ_cols)[, LFQ_cols])
LFQ_cols <- which(startsWith(names(chf), "sum"))
logchf.nz <- log2(removezeros(chf, LFQ_cols)[, LFQ_cols])
LFQ_cols <- which(startsWith(names(chm), "sum"))
logchm.nz <- log2(removezeros(chm, LFQ_cols)[, LFQ_cols])
LFQ_cols <- which(startsWith(names(ch), "sum"))
logch.nz <- log2(removezeros(ch, LFQ_cols)[, LFQ_cols])


cmf.nz.norm <- normalizedata(logcmf.nz) #finally fine?
chf.nz.norm <- normalizedata(logchf.nz) #good
chm.nz.norm <- normalizedata(logchm.nz) #good!
ch.nz.norm <- normalizedata(logch.nz) #good!

#Design schemes for comparison
    design.cmf <- model.matrix(~0 + factor(c(2, 2, 2, 2, 2, 1, 1, 1)))
colnames(design.cmf) <- c("females", "males")
cm.cmf <- makeContrasts(males-females, levels=design.cmf)
    design.chf <- model.matrix(~0 + factor(c(2, 2, 2, 1, 1, 1, 1, 1)))
colnames(design.chf) <- c("females_hs", "females_control")
cm.chf <- makeContrasts(females_hs-females_control, levels=design.chf)
    design.chm <- model.matrix(~0 + factor(c(2, 2, 2, 1, 1, 1)))
colnames(design.chm) <- c("males_hs", "males_control")
cm.chm <- makeContrasts(males_hs-males_control, levels=design.chm)
    design.ch <- model.matrix(~0 + factor(c(2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1)))
colnames(design.ch) <- c("hs", "control")
cm.ch <- makeContrasts(hs-control, levels=design.ch)
    
cmf.proteins <- removezeros(cmf, which(startsWith(names(cmf), "sum_")))
chf.proteins <- removezeros(chf, which(startsWith(names(chf), "sum_")))
chm.proteins <- removezeros(chm, which(startsWith(names(chm), "sum_")))
ch.proteins <- removezeros(ch, which(startsWith(names(ch), "sum_")))

source("./eBayes_functions.R")

#code for the plot see in the function
cmf.tt <- cbind(cmf.proteins[,c("Protein.IDs", "GO", "description")], 
                eb(cmf.nz.norm, design.cmf, cm.cmf), 
                cmf.proteins[,which(startsWith(names(cmf.proteins), "sum_"))])
chf.tt <- cbind(chf.proteins[,c("Protein.IDs", "GO", "description")], 
                eb(chf.nz.norm, design.chf, cm.chf), 
                chf.proteins[,which(startsWith(names(chf.proteins), "sum_"))])
chm.tt <- cbind(chm.proteins[,c("Protein.IDs", "GO", "description")], 
                eb(chm.nz.norm, design.chm, cm.chm), 
                chm.proteins[,which(startsWith(names(chm.proteins), "sum_"))])
ch.tt <- cbind(ch.proteins[,c("Protein.IDs", "GO", "description")], 
                eb(ch.nz.norm, design.ch, cm.ch), 
                ch.proteins[,which(startsWith(names(ch.proteins), "sum_"))])


#write.xlsx(chm.tt, file = "./proteinGroups_males_contr_vs_HS_stat.xlsx")
write.xlsx(cmf.tt, file = "./proteinGroups_males_vs_females_control_stat.xlsx")
write.xlsx(chf.tt, file = "./proteinGroups_females_control_vs_HS_stat.xlsx")
write.xlsx(chm.tt, file = "./proteinGroups_males_control_vs_HS_stat.xlsx")

cmf.tt.signif <- cmf.tt[cmf.tt["adj.P.Val"] < 0.05,]
cmf.tt.signif <- cmf.tt.signif[order(cmf.tt.signif$logFC),]
write.xlsx(cmf.tt.signif, file = "./proteinGroups_males_vs_females_control_signif.xlsx")

chf.tt.signif <- chf.tt[chf.tt["adj.P.Val"] < 0.05,]
chf.tt.signif <- chf.tt.signif[order(chf.tt.signif$logFC),]
write.xlsx(chf.tt.signif, file = "./proteinGroups_females_control_vs_HS_signif.xlsx")

chm.tt.signif <- chm.tt[chf.tt["adj.P.Val"] < 0.05,]
chm.tt.signif <- chm.tt.signif[order(chm.tt.signif$logFC),]
write.xlsx(chm.tt.signif, file = "./proteinGroups_males_control_vs_HS_signif.xlsx")


#####Various visualization tools

#read the data
data <- read.delim("proteinGroups_with_sums.csv")

allLFQs <- data[,(names(data) == "Protein.IDs" | 
                      startsWith(names(data), "sum_"))]

#install.packages("gplots")
library(gplots)
heatmap.2(log2(as.matrix(allLFQs[1:100,-1])+0.001))

library(RColorBrewer)
#coul = colorRampPalette(brewer.pal(8, "PiYG"))(512)
coul = brewer.pal(n = 9, "Blues")

#png(width = 800, height = 600)
svg(height=6, width=8)
par(mar=c(8, 4, 4, 2))
#heatmap.2(log2(as.matrix(allLFQs[1:100,-1])+0.001), col = coul, cexCol = 1, labRow = F)
#heatmap.2(log2(as.matrix(allLFQs[,-1])+0.001), col = coul, cexCol = 1, labRow = F)
#heatmap.2(as.matrix(allLFQs[,-1]), col = coul, cexCol = 1, labRow = F)
heatmap.2(log10(as.matrix(allLFQs[,-1])+1), col = coul, cexCol = 1, labRow = F, 
          density.info = "none", trace = "none")
dev.off()




###One plot
tt <- cmf.tt
signif <- ifelse(abs(tt$logFC) > 1 & tt$adj.P.Val < 0.05, "violetred", "black")
svg("Male vs female.svg")
plot(tt$logFC, -log10(tt$adj.P.Val), xlab="log2 fold change", 
          ylab="-log10  p.adjusted (q)", main=paste("eBayes", 
                                                    substitute(normvalues)), pch=19, cex=0.5, col = signif, las = 1)
dev.off()
