options(stringsAsFactors = F)
###read the protein groups


#######This is to be done only once###########

#proteinGroups <- read.delim("proteinGroups_with_sums.csv")
#goodProteins <- proteinGroups[proteinGroups$Peptides > 1 &
#                                proteinGroups$Only.identified.by.site == "" & 
#                                proteinGroups$Potential.contaminant ==  "" & 
#                                proteinGroups$Reverse ==  "" ,]
#write.table(goodProteins, "994_proteinGroups_with_sums.csv", sep = "\t", row.names = F)

### now we have 994 protein groups. 

allwithsums <- read.delim("../data/994_proteinGroups_with_sums.csv", stringsAsFactors = F)
keep <- grepl("sum", names(allwithsums)) | grepl("Protein.IDs", names(allwithsums))
sums <- allwithsums[ , keep]

##and we have Panther results!!!

## this is with one best match for each
panther <- read.delim("../data/EcyBCdTP1_cor_renamed_found_names.txt", head = F, stringsAsFactors = F)
## 2489 out of 2563. Not bad, I would say. 


#sums$panther.family <- ""

#panther$family <- sapply(panther$V2, function(x) {unlist(strsplit(x, ":"))[1]})
  
#for (i in 1:nrow(sums)) {
#  for (j in 1:nrow(panther)) {
#    if (grepl(panther$V1[j], sums$Protein.IDs[i], fixed = T))
#      if (sums$panther.family[i] == "" | sums$panther.family[i] == panther$family[j]) {
#        sums$panther.family[i] <- panther$family[j]  
#      } else {sums$panther.family[i] <- paste0(sums$panther.family[i], ", ", panther$family[j])}
#      
#  }
#}

#sums$panther.subfamily <- ""
#for (i in 1:nrow(sums)) {
#  for (j in 1:nrow(panther)) {
#    if (grepl(panther$V1[j], sums$Protein.IDs[i], fixed = T))
#      if (sums$panther.subfamily[i] == "" | sums$panther.subfamily[i] == panther$V2[j]) {
#        sums$panther.subfamily[i] <- panther$V2[j]  
#      } else {sums$panther.subfamily[i] <- paste0(sums$panther.subfamily[i], ", ", panther$V2[j])}
    
#  }
#}

#head(sums)

#write.csv(sums, "sums_with_panther_families.csv")
## the code above is also preferably only run once



#head(sums)

sums <- read.csv("../data/sums_with_panther_families.csv")

sumcols <- grep("sum", names(sums))

sums$fabundance <- rowSums(sums[,c("sum_FK_E", "sum_FK_F" , "sum_FK_G", "sum_FK_H")]) / 4
sums$mabundance <- rowSums(sums[,c("sum_MK_N", "sum_MK_O" , "sum_MK_P")]) / 3



panther_base <- read.delim("../data/panther_families.tsv", head = F)

## not the best solution but still
sums$panther.fam.name <- sapply(sums$panther.family, 
                      function(x) {panther_base[panther_base$V1 == x, "V2"][1]})

##I need more general information
sumsn$panther.category <- sapply(sumsn$panther.family, 
                                 function(x) {panther_base[panther_base$V1 == x, "V6"][1]})
##what if go terms?
sumsn$panther.go <- sapply(sumsn$panther.family, 
                                 function(x) {panther_base[panther_base$V1 == x, "V5"][1]})


write.csv(sums, "../data/sums_with_panther_families_names.csv")


sums <- read.csv("../data/sums_with_panther_families.csv")

sumcols <- c(grep("sum", names(sums)), grep("abundance", names(sums)), 
             grep("panther.family", names(sums)))
sumsn <- sums[, sumcols]

f <- aggregate( . ~ panther.family, sumsn, FUN=sum)
head(f[order(f$fabundance, decreasing = T), ], 15)


m <- aggregate(sums$mabundance, by=list(sums$panther.family, sums$panther.fam.name), FUN=sum)
head(m[order(m$x, decreasing = T), ], 15)

# f <- aggregate(sums$fabundance, by=list(sums$panther.family, sums$panther.fam.name), FUN=sum)
# head(f[order(f$x, decreasing = T), ], 15)
# 
# m <- aggregate(sums$mabundance, by=list(sums$panther.family, sums$panther.fam.name), FUN=sum)
# head(m[order(m$x, decreasing = T), ], 15)


## top 20 female proteins for plotting
f$percentfabundance <- f$fabundance / sum(f$fabundance)* 100
f$percentFK_E <- f$sum_FK_E / sum(f$sum_FK_E) * 100
f$percentFK_F <- f$sum_FK_F / sum(f$sum_FK_F) * 100
f$percentFK_G <- f$sum_FK_G / sum(f$sum_FK_G) * 100
f$percentFK_H <- f$sum_FK_H / sum(f$sum_FK_H) * 100

toplotf <- (head(f[order(f$fabundance, decreasing = T), ], 11)) ##approx. 71%, each over 1%
toplotf$family <- factor(toplotf$panther.family, levels = rev(toplotf$panther.family))


## Part of Fig. 3 actually
fplot <- 
  ggplot(toplotf, aes(y = percentfabundance, x = family)) + 
  stat_summary_bin(fun.y = "median", geom = "bar", alpha=.8, col = "transparent", fill = "#FF00FF") + 
  geom_point(aes(y = percentFK_E), cex = 1, alpha=.5, color = "#990099", position = position_jitter(width = 0, h = 0)) +
  geom_point(aes(y = percentFK_F), cex = 1, alpha=.5, color = "#990099", position = position_jitter(width = 0, h = 0)) + 
  geom_point(aes(y = percentFK_G), cex = 1, alpha=.5, color = "#990099", position = position_jitter(width = 0, h = 0)) + 
  geom_point(aes(y = percentFK_H), cex = 1, alpha=.5, color = "#990099", position = position_jitter(width = 0, h = 0)) + 
  theme_bw(base_size = 16) + coord_flip() + 
  xlab("Protein family") + ylab("% of the total intensity in the sample")



##and top male proteins for plotting
f$percentmabundance <- f$mabundance / sum(f$mabundance)* 100
f$percentMK_N <- f$sum_MK_N / sum(f$sum_MK_N) * 100
f$percentMK_O <- f$sum_MK_O / sum(f$sum_MK_O) * 100
f$percentMK_P <- f$sum_MK_P / sum(f$sum_MK_P) * 100

toplotm <- (head(f[order(f$mabundance, decreasing = T), ], 14)) ##approx. 71%, each over 1%
toplotm$family <- factor(toplotm$Group.1, levels = rev(toplotm$Group.1))

## Part of Fig. 3 actually
mplot <- 
  ggplot(toplotm, aes(y = percentmabundance, x = family)) + 
  stat_summary_bin(fun.y = "median", geom = "bar", alpha=.8, col = "transparent", fill = "#0072b2") + 
  geom_point(aes(y = percentMK_O), cex = 1, alpha=.5, color = "#005555", position = position_jitter(width = 0, h = 0)) +
  geom_point(aes(y = percentMK_P), cex = 1, alpha=.5, color = "#005555", position = position_jitter(width = 0, h = 0)) + 
  geom_point(aes(y = percentMK_N), cex = 1, alpha=.5, color = "#005555", position = position_jitter(width = 0, h = 0)) + 
  theme_bw(base_size = 16) + coord_flip() + 
  xlab("Protein family") + ylab("% of the total intensity in the sample")

pp <- grid.arrange(mplot, fplot, heights = c(12/22, 10/22))
ggsave(plot = pp, filename = "../figures/fm_top.svg", device = "svg", 
       width = 20, height = 20, units = "cm")

## some of groups do not have proper names. Let's use the name of the largest subfamily
f <- aggregate(sums$fabundance, by=list(sums$panther.subfamily, sums$panther.fam.name), FUN=sum)
head(f[order(f$x, decreasing = T), ], 20)


##and the same thing for males
m <- aggregate(sums$mabundance, by=list(sums$panther.family, sums$panther.fam.name), FUN=sum)
View(head(m[order(m$x, decreasing = T), ], 20))

m <- aggregate(sums$fabundance, by=list(sums$panther.subfamily, sums$panther.fam.name), FUN=sum)
View(head(m[order(f$x, decreasing = T), ], 30))




######
sumsn <- read.csv("../data/sums_with_panther_families_names.csv")
sumsn <- read.csv("../data/all_DE_protein_with_sums_and_manual_annotation.csv")

library(openxlsx)
fmco <- read.xlsx("../data/DE/proteinGroups_males_vs_females_control_only_in_one.xlsx", sheet = 1)
fmcs <- read.xlsx("../data/DE/proteinGroups_males_vs_females_control_signif.xlsx", sheet = 1)
#at least let's get panther names. I'm not quite sure we need all the tables. We can go with one table with intensities and data on difference (add 1's)

## female better
fem_only <- c(fmco[fmco$gr2only, "Protein.IDs"], fmcs[fmcs$logFC > 0, "Protein.IDs"])

fem_panther <- sumsn[sumsn$Protein.IDs %in% fem_only, ]
#166 protein groups
#and then we just need the protein names, right? 
#sort(table(fem_panther$panther.family))
fem_panther_table <- table(fem_panther$panther.family)
sort(fem_panther_table[fem_panther_table > 1])
##what if category? and just search by all categories
sort(table(unlist(strsplit(fem_panther$panther.category, ";"))))
sort(table(unlist(strsplit(fem_panther$panther.go, ";"))))

fem_panther_table <- table(fem_panther$manual)
View(sort(fem_panther_table))

## male better
male_only <- c(fmco[fmco$gr1only, "Protein.IDs"], fmcs[fmcs$logFC < 0, "Protein.IDs"])
male_panther <- sumsn[sumsn$Protein.IDs %in% male_only, ]
View(male_panther)

male_panther_table <- table(male_panther$panther.family)
sort(male_panther_table[male_panther_table > 1])
table(male_panther$panther.family)

sort(table(unlist(strsplit(male_panther$panther.category, ";"))))
sort(table(unlist(strsplit(male_panther$panther.go, ";"))))


##female heat shock
fhc <- read.xlsx("../data/DE/proteinGroups_females_control_vs_HS_only_in_one.xlsx")

##upregs
fhc_up <- fhc[fhc$gr1only, "Protein.IDs"]
fhc_up_panther <- sumsn[sumsn$Protein.IDs %in% fhc_up, ]
sort(table(fhc_up_panther$panther.fam.name))
sort(table(unlist(strsplit(fhc_up_panther$panther.category, ";"))))

sort(table(fhc_up_panther$manual))

#downregs
fhc_down <- fhc[fhc$gr2only, "Protein.IDs"]
fhc_down_panther <- sumsn[sumsn$Protein.IDs %in% fhc_down, ]
sort(table(fhc_down_panther$panther.fam.name))
sort(table(fhc_down_panther$manual))
sort(table(unlist(strsplit(fhc_down_panther$panther.category, ";"))))



mhc <- read.xlsx("../data/DE/proteinGroups_males_control_vs_HS_only_in_one.xlsx")

##upregs
mhc_up <- mhc[mhc$gr1only, "Protein.IDs"]
mhc_up_panther <- sumsn[sumsn$Protein.IDs %in% mhc_up, ]
sort(table(mhc_up_panther$manual))

#downregs
mhc_down <- mhc[mhc$gr2only, "Protein.IDs"]
mhc_down_panther <- sumsn[sumsn$Protein.IDs %in% mhc_down, ]
sort(table(mhc_down_panther$manual))


mf <- read.csv("../data/male_vs_female_for_fig_only.csv")
library(ggplot2)
ggplot(mf, aes(x=group, y = Number_of_protein_groups)) + 
  coord_flip() + 
  geom_bar(stat = "identity") + 
  theme_bw() + 
  facet_grid(~sex)

###########
## you can just start from here
library(openxlsx)
library(ggplot2)
mf2 <- read.xlsx("../data/For_Figs_4-5.xlsx")
library(reshape2)
mf3 <- dcast(mf2, formula =comparison ~ manual_function_num)
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
mf4a$variable <- droplevels(mf4a$variable)
            ##finish this
mf4a <- mf4a[mf4a$value > 0, ]

fhc <- mf4a[mf4a$comparison %in% c("fhs_up", "fhs_down"), ]

ggplot(fhc, aes(x=variable, y = value)) + 
  coord_flip() + 
  scale_x_discrete(limits = rev(levels(fhc$variable))) +
  geom_bar(stat = "identity") + 
  theme_bw() + ylim(0, 5) +
  facet_grid(~comparison)

ggsave("../figures/fig5a.svg", width = 18, height = 9, units = "cm")


mhc <- mf4a[mf4a$comparison %in% c("mhs_up", "mhs_down"), ]

ggplot(mhc, aes(x=variable, y = value)) + 
  coord_flip() + 
  scale_x_discrete(limits = rev(levels(mhc$variable))) +
  geom_bar(stat = "identity") + 
  theme_bw() + ylim(0, 5) +
  facet_grid(~comparison)


ggsave("../figures/fig5b.svg", width = 18, height = 9, units = "cm")
