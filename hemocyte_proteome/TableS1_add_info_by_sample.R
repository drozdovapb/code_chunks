library(openxlsx)


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


write.xlsx(S1, "Table_S1_Abundance_MW_pI_upd_each_sample.xlsx")
