library(readxl) ## for xls
library(openxlsx) ## for xlsx

## read the data
## SDS
sample51 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_1_Default Protein Report.xls")
sample52 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_2_Default Protein Report.xls")
sample53 <- read_xls("PeptideShaker_reports/E.ve_hemoc_5_sds_repeat_3_Default Protein Report.xls")
## no SDS
sample61 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_1_Default Protein Report.xls")
sample62 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_2_Default Protein Report.xls")
sample63 <- read_xls("PeptideShaker_reports/E.ve_hemoc_6_3_Default Protein Report.xls")

S1 <- read.xlsx("Table_S1_Abundance_MW_pI_upd.xlsx")

S1$Present.in.51 <- sapply(S1$Accession, function(x) x %in% sample51$`Main Accession`)
S1$Present.in.52 <- sapply(S1$Accession, function(x) x %in% sample52$`Main Accession`)
S1$Present.in.53 <- sapply(S1$Accession, function(x) x %in% sample53$`Main Accession`)
S1$Present.in.61 <- sapply(S1$Accession, function(x) x %in% sample61$`Main Accession`)
S1$Present.in.62 <- sapply(S1$Accession, function(x) x %in% sample62$`Main Accession`)
S1$Present.in.63 <- sapply(S1$Accession, function(x) x %in% sample63$`Main Accession`)

S1$Present.in.SDS.only <- !(S1$Present.in.61 | S1$Present.in.62 | S1$Present.in.63)


# samples5152 <- merge(sample51, sample52, by = "Main Accession", all = TRUE, suffixes = c("51", "52"))
# samples6162 <- merge(sample61, sample62, by = "Main Accession", all = TRUE, suffixes = c("61", "62"))
# samples5 <- merge(samples5152, sample53, by = "Main Accession", all = TRUE, suffixes = c("5152", "53"))
# samples6 <- merge(samples6162, sample63, by = "Main Accession", all = TRUE, suffixes = c("6162", "63"))
# allsamples <- merge(samples5, samples6, by = "Main Accession", all = TRUE, suffixes = c("5", "6"))
# names(allsamples)[1] <- "Accession"
# 
# S1_with_peptides <- merge(S1, allsamples, by=c("Accession"), all = TRUE, all.y = FALSE)
# 
# DF <- S1_with_peptides
# DF <- DF[ , which( !duplicated( t( DF ) ) ) ]
# 
# write.xlsx(S1, "Table_S1_Abundance_MW_pI_upd_each_sample.xlsx")
# write.xlsx(DF, "Table_S1_Abundance_peptides.xlsx")

S1$Peptides.in.51 <- sapply(S1$Accession, function(x) sample51[sample51$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.52 <- sapply(S1$Accession, function(x) sample52[sample52$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.53 <- sapply(S1$Accession, function(x) sample53[sample53$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.61 <- sapply(S1$Accession, function(x) sample61[sample61$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.62 <- sapply(S1$Accession, function(x) sample62[sample62$`Main Accession`==x, "#Peptides"])
S1$Peptides.in.63 <- sapply(S1$Accession, function(x) sample63[sample63$`Main Accession`==x, "#Peptides"])

write.xlsx(S1, "Table_S1_Abundance_MW_pI_upd_peptides.xlsx")
