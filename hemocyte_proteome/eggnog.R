library(openxlsx)

tableS1 <- read.xlsx("Table_S1_Abundance_MW_pI_upd_peptides_upd_TM.xlsx")

eggnog.annot <- read.delim("all_found_proteins_eggnog.annotations", skip = 4, header = F)[ ,c(1,7)]
#nameseggnog.annot <- readLines("all_found_proteins_eggnog.annotations")[4]
#names(eggnog.annot)[1:17] <- unlist(strsplit(namesTableS1, split = "\t"))
names(eggnog.annot) <- c("Accession_underscore", "GOs")

tableS1 <- merge(tableS1, eggnog.annot, all.x = TRUE)

write.xlsx(tableS1, "Table_S1_Abundance_MW_pI_upd_peptides_upd_TM_upd_eggnog.xlsx")


library(fgsea)
go_terms <- subset(eggnog.annot, V6 != '') # remove rows which do not contain gene name
GOs <- strsplit(as.character(go_terms$V7), ',') # extract GO terms (this is gene2GO list)
