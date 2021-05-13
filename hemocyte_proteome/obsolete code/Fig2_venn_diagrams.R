library(readxl)
library(ggplot2)
library(openxlsx)
#install.packages("UpSetR")
#library("UpSetR")


## read the data
sample51 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_1_Default Protein Report.xls")
sample52 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_2_Default Protein Report.xls")
sample53 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_3_Default Protein Report.xls")

sample61 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_1_Default Protein Report.xls")
sample62 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_2_Default Protein Report.xls")
sample63 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_3_Default Protein Report.xls")

## one list with all sample names
listNames <- list(one = sample51$`Main Accession`, two = sample52$`Main Accession`, three = sample53$`Main Accession`,
                  four = sample61$`Main Accession`, five = sample62$`Main Accession`, six = sample63$`Main Accession`)
## and separate vectors (whichever works better)
one <- sample51$`Main Accession`
two <- sample52$`Main Accession`
three <- sample53$`Main Accession`
four <- sample61$`Main Accession`
five <- sample62$`Main Accession`
six <- sample63$`Main Accession`


## logical operations
## these are the proteins found in each sample. The core proteome, if you wish.
found <- list(Reduce(intersect, listNames))[[1]]
## and proteins found in at least one sample
allfound <- list(Reduce(union, listNames))[[1]]
#allfound <- sapply(found[[1]], FUN = function(x) {strsplit(x, "|", fixed = T)[[1]][1]})
#writeLines(found, "all_found_proteins.txt")

allSDS <- unique(c(one, two, three))
allnoSDS <- unique(c(four, five, six))
coreSDS <- list(Reduce(intersect, listNames[1:3]))[[1]]
corenoSDS <- list(Reduce(intersect, listNames[4:6]))[[1]]

### Venn diagram part
##https://stackoverflow.com/questions/8713994/venn-diagram-proportional-and-color-shading-with-semi-transparency
##https://www.datanovia.com/en/blog/venn-diagram-with-r-or-rstudio-a-million-ways/
#if (!require(devtools)) install.packages("devtools")
#devtools::install_github("yanlinlin82/ggvenn")
#library(ggvenn)
#ggvenn(
#  listNames[1:3], 
##  fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF"),
#  stroke_size = 0.5, set_name_size = 4)

#if (!require(devtools)) install.packages("devtools")
#devtools::install_github("gaospecial/ggVennDiagram")
#library(ggVennDiagram)

#ggVennDiagram(listNames) ## only 2-4 dimension! They're really good
#ggVennDiagram(listNames[1:3], label_alpha=0)
#ggVennDiagram(listNames[4:6], label_alpha=0)


#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install("biomaRt")
#install.packages('BioVenn')
#library(BioVenn)
## it works but very vibrant... and the arguments names are not entirely clear... 
## installation troubles...
## So: it works but I opt for eulerr (see below)
#svg("SDS.svg")
#BioVenn::draw.venn(one, two, three, title = "Samples with SDS", subtitle = "",
#                   xtitle = "", ytitle = "", ztitle = "", nr_fb = 1, t_fb = 1)
#dev.off()
#svg("noSDS.svg")
#BioVenn::draw.venn(four, five, six, title = "Samples without SDS", subtitle = "",
#                   xtitle = "", ytitle = "", ztitle = "", nr_fb = 1, t_fb = 1)
#dev.off()
#svg("allSDSvsnoSDS.svg")
#BioVenn::draw.venn(allSDS, allnoSDS, list(), title = "Samples with SDS vs. without SDS", 
#                   subtitle = "All proteins present in at least one sample",
#                   xtitle = "", ytitle = "", ztitle = "", nr_fb = 1, t_fb = 1)
#dev.off()
#svg("coreSDSvsnoSDS.svg")
#BioVenn::draw.venn(coreSDS, corenoSDS, list(), title = "SDS vs no SDS (core)", 
#                   subtitle = "",
#                   xtitle = "", ytitle = "", ztitle = "", nr_fb = 1, t_fb = 1)
#dev.off()


## Option 4. venneuler
#install.packages('venneuler')
#library(venneuler)
#df <- data.frame(elements=c(one, two, three),
#                 sets=c(rep("51", length(one)), rep("52", length(two)), rep("53", length(three))))
#vdf <- venneuler(df)
#plot(vdf)

#df <- data.frame(elements=c(four, five, six),
#                 sets=c(rep("61", length(four)), rep("62", length(five)), rep("63", length(six))))
#vdf <- venneuler(df)
#plot(vdf)

#df <- data.frame(elements=c(allSDS, allnoSDS), 
#                 sets=c(rep("allSDS", length(allSDS)), rep("allnoSDS", length(allnoSDS))))
#vdf <- venneuler(df)
#plot(vdf)

#df <- data.frame(elements=c(coreSDS, corenoSDS), 
#                 sets=c(rep("coreSDS", length(coreSDS)), rep("corenoSDS", length(corenoSDS))))
#vdf <- venneuler(df)
#plot(vdf)


#install.packages('nVennR')
#library(nVennR)
#myV2 <- plotVenn(
#  list(one, two, three), 
#  outFile = "test.svg")


#install.packages("VennDiagram")
#library(VennDiagram) 
#venn.diagram(x = list(one, two, three), 
#             fill = c("lightblue", "green", "blue"),
#             alpha = c(0.5, 0.5, 0.5), category = rep("", 3), 
#             filename = "VennDiagram.svg", imagetype = "svg", height = 10, width = 10)
## why the heck isn't it proportional?!

#install.packages('eulerr')
library(eulerr)
#plot(venn(list(one = unique(one), two = unique(two), three = unique(three))))
#plot(euler(list(four = unique(four), five = unique(five), six = unique(six))))
svg("SDS.svg", width = 3, height = 3)
plot(euler(list(one = unique(one), two = unique(two), three = unique(three))), Count=T, quantities = T,
     fill = c("#f0e442", "#009e73","#0072b2"), alpha = 0.5, labels = c("","",""), lty = 2, col = "black")
dev.off()

svg("noSDS.svg", width = 3, height = 3)
plot(euler(list(one = unique(four), two = unique(five), three = unique(six))), Count=T, quantities = T,
     fill = c("#f0e442", "#009e73","#0072b2"), alpha = 0.5, labels = c("","",""))
dev.off()

svg("all.svg", width = 3, height = 3)
plot(euler(list(SDS = allSDS, `No SDS` = allnoSDS)), 
     fill = c("grey70", "grey95"), lty = c(2, 1), main = "Proteins found in at least one replicate", 
     Count=TRUE, quantities = TRUE)
dev.off()

svg("core.svg", width = 3, height = 3)
plot(euler(list(SDS = coreSDS, `No SDS` = corenoSDS)), col = "black", lty = c(2, 1),
     fill = c("grey50", "grey80"), lty = c(2, 1), main = "Proteins found in three replicates", 
     Count=TRUE, quantities = TRUE)
dev.off()
