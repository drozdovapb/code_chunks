options(stringsAsFactors = F)
library(ggplot2)
library(openxlsx)

# dat <- read.xlsx("Table_S1a_all_found_proteins_with_panther.tsv", head = F)
# # dat2 <- sapply(dat$V3, function(x) strsplit(x, ";"))
# # dat3 <- sapply(dat2, function(x) x[1])
# # ## get families
# # dat4 <- sapply(names(dat3), function(x) strsplit(x, ":"))
# # dat5 <- sapply(dat4, function(x) x[2])
# # 
# # tail(sort(table(dat5))
# 
# ## Stupid! Families were available in V2
# dat$V2
# tail(sort(table(dat$V2)))
# names(dat) <- c("Accession_underscore", "Panther.Family", "Panther.Info")

# quant <- read.xlsx("Table_S1_Abundance_MW_pI.xlsx")
# quant$Percent.Quantity <- quant$Total.Quantity / sum(quant$Total.Quantity) * 100
# quant.with.panther <- merge(quant, dat, by = "Accession_underscore", all = TRUE)
<<<<<<< HEAD

=======

## merging code
# library(openxlsx)
# options(stringsAsFactors = F)
# 
# wpanther <- read.delim("Table_S1a_all_found_proteins_with_panther.tsv", head = F)
# withmwpi <- read.xlsx("Table_S1_Abundance_MW_pI.xlsx")
# 
# names(wpanther) <- c("Accession_underscore", "Panter_class", "Panther_GO")
# wall <- merge(wpanther, withmwpi, all = T)
# 
# wall <- wall[order(wall$`%.Quantity`, decreasing = T), ]
# 
# write.xlsx(wall, file = "Table_S1_Abundance_MW_pI_upd.xlsx")


>>>>>>> 1e76151c0a7fd333de247b91be631c87354de277
quant.with.panther <- read.xlsx("Table_S1_Abundance_MW_pI_upd.xlsx")
## at least three proteins...
atleast5 <- names(table(quant.with.panther$Panther.Family)[table(quant.with.panther$Panther.Family) > 5])
quant.with.panther.atleast5 <- quant.with.panther[quant.with.panther$Panther.Family %in% atleast5, ]


ggplot(quant.with.panther.atleast5, aes(x = reorder(Panther.Family, Percent.Quantity), y = Percent.Quantity),
       color = "black", fill = "white") + 
  geom_bar(stat = "identity") + 
  theme_bw(base_size = 16) + 
  coord_flip() +
  xlab("Panther family") + ylab("% Intensity") #+ 
  #theme(axis.text.x = element_text(angle = 90)) 
ggsave("Fig2B_functional_classification_draft.svg", width = 4, height = 4)

## % for each group
aggregate(quant.with.panther.atleast5$Percent.Quantity ~ quant.with.panther.atleast5$Panther.Family, FUN = sum)
### TODO SAVE