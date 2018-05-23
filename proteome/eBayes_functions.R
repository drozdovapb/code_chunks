##prepare packages
if (!"openxlsx" %in% installed.packages()) install.packages("openxlsx")
library("openxlsx")
#bioconductor packages
source("http://bioconductor.org/biocLite.R")
if (!("limma" %in% installed.packages())) biocLite("limma")
if (!("qvalue" %in% installed.packages())) biocLite("qvalue")
#load the packages
library(limma)
library(qvalue)
# This code installs and loads the vsn package. It's not needed if we do not use vsn normalization 
#(which we do not use in the current version of the code)
#if (! ("vsn" %in% installed.packages())) biocLite("vsn")
#library(vsn)

#Function for quick look at the data
explore.and.log <- function(rawsums, cols_with_LFQ) {
    #non-log
    boxplot(rawsums[, cols_with_LFQ], las=2, cex.axis=0.7, main="As is")
    boxplot(rawsums[, cols_with_LFQ], las=2, cex.axis=0.7, ylim=c(0,10**7), main="As is (cropped)")
    #Non-normalized #now log
    logvalues <- log2(rawsums[, cols_with_LFQ] + 10)
    boxplot(logvalues, las=2, cex.axis=0.7, main="Log")
    return(logvalues)
}

show.only.in.one <- function(rawsums, gr1cols, gr2cols) {
    rawsums$gr1only <- FALSE
    rawsums$gr2only <- FALSE
    message("Group 1: ", paste(names(rawsums)[gr1cols], " "))
    message("Group 2: ", paste(names(rawsums)[gr2cols], " "))
    for (row in 1:nrow(rawsums)) {
        if (sum(rawsums[row, gr1cols]) == 0 && 
            #sum(rawsums[row, gr2cols]) > 0) {
            sum(!rawsums[row, gr2cols] == 0) > 1) { #i.e. at least in 2 samples
            rawsums$gr1only[row] <- TRUE}
        if (sum(rawsums[row, gr2cols]) == 0 && 
            #sum(rawsums[row, gr1cols]) > 0) {
            sum(!rawsums[row, gr1cols] == 0) > 1) { #i.e. at least in 2 samples
            rawsums$gr2only[row] <- TRUE} }
    message("There were ", sum(rawsums$gr1only), 
            " hits in group 1 ", paste(names(rawsums)[gr1cols], " "), " only")
    #print(substr(rawsums[rawsums$gr1only,2], 1, 80))
    message("There were ", sum(rawsums$gr2only), 
            " hits in group 2 ", paste(names(rawsums)[gr2cols], " "), " only")
    #print(paste(rawsums[rawsums$gr2only,1], substr(rawsums[rawsums$gr2only,2], 1, 80)))
    #print(substr(rawsums[rawsums$gr2only,2], 1, 80))
    final <- rawsums[rawsums$gr2only | rawsums$gr1only, ]
    final <- final[order(final$gr1only),]
    return(final)
}

# a function to remove rows with at least one zero value
removezeros <- function(rawsums, cols_with_LFQ) {
    rawsums$nonzero <- NA
    message("looking at columns: ", paste(names(rawsums)[cols_with_LFQ], " "))
    for (row in 1:nrow(rawsums)) {
        rawsums$nonzero[row] <- !(0 %in% rawsums[row, cols_with_LFQ])
    }
    return(rawsums[rawsums$nonzero,])}

#normalization (cyclic loess used for now)
normalizedata <- function(logdata) {
    normdata <- normalizeBetweenArrays(logdata, method="cyc")
    boxplot(normdata, las=2, cex=0.7)
    return(normdata)
}


#Comparison & volcano plots
eb <- function(normvalues, design, cm) {
    fit <- lmFit(normvalues, design)
    fit <- contrasts.fit(fit, cm)
    fit.eb <- eBayes(fit)
    #fit.eb$coefficients
    tt <- topTable(fit.eb, coef = 1, n=500, adjust.method = "BH", sort.by = "none")
    signif <- ifelse(abs(tt$logFC) > 1 & tt$adj.P.Val < 0.05, "violetred", "black")
    p <- plot(tt$logFC, -log10(tt$adj.P.Val), xlab="log2 fold change", 
              ylab="-log10  p.adjusted (q)", main=paste("eBayes", 
              substitute(normvalues)), pch=19, cex=0.5, col = signif, las = 1)
    print(p)#, abline(h = 1.3, v = c(-1, 1), col = "red4", lty = 3))
    
    #print(volcanoplot(fit.eb, cex = 0.5, pch=19, las = 1))
    return(tt)}
