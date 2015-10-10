setwd("/media/drozdovapb/441DB6652D7ED741/Work/Current work/Lab&colleagues/DQ/") #change it to ur path
#if(!('gdata' %in% installed.packages()) {
#install.packages("gdata")
#install.packages("mixtools")

##library(gdata) # I don't probably need it
library(reshape2) #we will need it later to rearrange values
library(mixtools) #Some statistics for bimodal distribution

##The proper way to read files but requires additional packages installed
#install marray if it is not installed
#if(!('marray' %in% installed.packages()) {
#    source("http://bioconductor.org/biocLite.R")
#    biocLite("marray")}

#library(marray)

#data <- read.GenePix(path = "From DQ")

#QC

#install arrayQuality if not installed
#if (!("arrayQuality") %in% installed.packages()) {
#    source("http://bioconductor.org/biocLite.R")
#    biocLite("arrayQuality")}
#library(arrayQuality)


#Functions

read_data <- function(path) {
    #read the data
    A <- read.delim(path, skip = 31, stringsAsFactors=F)
    #get rid of everything except chromosomes
    A <- A[startsWith(A$ID, "chr"), ]
    # get rid of flagged values
    A <- A[A$Flags == 0,]
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
    normalA <- A[A$Ratio.of.Medians..635.532. > -.5 & A$Ratio.of.Medians..635.532. < 2.5,]
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
    
    ##summary(normalmixEM(A$Ratio.of.Medians..635.532., k=2, epsilon = 1e-03, fast=TRUE))
    
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
    
    #strain <- substr(A$ID[i], nchar(A$ID[i])-1, nchar(A$ID[i])-1)
    
    #some magic to get the type of table we need 
    #aggregate by average values
    #Amelt <- melt(Anew)
    Acast <- dcast(data = Anew, formula = ID ~ background, 
                   fun.aggregate = mean, value.var = "Ratio.of.Medians..635.532.")
    
    message("Are there many NAs now?")
    message("Calculating for W303...")
    message(sum(is.na(Acast$W303)))
    message("Calculating for YJM789...")
    message(sum(is.na(Acast$YJM)))
    
    Acast$chrom <- as.numeric(substr(Acast$ID, 4, 5))
    Acast$coord <- as.numeric(substr(Acast$ID, 7, 13))
    
    return(Acast)
}

#chr1 <- Acast[Acast$chrom==1,]
#plot(chr1$YJM ~ chr1$coord, type="l", col="red", main="chr1", xlab="Ratio of medians", ylab="coord")
#lines(chr1$W303 ~ chr1$coord, type="l", col="blue")


infer_background <- function(Acast) {
    
    #add data about which is higher now:
    Acast$background <- (ifelse(Acast$YJM > Acast$W303, "YJM", "W303"))
    Acast$bckgnd <- (ifelse(Acast$YJM > Acast$W303, 0, 1))
    Acast$borders <- NA
    for (i in 2:nrow(Acast)) {
        if (!is.na(Acast$bckgnd[i]) & !is.na(Acast$bckgnd[i-1]) & 
                Acast$bckgnd[i] != Acast$bckgnd[i-1]) {
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
                    (Anew$chr, as.character(Anew$coord), 
                     Anew$background, Anew$borders, 
                     Bnew$background, Bnew$borders, 
                     Cnew$background, Cnew$borders, 
                     Dnew$background, Dnew$borders))
names(all_borders) <- c("chr", "coord", 
                        "state A", "transition A", 
                        "state B", "transition B", 
                        "state C", "transition C", 
                        "state D", "transition D")

#remove all NA-only rows
only_borders <- all_borders[rowSums(is.na(all_borders)) < 4, ]

write.csv(all_borders, "All borders.csv", quote = F)
write.csv(only_borders, "Borders.csv", quote = F)


for (i in 1:16) {
    png(paste("chr", as.character(i), ".png", sep=""))
    #subset to get data for each chromosome separately
    chrA <- A[A$chrom==i,]; chrB <- B[B$chrom==i,]; chrC <- C[C$chrom==i,]; chrD <- D[D$chrom==i,]
    par(mfrow=c(4,1))
    print(plot(chrA$YJM ~ chrA$coord, type="l", col="red", 
         main=paste("chr", as.character(i), sep=""), ylab="Ratio of medians, spore A", xlab="coord"))
    print(lines(chrA$W303 ~ chrA$coord, type="l", col="blue"))
    print(plot(chrB$YJM ~ chrB$coord, type="l", col="red", 
         main=paste("chr", as.character(i), sep=""), ylab="Ratio of medians, spore B", xlab="coord"))
    print(lines(chrB$W303 ~ chrB$coord, type="l", col="blue"))
    print(plot(chrC$YJM ~ chrC$coord, type="l", col="red", 
         main=paste("chr", as.character(i), sep=""), ylab="Ratio of medians, spore C", xlab="coord"))
    print(lines(chrC$W303 ~ chrC$coord, type="l", col="blue"))
    print(plot(chrD$YJM ~ chrD$coord, type="l", col="red", 
         main=paste("chr", as.character(i), sep=""), ylab="Ratio of medians, spore D", xlab="coord"))
    print(lines(chrD$W303 ~ chrD$coord, type="l", col="blue"))
    dev.off()
}
