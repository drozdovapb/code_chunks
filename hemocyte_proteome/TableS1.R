## This scripts collects all pieces of data to create Table S1.

rm(list=ls())
#############
## Packages
library(readxl) ## for xls
library(openxlsx) ## for xlsx
library(seqinr) ## for fasta input (N- / C-term completeness)
options(stringsAsFactors = F)

## Functions
extractQuantity <- function(accession, this.sample){
  as.numeric(this.sample[this.sample$`Protein Group` == accession, "Spectrum Counting"])}

calculateQuantity <- function(accession){
  sum(extractQuantity(accession, sample51),
      extractQuantity(accession, sample52),
      extractQuantity(accession, sample53),
      extractQuantity(accession, sample61),
      extractQuantity(accession, sample62),
      extractQuantity(accession, sample63), na.rm = TRUE)
}

# calculateNSDSSamples <- function(accession){
#   sum(!is.na(extractQuantity(accession, sample51)),
#       !is.na(extractQuantity(accession, sample52)),
#       !is.na(extractQuantity(accession, sample53)))
# }
# 
# calculateNnoSDSSamples <- function(accession){
#   sum(!is.na(extractQuantity(accession, sample61)),
#       !is.na(extractQuantity(accession, sample62)),
#       !is.na(extractQuantity(accession, sample63)))
# }

##############

## read the data
## SDS
sample51 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_1_Default Protein Report.xls")
sample52 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_2_Default Protein Report.xls")
sample53 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_3_Default Protein Report.xls")
## no SDS
sample61 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_1_Default Protein Report.xls")
sample62 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_2_Default Protein Report.xls")
sample63 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_3_Default Protein Report.xls")

## merge all samples sequentially ## possible but not needed
#samples5152 <- merge(sample51, sample52, by = "Main Accession", all = TRUE, suffixes = c("51", "52"))
#samples6162 <- merge(sample61, sample62, by = "Main Accession", all = TRUE, suffixes = c("61", "62"))
#samples5 <- merge(samples5152, sample53, by = "Main Accession", all = TRUE, suffixes = c("5152", "53"))
#samples6 <- merge(samples6162, sample63, by = "Main Accession", all = TRUE, suffixes = c("6162", "63"))
#allsamples <- merge(samples5, samples6, by = "Main Accession", all = TRUE, suffixes = c("5", "6"))
#names(allsamples)[1] <- "Accession"

## make a data frame with all proteins
listNames <- list(one = sample51$`Main Accession`, two = sample52$`Main Accession`, three = sample53$`Main Accession`,
                  four = sample61$`Main Accession`, five = sample62$`Main Accession`, six = sample63$`Main Accession`)
found <- list(Reduce(union, listNames))[[1]]
## Remove contaminants
found <- found[startsWith(found, "GHHK")]
S1 <- data.frame(Accession = found, Total.Quantity = NA) ##1152 proteins
S1$Accession_underscore <- gsub("[^[:alnum:] ]", "_", S1$Accession, ) ## will need it later for merging

## Add diamond-based annotation
diamond <- read.delim("Sequence_data/EveGHHK01_and_contam.diamond.tsv", header = F, stringsAsFactors = F)
S1$Annotation <- sapply(S1$Accession, function(x) diamond[diamond$V1 == x, "V14"])

## Add panther annotation
withpanther <- read.delim("Sequence_data/all_found_proteins_with_panther.tsv", head = F)
names(withpanther) <- c("Accession_underscore", "Panter_class", "Panther_GO")
S1 <- merge(S1, withpanther, all = T)


## Add quantity and which samples
S1$Total.Quantity <- sapply(S1$Accession, calculateQuantity)
## which samples
Present.in.51 <- sapply(S1$Accession, function(x) x %in% sample51$`Main Accession`)
Present.in.52 <- sapply(S1$Accession, function(x) x %in% sample52$`Main Accession`)
Present.in.53 <- sapply(S1$Accession, function(x) x %in% sample53$`Main Accession`)
Present.in.61 <- sapply(S1$Accession, function(x) x %in% sample61$`Main Accession`)
Present.in.62 <- sapply(S1$Accession, function(x) x %in% sample62$`Main Accession`)
Present.in.63 <- sapply(S1$Accession, function(x) x %in% sample63$`Main Accession`)
## how manhy replicates in each group
S1$SDS.replicates <- Present.in.51 + Present.in.52 + Present.in.53
S1$no.SDS.replicates <- Present.in.61 + Present.in.62 + Present.in.63
## SDS only
S1$SDS.only <- !(Present.in.61 | Present.in.62 | Present.in.63)



## ORF completeness, MW, and PI
seqs <- unlist(read.fasta(file = "Sequence_data/all_found_proteins.fasta", as.string = TRUE))
seqvect <- read.fasta(file = "Sequence_data/all_found_proteins.fasta")
seqs.df <- data.frame(Accession_underscore = names(seqs))
## N / C Terminus
seqs.df$N.Term.Complete <- startsWith(seqs, "m")
seqs.df$C.Term.Complete <- endsWith(seqs, "*")
## MW / pI
seqs.df$MW <- sapply(seqvect, function(x) pmw(toupper(x))/1000)
seqs.df$pI <- sapply(seqvect, function(x) computePI(toupper(x)))
## merge
S1 <- merge(S1, seqs.df)

## Peptides
S1$Peptides.in.SDS1 <- sapply(S1$Accession, function(x) sample51[sample51$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.SDS2 <- sapply(S1$Accession, function(x) sample52[sample52$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.SDS3 <- sapply(S1$Accession, function(x) sample53[sample53$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.noSDS1 <- sapply(S1$Accession, function(x) sample61[sample61$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.noSDS2 <- sapply(S1$Accession, function(x) sample62[sample62$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.noSDS3 <- sapply(S1$Accession, function(x) sample63[sample63$`Main Accession`==x, "#Peptides"])

## TM sequences
tm_vect <- readLines("Sequence_data/Fig2A_proteins_with_TMHs_ids.txt")
## play with the names again ;(
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
## add TM to Table S1
S1$TM <- S1$Accession_underscore %in% tm_vect


## add eggnog annotation
eggnog.annot <- read.delim("Sequence_data/all_found_proteins_eggnog.annotations", skip = 4, header = F)[ ,c(1,6,7,8,10,21,22)]
names(eggnog.annot) <- c("Accession_underscore", "Predicted protein name", "GOs", "EC", "KEGG_Pathway", "COG", "Eggnog description")
S1 <- merge(S1, eggnog.annot, all.x = TRUE)

##sort and output
S1 <- S1[order(S1$Total.Quantity, decreasing = T), ]
write.xlsx(S1, "TableS1_reassembled.xlsx")