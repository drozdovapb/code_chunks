###########
## you can just start from here
library(openxlsx)
library(ggplot2)
mf2 <- read.xlsx("../data/For_Figs_4-5.xlsx")
library(reshape2)
#this is with the numbers for 'functionally' 
#mf3 <- dcast(mf2, formula = comparison ~ manual_function_num)
mf3 <- dcast(mf2, formula = comparison ~ manual_function_upd) 
mf4 <- melt(mf3)

mf5 <- mf4[mf4$comparison %in% c("females", "males"), ]
mf5$variable <- droplevels(mf5$variable)

## at least 2 proteins? 
mf5 <- mf5[mf5$value > 0,]

ggplot(mf5, aes(x=variable, y = value, fill = comparison)) + 
  coord_flip() + 
  scale_x_discrete(limits = rev(levels(mf5$variable))) +
  geom_bar(stat = "identity") + 
  theme_bw() + 
  facet_grid(~comparison)


ggsave("../figures/fig4c.svg", width = 28, height = 9, units = "cm")

## levels? 
mf4a <- mf4[mf4$comparison  %in% c("fhs_up", "fhs_down", "mhs_up", "mhs_down"), ]
## As Stefan suggested: sort by the frequency
freq <- aggregate(mf4a$value ~ mf4a$variable, FUN = sum)
newlevs <- as.character(freq[order(freq$"mf4a$value"), "mf4a$variable"])
mf4a$group <- factor(mf4a$variable, levels = newlevs)

mf4a$variable <- droplevels(mf4a$variable)
##finish this
mf4a <- mf4a[mf4a$value > 0, ]

fhc <- mf4a[mf4a$comparison %in% c("fhs_up", "fhs_down"), ]

ggplot(fhc, aes(x=variable, y = value)) + 
  coord_flip() + 
  scale_x_discrete(limits = levels(fhc$group)) +
  geom_bar(stat = "identity") + 
  theme_bw() + ylim(0, 5) +
  geom_vline(xintercept = 11.5, linetype = "dotted") + 
  facet_grid(~comparison)

ggsave("../figures/fig5a_new.svg", width = 18, height = 9, units = "cm")


mhc <- mf4a[mf4a$comparison %in% c("mhs_up", "mhs_down"), ]

ggplot(mhc, aes(x=variable, y = value)) + 
  coord_flip() + 
  scale_x_discrete(limits = rev(levels(mhc$variable))) +
  geom_bar(stat = "identity") + 
  theme_bw() + ylim(0, 5) +
  geom_vline(xintercept = 11.5, linetype = "dotted") + 
  facet_grid(~comparison)


ggsave("../figures/fig5b_new.svg", width = 18, height = 9, units = "cm")
