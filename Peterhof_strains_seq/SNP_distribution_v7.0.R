setwd("/media/drozdovapb/big/Peterhof_strains_seq/SNPs/")


library(gridExtra)
library(ggplot2)
library(GenomicRanges)



chromosome.length.df <- read.table('../Reference/S288c.sizes', as.is=TRUE)
fifteen.df <- read.table('../NEW_SNPS/15V.snps.indels.vcf', as.is=TRUE)
#fifteen.df <- read.table('../NEW_SNPS/15V.snps.no-rep.vcf', as.is=TRUE) #not much difference
twentyfive.df <- read.table('../NEW_SNPS/25b.snps.indels.vcf', as.is=TRUE)
oneb.df <- read.table('../NEW_SNPS/1B.snps.indels.vcf', as.is=TRUE)
seventyfour.df <- read.table('../NEW_SNPS/74.snps.indels.vcf', as.is = TRUE)
twentyfive.diff.df <- read.table('../NEW_SNPS/Difference/25b.and.15V.vcf', as.is=TRUE)
oneb.diff.df <- read.table('../NEW_SNPS/Difference/1B.and.15V.vcf', as.is=TRUE)
seventyfour.diff.df <- read.table('../NEW_SNPS/Difference/74.and.15V.vcf', as.is = TRUE)
sixp.df <- read.table('../NEW_SNPS/6P.snps.indels.vcf', as.is = TRUE)
sixp.diff.df <- read.table('../NEW_SNPS/Difference/6P.and.15V.vcf', as.is = TRUE)

#Build object
yeast.seqinfo <- Seqinfo(seqnames=chromosome.length.df$V1,
                         seqlengths=chromosome.length.df$V2,
                         isCircular=rep(FALSE, nrow(chromosome.length.df)),
                         genome='yeast')
chromosome.ranges <- GRanges(seqnames=chromosome.length.df$V1,
                             ranges=IRanges(start=rep(1, nrow(chromosome.length.df)), end=chromosome.length.df$V2), seqinfo=yeast.seqinfo)



#function 
count <- function(snv.df) {
    snv.ranges <- GRanges(seqnames=snv.df$V1,
                          ranges=IRanges(start=snv.df$V2, end=snv.df$V2),
                          seqinfo=yeast.seqinfo)
    windows <- GRanges(seqinfo=yeast.seqinfo)
    window.size <- 1000
    for (i in 1:nrow(chromosome.length.df)) {
        chr.name <- chromosome.length.df$V1[i]; chr.length <- chromosome.length.df$V2[i]
                temp <- GRanges(seqnames=chr.name,
                        ranges=IRanges(start=seq(1, chr.length-window.size, by=window.size), width=window.size),
                        seqinfo=yeast.seqinfo)
        last.position <- end(temp)[length(temp)]
        last.interval <- GRanges(seqnames=chr.name,
                                 ranges=IRanges(start=last.position + 1,
                                                end=chr.length),
                                 seqinfo=yeast.seqinfo)
        temp <- c(temp, last.interval)
        windows <- c(windows, temp)    }
    window.snv.counts <- countOverlaps(windows, snv.ranges)
    snv.density <- window.snv.counts / width(windows)
    snv.count <- cbind(1:length(windows), snv.density)
    borders <- cumsum(chromosome.length.df$V2)
    starts1 <- start(windows); starts <- start(windows)
    seqs <- as.vector(seqnames(windows))
    bords <- cbind(chromosome.length.df, c(0, borders[-17]))
    for (i in 1:length(starts)) {
            starts1[i] <- starts1[i] + as.numeric(bords[bords[,1]==seqs[i],][3]) } 
    seqs <- factor(x = seqs, levels = c("I", "II", "III", "IV", "V",
                     "VI", "VII", "VIII", "IX", "X", 
                     "XI", "XII", "XIII", "XIV", "XV", "XVI", "Mito"))
    
    res <- data.frame(starts1, window.snv.counts, starts, seqs)
    #res$starts1 <- as.numeric(res$starts1); res$starts <- as.numeric(res$starts)
    #res$window.snv.counts <- as.numeric(res$window.snv.counts)
    
    return(res)}


plot_dist <- function(obj, mytitle = "strain"){
    #win.size <- as.numeric(obj$starts[2] - obj$starts[1])
    #xlims <- table(obj$seqs)*5000
    pl <- ggplot(data = obj) + 
        geom_line(aes(x = as.numeric(starts), y = as.numeric(window.snv.counts), group = seqs), 
                  col = "green4", alpha=.8) +
        #ylim(c(0,25)) +
        #xlim(c(-10**4,1542000)) +
        #xlim(c(0, 1531933 + 1)) + #max number of windows (number of windows on chrIV + 1)
        facet_grid(. ~ seqs, space = "free_x", scales = "free") + #drop = T, shrink = T) +
        #scale_x_continuous(breaks = seq(0, 1542000, by=5 * 10^5)) +
        scale_x_continuous(breaks = seq(0, 1542000, by=5 * 10^5)) +
        xlab("") + ylab("SNVs per window") + 
        ggtitle(mytitle) +
        #facet_wrap(~ seqs, nrow=1, drop = T) +
#        geom_vline(xintercept = borders , colour = 'grey', linetype = "longdash") +
        theme_bw() +
        theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())
        #theme(axis.text.x = element_text(angle = 45, hjust = 1))
    print(pl)
}


plot_dist <- function(obj, mytitle = "strain"){
    pl <- ggplot(data = obj) + 
        geom_line(aes(x = as.numeric(starts), y = as.numeric(window.snv.counts), group = seqs), 
                  col = "green4", alpha=.8) +
        facet_grid(. ~ seqs, space = "free_x", scales = "free") + 
        scale_x_continuous(breaks = seq(0, 1542000, by=5 * 10^5)) +
        xlab("") + ylab("SNVs per window") + 
        ggtitle(mytitle) +
        theme_bw() +
        theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())
    print(pl)}


plot_diff <- function(obj, obj2, mytitle = "strain"){
    obj$counts.2 <- - obj2[,2]
    pl <- ggplot(data = obj, aes(x = starts, y = window.snv.counts)) + 
        geom_line(aes(x = as.numeric(starts), y = as.numeric(window.snv.counts), group = seqs), 
                  col = "green4", alpha=.8) +
        geom_line(aes(x = as.numeric(starts), y = as.numeric(counts.2), group = seqs), 
                  col = "darkviolet", alpha=.8) +
        facet_grid(. ~ seqs, space = "free_x", scales = "free") + 
        scale_x_continuous(breaks = seq(0, 1542000, by=5 * 10^5)) +
        xlab("") + ylab("SNVs per 1kb") + 
        ggtitle(mytitle) +
        theme_bw() +
        labs(x = NULL) +
        theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())
    print(pl)
return(pl)}

#testing
fift_c <- count(fifteen.df)
plot_dist(fift_c, mytitle = "15V-P4")


#now difference

twentyfive_nonPet_c <- count(twentyfive.diff.df)
oneb_nonPet_c <- count(oneb.diff.df)
seventyfour_nonPet_c <- count(seventyfour.diff.df)
sixp_nonPet_c <- count(sixp.diff.df)

twentyfive_c <- count(twentyfive.df)
oneb_c <- count(oneb.df)
seventyfour_c <- count(seventyfour.df)
sixp_c <- count(sixp.df)

plot_dist(fift_c)
plot_dist(twentyfive_c)

tf_diff <- plot_diff(twentyfive_c, twentyfive_nonPet_c, mytitle = "25-25-2V-P3982")
ob_diff <- plot_diff(oneb_c, oneb_nonPet_c, mytitle = "1B-D1606")
sf_diff <- plot_diff(seventyfour_c, seventyfour_nonPet_c, mytitle = "74-D694")
sp_diff <- plot_diff(sixp_c, sixp_nonPet_c, mytitle = "6P-33G-D373")

svg("2015-10-23-15V.svg", width = 6.75, height = 3)
plot_dist(fift_c, mytitle = "15V-P4")
dev.off()

#svg("2015-10-23-hybrid_strains.svg", width = 6.75)#, height = 4)
svg("2015-11-23-hybrid_strains.svg", width = 6.75)#, height = 4)
#grid.arrange(tf_diff, ob_diff, sf_diff)
grid.arrange(tf_diff, ob_diff, sf_diff, sp_diff, ncol = 1)
dev.off()

