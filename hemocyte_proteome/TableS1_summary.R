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


## these are the proteins found in each sample. The core proteome, if you wish.
#found <- list(Reduce(intersect, listNames))[[1]]
found <- list(Reduce(union, listNames))[[1]]
#allfound <- sapply(found[[1]], FUN = function(x) {strsplit(x, "|", fixed = T)[[1]][1]})

## reconstruct the details of Table S1 construction


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


dat <- read.xlsx("Table_S1_Abundance_MW_pI_upd_peptides.xlsx")
dat$TM <- dat$Accession_underscore %in% tm_vect

write.xlsx(dat, "Table_S1_Abundance_MW_pI_upd_peptides_upd_TM.xlsx")
