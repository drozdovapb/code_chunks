setwd("/media/drozdovapb/441DB6652D7ED741/Work/Current work/Lab&colleagues/DQ/") #change it to ur path

if(!('gdata' %in% installed.packages())) {
install.packages("gdata")}

if(!('reshape2' %in% installed.packages())) {
    install.packages("reshape2")}

if(!('mixtools' %in% installed.packages())) {
    install.packages("mixtools")}

library(gdata) #for the starstWith function
library(reshape2) #we will need it later to rearrange values
library(mixtools) #Some statistics for bimodal distribution


#Functions

read_data <- function(path) {
    #read the data
    A <- read.delim(path, skip = 31, stringsAsFactors=F)
    #get rid of everything except chromosomes
    A <- A[startsWith(A$ID, "chr"), ]
    #get rid of non-informative probes
    #please note that you have to have the probes file in the same folder--or change to ur path
    good_probes <- read.delim("./probes", stringsAsFactors = F)$ProbeID
    A <- A[(A$ID %in% good_probes),]
    # get rid of flagged values
    A <- A[A$Flags == 0,]
    A <- A[A$Dia. == 45 | A$Dia. == 50 | A$Dia. == 55,]
    
    
    #replace chr1-9 with chr chr01-chr09 in order to be able to sort alphabetically
    A$ID <- sub(pattern = "chr(.):", replacement = "chr0\\1:", x = A$ID)
    ##A$Name <- sub(pattern = "chr(.):", replacement = "chr0\\1:", x = A$Name)
    ##table(nchar(A$Name)) #15, 17, 19, or 21
    #do the same with coordinates:
    ##A$Name <- sub(pattern = ":(......)-(......)", replacement = ":0\\1-0\\2", x = A$Name)
    ##A$Name <- sub(pattern = ":(.....)-(.....)", replacement = ":00\\1-00\\2", x = A$Name)
    ##A$Name <- sub(pattern = ":(....)-(....)", replacement = ":000\\1-000\\2", x = A$Name)
    A$ID <- sub(pattern = ":([0-9]{4}[A-Z]{2})", replacement = ":000\\1", x = A$ID)
    A$ID <- sub(pattern = ":([0-9]{5}[A-Z]{2})", replacement = ":00\\1", x = A$ID)
    A$ID <- sub(pattern = ":([0-9]{6}[A-Z]{2})", replacement = ":0\\1", x = A$ID)
        #now sort alphabetically (and this is now numerically true)
    A <- A[order(A$ID),]
    return(A)
}


preprocess_data <- function(A) {
    ###########################
    #Statistics for bimodal distribution
    ##hist(normalA$Ratio.of.Medians..635.532., breaks=1000, col="blue")
    
    #I have to assume some thresholds for acceptable values -- or I fail to treat this as a normal distribution
    normalA <- A[A$Ratio.of.Medians..635.532. > 0 & A$Ratio.of.Medians..635.532. < 3.5,]
    plot(density(normalA$Ratio.of.Medians..635.532.))

    
    message("Are there many NAs?")
    message(sum(is.na(normalA$Ratio.of.Medians..635.532.)))
    
    #now let's fit bimodal normal distribution and keep only values plus/minus sigma
    Astats <- normalmixEM(normalA$Ratio.of.Medians..635.532., k=2, epsilon = 1e-03, fast=TRUE)
    summary(Astats)

    #change here to include +- 2 sigmas or something else
            lower1 <- Astats$mu[1] - 3 * Astats$sigma[1]
            upper1 <- Astats$mu[1] + 3 * Astats$sigma[1]
            lower2 <- Astats$mu[2] - 3 * Astats$sigma[2]
            upper2 <- Astats$mu[2] + 3 * Astats$sigma[2]
    
    
    normalA$Ratio.of.Medians..635.532. <- 
        ifelse(normalA$Ratio.of.Medians..635.532. > lower1 & normalA$Ratio.of.Medians..635.532. < upper1 |
                normalA$Ratio.of.Medians..635.532. > lower2 & normalA$Ratio.of.Medians..635.532. < upper2, 
               normalA$Ratio.of.Medians..635.532., NA)
    
    message("Are there many NAs now?")
    message(sum(is.na(normalA$Ratio.of.Medians..635.532.)))
    
    
    Anew <- normalA[,c("ID", "Ratio.of.Medians..635.532.")]
    Anew$background <- ifelse(substr(normalA$ID, nchar(normalA$ID)-1, nchar(normalA$ID)-1) == "S", 
                              "W303", "YJM")
    
    #now we can cut the names to be able to merge probes later
    #for now we merge all the probes for the same region! 
    #change something here if you want to deal with forward and reverse probes separately
    Anew$ID <- substr(normalA$ID, 1, nchar(normalA$ID)-2)
    
    #some magic to get the type of table we need 
    #aggregate by average values
    #Amelt <- melt(Anew)
    Acast <- dcast(data = Anew, formula = ID ~ background, 
                   fun.aggregate = mean, value.var = "Ratio.of.Medians..635.532.")
    
    #Empirical thresholds for means: 0.75 and 1.25
    #mask everything else with NAs
    #Acast$W303 <- ifelse(Acast$W303 < 0.4 | Acast$W303 > 0.8, Acast$W303, NA) 
    #Acast$YJM <- ifelse(Acast$YJM < 0.4 | Acast$YJM > 0.8, Acast$YJM, NA)
    
    #plot distribution of values (uncomment if you would like to see the plots)
    plot(density(Acast$W303, na.rm = T), main="W303 after filtering")
    plot(density(Acast$YJM, na.rm = T), main="YJM789 after filtering")
    
    message("Are there many NAs now?")
    message("Calculating for W303...")
    message(sum(is.na(Acast$W303)))
    message("Calculating for YJM789...")
    message(sum(is.na(Acast$YJM)))
    
    Acast$chrom <- as.numeric(substr(Acast$ID, 4, 5))
    Acast$coord <- as.numeric(substr(Acast$ID, 7, 13))
    
    return(Acast)
}


infer_background <- function(Acast) {
    #add data about which is higher now (at least by threshold):
    threshold <- 0.4 #important! change it !!here if you like!!!
    Acast$background <- (ifelse(Acast$YJM - Acast$W303 > threshold, "YJM", 
                                ifelse(Acast$W303 - Acast$YJM > threshold, "W303", NA)))
    Acast$bckgnd <- (ifelse(Acast$YJM - Acast$W303 > threshold, 0, 
                            ifelse(Acast$W303 - Acast$YJM > threshold, 1, NA)))
    Acast$borders <- NA
    for (i in 2:nrow(Acast)) {
        if (!is.na(Acast$bckgnd[i]) & !is.na(Acast$bckgnd[i-1]) & 
                Acast$bckgnd[i] != Acast$bckgnd[i-1] & 
                Acast$chrom[i] == Acast$chrom[i-1]) {
            #Acast$borders[i-1] <- ifelse(Acast$background[i-1]=="YJM", "Yends", "Sends")
            #Acast$borders[i] <- ifelse(Acast$bckgnd[i]=="YJM", "Ystarts", "Sstarts")
            Acast$borders[i-1] <- paste(Acast$borders[i-1], "start")
            Acast$borders[i] <- paste(Acast$borders[i], "end")
            i <- i + 1 #or we will get these things overwritten every time?
        }}
    return(Acast)
}

paths <- c("./From DQ/JSC22-1-11A.gpr", "./From DQ//JSC22-1-11B.gpr", "./From DQ/JSC22-1-11C.gpr", "./From DQ//JSC22-1-11D.gpr")

Adata <- read_data(paths[1])
Bdata <- read_data(paths[2])
Cdata <- read_data(paths[3])
Ddata <- read_data(paths[4])


A <- preprocess_data(Adata)
B <- preprocess_data(Bdata)
C <- preprocess_data(Cdata)
D <- preprocess_data(Ddata)

Anew <- infer_background(A)
Bnew <- infer_background(B)
Cnew <- infer_background(C)
Dnew <- infer_background(D)

#what if we keep only differing blocks?
all_borders <- as.data.frame(cbind
                    (Anew$chrom, as.character(Anew$coord), 
                     Anew$background, Anew$borders, 
                     Bnew$background, Bnew$borders, 
                     Cnew$background, Cnew$borders, 
                     Dnew$background, Dnew$borders))
names(all_borders) <- c("chr", "coord", 
                        "state A", "transition A", 
                        "state B", "transition B", 
                        "state C", "transition C", 
                        "state D", "transition D")

#remove all rows where nothing happens
only_borders <- all_borders[rowSums(is.na(all_borders[,c(4,6,8,10)])) < 4, ]

write.csv(all_borders, "All borders.csv", quote = F)
write.csv(only_borders, "Borders.csv", quote = F)


#Print overview of each chromosome for visial inspection
#a small function to help manage plotting
plot_two_backgrounds <- function(chr) {
    plot(chr$YJM ~ chr$coord, type="l", col = "red",
         main = paste("chr", as.character(i), sep = ""),
         ylab = paste("Rm,", deparse(substitute(chr))), xlab = "coord",
         ylim = c(0, 2))
    lines(chr$W303 ~ chr$coord, type="l", col="blue") 
}

    
#Now plotting
for (i in 1:16) {
    png(paste("chr", as.character(i), ".png", sep=""), 
        height = 5.83, width = 8.27, units = "in", res=120)
    #subset to get data for each chromosome separately
    chrA <- A[A$chrom==i,]; chrB <- B[B$chrom==i,]
    chrC <- C[C$chrom==i,]; chrD <- D[D$chrom==i,]
    #set parameters for margins and multipanel plotting
    par(mar = c(3, 4, 2, 2))
    par(mgp=c(1.5, .5, 0))
    par(mfrow=c(4,1))
    #now plot
    plot_two_backgrounds(chrA)
    plot_two_backgrounds(chrB)
    plot_two_backgrounds(chrC)
    plot_two_backgrounds(chrD)
    dev.off()
}

#Defining events

only_borders$event <- NA

for (i in 1:nrow(only_borders)) {
    if (sum(is.na(only_borders[i, 4:10])) == 2) {
        only_borders$event[i] <- "CO"
    } else if (sum(is.na(only_borders[i, 4:10])) == 3) {
        only_borders$event[i] <- "CON"
}}

write.csv(only_borders, "Borders.csv", quote = F)