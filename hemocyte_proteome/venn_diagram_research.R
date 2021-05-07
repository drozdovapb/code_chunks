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
#install.packages('Bif  oVenn')
library(BioVenn)
BioVenn::draw.venn(one, two, three, title = "SDS", subtitle = "",
                   xtitle = "", ytitle = "", ztitle = "")
BioVenn::draw.venn(four, five, six, title = "no SDS", subtitle = "",
                   xtitle = "", ytitle = "", ztitle = "")
BioVenn::draw.venn(allSDS, allnoSDS, list(), title = "SDS vs no SDS", 
                   subtitle = "",
                   xtitle = "", ytitle = "", ztitle = "")
BioVenn::draw.venn(coreSDS, corenoSDS, list(), title = "SDS vs no SDS (core)", 
                   subtitle = "",
                   xtitle = "", ytitle = "", ztitle = "")

## Option 4. venneuler
#install.packages('venneuler')
library(venneuler)

df <- data.frame(elements=c(one, two, three),
                 sets=c(rep("51", length(one)), rep("52", length(two)), rep("53", length(three))))
vdf <- venneuler(df)
plot(vdf)

df <- data.frame(elements=c(four, five, six),
                 sets=c(rep("61", length(four)), rep("62", length(five)), rep("63", length(six))))
vdf <- venneuler(df)
plot(vdf)

df <- data.frame(elements=c(allSDS, allnoSDS), 
                 sets=c(rep("allSDS", length(allSDS)), rep("allnoSDS", length(allnoSDS))))
vdf <- venneuler(df)
plot(vdf)

df <- data.frame(elements=c(coreSDS, corenoSDS), 
                 sets=c(rep("coreSDS", length(coreSDS)), rep("corenoSDS", length(corenoSDS))))
vdf <- venneuler(df)
plot(vdf)


#install.packages('nVennR')
library(nVennR)
myV2 <- plotVenn(
  list(one, two, three), 
  outFile = "test.svg")


#install.packages("VennDiagram")
library(VennDiagram) 
venn.diagram(x = list(one, two, three), 
             fill = c("lightblue", "green", "blue"),
             alpha = c(0.5, 0.5, 0.5), category = rep("", 3), 
             filename = "VennDiagram.svg", imagetype = "svg", height = 10, width = 10)
## why the heck isn't it proportional?!

#install.packages('eulerr')
library(eulerr)
plot(venn(list(one = unique(one), two = unique(two), three = unique(three))))
plot(euler(list(one = unique(one), two = unique(two), three = unique(three))))
plot(euler(list(four = unique(four), five = unique(five), six = unique(six))))
plot(euler(list(allSDS = allSDS, allnoSDS = allnoSDS)))
plot(euler(list(coreSDS = coreSDS, corenoSDS = corenoSDS)))
plot(euler(list(one = unique(one), two = unique(two), three = unique(three), 
                four = unique(four), five = unique(five), six = unique(six))))

diamond <- read.delim("EveGHHK01_and_contam.diamond.tsv", header = F, stringsAsFactors = F)

found.proteins <- data.frame(Accession = found, Annotation = NA)
found.proteins$Accession <- as.character(found.proteins$Accession)
found.proteins$Annotation <- sapply(found.proteins$Accession, function(x) diamond[diamond$V1 == x, "V14"])


samples5152 <- merge(sample51, sample52, by = "Main Accession", all = TRUE)
samples6162 <- merge(sample61, sample62, by = "Main Accession", all = TRUE)
samples5 <- merge(samples5152, sample53, by = "Main Accession", all = TRUE)
samples6 <- merge(samples6162, sample63, by = "Main Accession", all = TRUE)
allsamples <- merge(samples5, samples6, by = "Main Accession", all = TRUE)