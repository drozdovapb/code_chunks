options(stringsAsFactors = F)
library(ggplot2)
library(openxlsx)

dat <- read.delim("all_found_proteins_with_panther.tsv", head = F)
# dat2 <- sapply(dat$V3, function(x) strsplit(x, ";"))
# dat3 <- sapply(dat2, function(x) x[1])
# ## get families
# dat4 <- sapply(names(dat3), function(x) strsplit(x, ":"))
# dat5 <- sapply(dat4, function(x) x[2])
# 
# tail(sort(table(dat5))

## Stupid! Families were available in V2
dat$V2
tail(sort(table(dat$V2)))
names(dat) <- c("Accession_underscore", "Panther.Family", "Panther.Info")

quant <- read.xlsx("Table_S1_Abundance_MW_pI.xlsx")
quant$Percent.Quantity <- quant$Total.Quantity / sum(quant$Total.Quantity) * 100

quant.with.panther <- merge(quant, dat, by = "Accession_underscore", all = TRUE)
## at least three proteins...
atleast5 <- names(table(dat$Panther.Family)[table(dat$Panther.Family) > 5])
quant.with.panther.atleast5 <- quant.with.panther[quant.with.panther$Panther.Family %in% atleast5, ]


ggplot(quant.with.panther.atleast5, aes(x = reorder(Panther.Family, Percent.Quantity), y = Percent.Quantity),
       color = "black", fill = "grey") + 
  geom_bar(stat = "identity") + 
  theme_bw(base_size = 16) + 
  coord_flip() +
  xlab("Panther family") + ylab("% Intensity") + 
  #theme(axis.text.x = element_text(angle = 90)) 
ggsave("Fig2B_functional_classification_draft.svg", width = 4, height = 4)
