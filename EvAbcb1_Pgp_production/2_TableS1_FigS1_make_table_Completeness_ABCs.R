options(stringsAsFactors = F)
library(ggplot2)
library(ggpubr)

setwd("Data/Baikal_selection_ABC/")

#mlst <- list()
summary_table <- data.frame("Species"="Test", 
                            "ABCA"=0, "ABCBF"=0, "ABCBH"=0, "ABCC"=0, "ABCD"=0, "ABCE"=0, "ABCF"=0, "ABCG"=0, "ABCH"=0)


collectStats <- function(directory) {
  setwd(directory)
  for (subdir in dir()) {
    numberrow <- nrow(summary_table) + 1
    temp <- read.csv(paste0(subdir, '/Final_ABC_table.tsv'))
    summary_table[numberrow, 1] <- subdir
    summary_table[numberrow, "ABCA"] <- length(grep("ABCA", temp$fam))
    summary_table[numberrow, "ABCBF"] <- length(grep("ABCBF", temp$fam))
    summary_table[numberrow, "ABCBH"] <- length(grep("ABCBH", temp$fam))
    summary_table[numberrow, "ABCC"] <- length(grep("ABCC", temp$fam))
    summary_table[numberrow, "ABCD"] <- length(grep("ABCD", temp$fam))
    summary_table[numberrow, "ABCE"] <- length(grep("ABCE", temp$fam))
    summary_table[numberrow, "ABCF"] <- length(grep("ABCF", temp$fam))
    summary_table[numberrow, "ABCG"] <- length(grep("ABCG", temp$fam))
    summary_table[numberrow, "ABCH"] <- length(grep("ABCH", temp$fam))
  }
  setwd("../")
  return(summary_table)
}

## run through all files
directory <- dir()[1]
summary_table <- collectStats(directory)
directory <- dir()[2]
summary_table <- collectStats(directory)
directory <- dir()[3]
summary_table <- collectStats(directory)


summary_table <- summary_table[-1, ]
summary_table$Species <- gsub(".fasta.transdecoder.pep.repr.faa", "", summary_table$Species)
summary_table$SumABC <- rowSums(summary_table[ ,2:10])


#add BUSCO
library(openxlsx)
buscos <- read.xlsx("../Table_S1_assembly_stats_and_opsins.xlsx")
#buscos$`%.Complete.BUSCOs`
buscos$Species <- gsub(" ", "_", buscos$Species)
buscos$Species <- paste0(buscos$Species, "_", tolower(buscos$Assembly.method))
buscos$Species <- gsub(" v3.13.1", "", buscos$Species)


merged <- merge(summary_table, buscos, by=c("Species"))
plot(merged$`%.Complete.BUSCOs`, merged$SumABC)

ggplot(merged, aes(`%.Complete.BUSCOs`, SumABC)) + geom_point() +
  geom_smooth(method = "lm") + stat_cor(method = "spearman") + 
  theme_bw(base_size = 14)

#install.packages("ggstatsplot")
library(ggstatsplot)
ggstatsplot::ggscatterstats(data = merged, x = `%.Complete.BUSCOs`, y = SumABC)
