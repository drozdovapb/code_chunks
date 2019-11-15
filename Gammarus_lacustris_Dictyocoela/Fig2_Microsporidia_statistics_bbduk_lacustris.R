options(stringsAsFactors = F)
library(ggplot2)
library(reshape2)

res <- read.csv("./bbduk_results_allGla.csv")
res$Place <- factor(substr(res$X, 1, 3))
levels(res$Place) <- c("Lake 14", "Tibet")

## we only need Gla now
#res <- res[res$Species == "Gla", ]

resm <- melt(res, id.vars = c(1:3, 16), 
             variable.name = "Microsporidia_genus", value.name = "count")
resm$TPM <- resm$count / resm$X.Total * 10^6

#resm$TPM.Matched <- resm$X.Matched / resm$X.Total * 10^6
#distribution
#hist(resm$TPM.Matched, breaks = 200, col = "blue", xlab = "Read count, TPM", main = "Total microsporidian reads, TPM")
#abline(v=25, lty = 3)

hist(resm$TPM, breaks = 756, col = "blue", 
     xlab = "Read count, TPM", main = "Microsporidian reads, TPM", 
     las = 1)
     #las = 1)
abline(v=100, lty = 3)

##install.packages("plotrix")
library(plotrix)

resd <- resm[resm$Microsporidia_genus == "KM657354_Dictyocoela_berillonum", ]

png("S1_histogram.png", width = 20, height = 15, units = "cm", res = 400)
histbr <- hist(resd$TPM, breaks = 63, las=1, xlab = "Dictyocoela read count, reads per million (RPM)", 
               main = "Dictyocoela reads in RNA-seq", col = "orchid1", ylab = "Number of samples")
abline(v=50, lty=3)
dev.off()

resdLake14 <- resd[resd$Place == "Lake 14", ]
resdLake14$infected <- resdLake14$TPM > 50
table(resdLake14$infected)

## make a histogram with gapped axis
histbr <- hist(resm$TPM, breaks = 76)


png("S1_histogram.png", width = 600, height = 400, units = "px")
gap.barplot(y = histbr$counts, gap=c(6, 699), xlab="Abundance, RPM",
            ytics = c(1, 5, 700, 705), 
            las = 1, xaxt = 'n',
            xtics = histbr$breaks, ylab = "Counts", 
            main = "Abundace of microsporidian 18S rRNA", 
            col = rep("orchid1", 100))

axis(1, at = c(100, seq(0, 1400, 200)))

axis.break(axis=2, breakpos=6, pos=NULL, bgcol="white", breakcol="black",
           style="slash", brw=)

abline(v = 50, lty = 3)
dev.off()


## no, no filtering
#resm$TPM_filt <- ifelse(resm$TPM < 30, 0, resm$TPM)
#resm$TPM_filt <- ifelse(resm$TPM < 0, 0, resm$TPM)

#mycol <- scale_color_manual(values = c("#009E73", "#E69F00", "#56B4E9"),
#                   labels = c("E. verrucosus", "G. lacustris", "E. cyaneus"))

ggplot(resm, aes(x=Microsporidia_genus, y=TPM, col=Place)) + 
  coord_flip() + theme_bw(base_size = 14) + #mycol +
  geom_jitter(width = 0.2, size = 2, alpha = 0.5) +  
  scale_color_manual(values = c("#009E73","#E69F00")) + 
  scale_x_discrete(limits = rev(levels(resm$Microsporidia_genus))) + 
  geom_abline(slope = 0,intercept = 50, linetype = "dotted", col = "darkgrey") +
  ggtitle("Abundace of microsporidian 18S rRNA")

#ggsave("Gla_RNAseq.png", width = 20, height=10, units = "cm")
ggsave("Gla_RNAseq.svg", width = 30, height=15, units = "cm")
  
#ggplot(resm, aes(x=Microsporidia_genus, y=TPM_filt, fill=Species, col=Species)) + 
#  coord_flip() + theme_bw() + #mycol + 
#  geom_jitter(width = 0.1, size = .5) + facet_grid(~ Species) + scale_y_log10() #

#ggsave("Gla_RNAseq_log.png")



## cutoff?
table(res$KM657354_Dictyocoela_berillonum > 0)
table(res$KM657354_Dictyocoela_berillonum > 50)
table(res$KM657354_Dictyocoela_berillonum > 100) ## better?!
