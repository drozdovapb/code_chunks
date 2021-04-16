library(readxl)
library(ggplot2)
library(openxlsx)
#install.packages("UpSetR")
library("UpSetR")


## read the data
sample51 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_1_Default Protein Report.xls")
sample52 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_2_Default Protein Report.xls")
sample53 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_3_Default Protein Report.xls")

sample61 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_1_Default Protein Report.xls")
sample62 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_2_Default Protein Report.xls")
sample63 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_3_Default Protein Report.xls")

## number of identified proteins
plot(c(nrow(sample51), nrow(sample52), nrow(sample53), nrow(sample61), nrow(sample62), nrow(sample63)),
     col = c(1,1,1,2,2,2), ylim = c(0, 900), las = 1, ylab = "Number of proteins", pch = 19)


##upset?


listNames <- list(one = sample51$`Main Accession`, two = sample52$`Main Accession`, three = sample53$`Main Accession`,
                  four = sample61$`Main Accession`, five = sample62$`Main Accession`, six = sample63$`Main Accession`)
upset(fromList(listNames), 
      intersections = list(list("one", "two", "three", "four", "five", "six"), 
                         list("one", "two", "three"), list("four", "five", "six"),
      list("one"), list("two"), list("three"), list("four"), list("five"), list("six")), keep.order = T)

## these are the proteins found in each sample. The core proteome, if you wish.
#found <- list(Reduce(intersect, listNames))[[1]]

found <- list(Reduce(union, listNames))[[1]]
#allfound <- sapply(found[[1]], FUN = function(x) {strsplit(x, "|", fixed = T)[[1]][1]})
writeLines(found, "all_found_proteins.txt")


one <- sample51$`Main Accession`
two <- sample52$`Main Accession`
three <- sample53$`Main Accession`
four <- sample61$`Main Accession`
five <- sample62$`Main Accession`
six <- sample63$`Main Accession`

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

## Transmembrane
## TODO: put here back all the commands to run TMHMM etc

tm_vect <- readLines("Fig2A_proteins_with_TMHs_ids.txt")

sample51$shortnames <- gsub("(+)", "", gsub(".1|:", "1", gsub("-", "", gsub("(-)", "", sample51$`Main Accession`,
                                              fixed = T), fixed = T), fixed = T), fixed = T)
sample52$shortnames <- gsub("(+)", "", gsub(".1|:", "1", gsub("-", "", gsub("(-)", "", sample52$`Main Accession`,
                                              fixed = T), fixed = T), fixed = T), fixed = T)
sample53$shortnames <- gsub("(+)", "", gsub(".1|:", "1", gsub("-", "", gsub("(-)", "", sample53$`Main Accession`,
                                              fixed = T), fixed = T), fixed = T), fixed = T)
sample61$shortnames <- gsub("(+)", "", gsub(".1|:", "1", gsub("-", "", gsub("(-)", "", sample61$`Main Accession`,
                                              fixed = T), fixed = T), fixed = T), fixed = T)
sample62$shortnames <- gsub("(+)", "", gsub(".1|:", "1", gsub("-", "", gsub("(-)", "", sample62$`Main Accession`,
                                              fixed = T), fixed = T), fixed = T), fixed = T)
sample63$shortnames <- gsub("(+)", "", gsub(".1|:", "1", gsub("-", "", gsub("(-)", "", sample63$`Main Accession`,
                                              fixed = T), fixed = T), fixed = T), fixed = T)


tm_vect_short <- gsub("_", "", tm_vect)

tm51 <- sum(sapply(tm_vect_short, function(x) sum(grepl(x, sample51$shortnames))))
tm52 <- sum(sapply(tm_vect_short, function(x) sum(grepl(x, sample52$shortnames))))
tm53 <- sum(sapply(tm_vect_short, function(x) sum(grepl(x, sample53$shortnames))))
tm61 <- sum(sapply(tm_vect_short, function(x) sum(grepl(x, sample61$shortnames))))
tm62 <- sum(sapply(tm_vect_short, function(x) sum(grepl(x, sample62$shortnames))))
tm63 <- sum(sapply(tm_vect_short, function(x) sum(grepl(x, sample63$shortnames))))

TMs <- data.frame(
  sample = c("5.1", "5.2", "5.3", "6.1", "6.2", "6.3"),
  Nprots = c(nrow(sample51), nrow(sample52), nrow(sample53), nrow(sample61), nrow(sample62), nrow(sample63)),
  NTMs = c(tm51, tm52, tm53, tm61, tm62, tm63),
  SDS = c(rep("SDS", 3), rep("no SDS", 3)))

TMs$noTM <- TMs$Nprots - TMs$NTMs
# TMs$TM.percent <- TMs$NTMs / TMs$Nprots * 100
# TMs$noTM.percent <- (TMs$Nprots - TMs$NTMs) / TMs$Nprots * 100

library(reshape2)
TMs.melt <- melt(TMs, id.vars = c("sample", "SDS", "Nprots"), 
                 variable.name = "Presence of TM domain", value.name = "Number of proteins")
TMs.melt$prop <- TMs.melt$`Number of proteins` / TMs.melt$Nprots * 100

ggplot(TMs.melt, aes(x = sample, y = prop, fill = `Presence of TM domain`)) + 
  geom_bar(stat = "identity") +
  ylab("% of the total proteins") + 
  geom_text(aes(label = `Number of proteins`), position = position_stack(vjust = 0.5)) + 
  theme_classic(base_size = 16)
ggsave("Fig2A_tm_percent.svg", width = 7, height = 3)

TMs$Present.in.SDS <- sapply(TMs$`Protein ID`, function(x) sum(grepl(x, sample10$shortnames), grepl(x, sample11$shortnames), grepl(x, sample12$shortnames)))
TMs$Present.in.no.SDS <- sapply(TMs$`Protein ID`, function(x) sum(grepl(x, sample20$shortnames), grepl(x, sample21$shortnames), grepl(x, sample22$shortnames)))

## add transmembrane!! 
# TMs <- read.csv("all_found_proteins.tmhmm.csv", head = F, sep = " ", stringsAsFactors = F)
# found.proteins$shortnames <- gsub("(+)", "", gsub("1|:", "", gsub("-", "", gsub("(-)", "", found.proteins$Accession, 
#                                                                                 fixed = T), fixed = T), fixed = T), fixed = T)
# 
# diamond$shortnames <- gsub("(+)", "", gsub("|:", "", gsub("-", "", gsub("(-)", "", diamond$V1, 
#                                                                                 fixed = T), fixed = T), fixed = T), fixed = T)
# 
# TMs$Annotation <- sapply(TMs$V2, function(x) diamond[diamond$shortnames == x, "V14"])
# 
# TMs <- TMs[ , c("V2", "V8", "Annotation")]
# names(TMs) <- c("Protein ID", "Number of TM domains", "Annotation")
# 
# TMs$Main.Accession <- gsub("\\..*", "", TMs$`Protein ID`)


TMs$Present.in.SDS <- sapply(TMs$`Protein ID`, function(x) sum(grepl(x, sample10$shortnames), grepl(x, sample11$shortnames), grepl(x, sample12$shortnames)))
TMs$Present.in.no.SDS <- sapply(TMs$`Protein ID`, function(x) sum(grepl(x, sample20$shortnames), grepl(x, sample21$shortnames), grepl(x, sample22$shortnames)))


write.xlsx(found.proteins, "all_found_proteins_wmod.xlsx")

