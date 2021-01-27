library(openxlsx)
options(stringsAsFactors = F)

wpanther <- read.delim("Table_S1a_all_found_proteins_with_panther.tsv", head = F)
withmwpi <- read.xlsx("Table_S1_Abundance_MW_pI.xlsx")

names(wpanther) <- c("Accession_underscore", "Panter_class", "Panther_GO")
wall <- merge(wpanther, withmwpi, all = T)

wall <- wall[order(wall$`%.Quantity`, decreasing = T), ]

write.xlsx(wall, file = "Table_S1_Abundance_MW_pI_upd.xlsx")
