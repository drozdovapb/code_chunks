#setwd("/media/drozdovapb/big/Peterhof_strains_seq/Coverage/2015-11-05-combine/")

library(intervals)

for (mrcnvr_name in c("./15V.copynumber.bed", 
                     "./25b.copynumber.bed", 
                     "./1B.copynumber.bed", 
                     "./74.copynumber.bed", 
                     "./6P.copynumber.bed",
                     "./222.copynumber.bed")) {



strain.name <- substr(mrcnvr_name, 3, 5)
if (substr(strain.name, 3, 3) == '.') {strain.name <- substr(strain.name, 1, 2)}

mrcnvr <- read.delim(mrcnvr_name)
#levels(mrcnvr$X.CHROM) <- c("I", "II", "III", "IV", "V", "VI", "VII", "VIII",
#                            "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "Mito")

#adjust for haploid state
mrcnvr$COPYNUMBER <- mrcnvr$COPYNUMBER / 2

#threshold <- quantile(x = mrcnvr$COPYNUMBER, .95)
#threshold <- 1.8 * median(mrcnvr$COPYNUMBER)
threshold <- 1.8

amplif_mrcnvr <- mrcnvr[mrcnvr$COPYNUMBER > threshold,]

merged_mrcnvr <- data.frame(chr = character(), start = numeric(), end = numeric())


tmp_list <- structure(list(chr = structure(amplif_mrcnvr[,1], class = "factor"),
                           start = amplif_mrcnvr[,2],
                           end = amplif_mrcnvr[,3], 
                           .Names = c("chr", "start", "end")))

#install.packages("intervals")
library(intervals)

for (chr in levels(amplif_mrcnvr$X.CHROM)) {
    sub_ampl_mrcnvr <- amplif_mrcnvr[amplif_mrcnvr$X.CHROM == chr,]
    idf <- Intervals(as.matrix(sub_ampl_mrcnvr[,2:3]))
    tmp_df <- as.data.frame(cbind(rep(chr, times = nrow(interval_union(idf))),
                                  interval_union(idf)))
    write.table(tmp_df, paste(strain.name, "ampl.intervals.bed", sep="."), 
                append = T, quote = F, row.names = F, col.names = F, sep = "\t")
    assign(chr, tmp_df)
}





#threshold <- quantile(x = mrcnvr$COPYNUMBER, .05)
#threshold <- median(mrcnvr$COPYNUMBER) / 1.8
threshold <- 0.3


deleted_mrcnvr <- mrcnvr[mrcnvr$COPYNUMBER < threshold,]

merged_mrcnvr <- data.frame(chr = character(), start = numeric(), end = numeric())


tmp_list <- structure(list(chr = structure(deleted_mrcnvr[,1], class = "factor"),
                           start = deleted_mrcnvr[,2],
                           end = deleted_mrcnvr[,3], 
                           .Names = c("chr", "start", "end")))

for (chr in levels(deleted_mrcnvr$X.CHROM)) {
    sub_del_mrcnvr <- deleted_mrcnvr[deleted_mrcnvr$X.CHROM == chr,]
    if (nrow(sub_del_mrcnvr)) {
        idf <- Intervals(as.matrix(sub_del_mrcnvr[,2:3]))
        tmp_df <- as.data.frame(cbind(rep(chr, times = nrow(interval_union(idf))),
                                      interval_union(idf)))
        write.table(tmp_df, paste(strain.name, "del.intervals.bed", sep="."), 
                append = T, quote = F, row.names = F, col.names = F, sep = "\t")
        assign(chr, tmp_df)}
}

}