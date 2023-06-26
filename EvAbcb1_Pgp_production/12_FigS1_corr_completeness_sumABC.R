options(stringsAsFactors = F)
library(openxlsx) ## to read the data
library(ggplot2)
library(ggpubr) ## for stat_cor
library(ggstatsplot)

merged <- read.xlsx("./ABC_scan_results.xlsx")

## the usual ggplot way
ggplot(merged, aes(`%.Complete.BUSCOs`, SumABC)) + geom_point(aes(color = Group_2)) +
  geom_smooth(method = "lm") + stat_cor(method = "spearman") + 
  theme_bw(base_size = 14)
ggsave("12_corr_completeness_sumABC.png")

ggstatsplot::ggscatterstats(data = merged, x = `%.Complete.BUSCOs`, y = SumABC)


### even if we try to adjust, there's still correlation. Done.
#merged$SumABC.adj <- merged$SumABC / merged$`%.Complete.BUSCOs` * 100
#ggplot(merged, aes(`%.Complete.BUSCOs`, SumABC.adj)) + geom_point() +
#  geom_smooth(method = "lm") + stat_cor(method = "spearman") + 
#  theme_bw(base_size = 14)

ggplot(merged, aes(`%.Complete.BUSCOs`, ABCBF)) + geom_point(aes(color = Group_2)) +
  geom_smooth(method = "lm") + stat_cor(method = "spearman") + 
  theme_bw(base_size = 14)


good_assemblies <- merged[merged$`%.Complete.BUSCOs` > 85, ]
ggstatsplot::ggscatterstats(data = good_assemblies, x = `%.Complete.BUSCOs`, y = SumABC)
