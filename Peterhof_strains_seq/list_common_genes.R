setwd("/media/drozdovapb/big/Peterhof_strains_seq/Phylogeny/2015-07-05-common_genes")

#allgenes <- readLines("./gene_lists.txt")
#allgenes[83425]


all_nucl_genes <- read.table("./gene_lists_nuclear.txt", sep="_", stringsAsFactors = F)
#readLines("./gene_lists_nuclear_verified.txt")[61435]
names(all_nucl_genes) <- c("ORF", "strain")
table(all_nucl_genes[,1])

library(reshape2)
d <- dcast(all_nucl_genes, ORF ~ strain)

head(d)

nrow(d)

row_sub <- apply(d, 1, function(row) all(row !=0))

dd <- d[row_sub,]
dd$V1

min(colSums(d[2:40]))
max(colSums(d[2:40]))

which(colSums(d[2:40]) == min(colSums(d[2:40])))

#remove CLIB382

d2 <- d[,-10]
row_sub <- apply(d2, 1, function(row) all(row !=0))

sum(as.numeric(row_sub))

which(colSums(d2[2:39]) == min(colSums(d2[2:39])))

d3 <- d[,-20]

sort(colSums(d[,-1]))

d3500 <- d[,! names(d) %in% c("M22", "Y10", "T73", "CLIB382")]
#dim(dnew)
row_sub <- apply(d3500, 1, function(row) all(row !=0))
sum(as.numeric(row_sub))


d5000 <- d[, ! names(d) %in% c("M22", "Y10", "T73", "CLIB382", "CLIB324", "UWOPS05-217-3", "AWRI1631", "RM11-1A")]
row_sub <- apply(d5000, 1, function(row) all(row !=0))
sum(as.numeric(row_sub))

genes <- sapply(d3500[row_sub,1], substr, 2, 100)
write.table(genes, "genes_more_3500.csv", quote = F, row.names = F, col.names = F)




###writing rearrange fasta

ReadFasta<-function(file) {
    # Read the file line by line
    fasta<-readLines(file)
    # Identify header lines
    ind<-grep(">", fasta)
    # Identify the sequence lines
    s<-data.frame(ind=ind, from=ind+1, to=c((ind-1)[-1], length(fasta)))
    # Process sequence lines
    seqs<-rep(NA, length(ind))
    for(i in 1:length(ind)) {
        seqs[i]<-paste(fasta[s$from[i]:s$to[i]], collapse="")
    }
    # Create a data frame 
    DF<-data.frame(sequence=as.character(seqs), ORF=as.character(gsub(">", "", fasta[ind])))
    # Return the data frame as a result object from the function
    return(DF)
}


#for (i in dir) {}

setwd("/media/drozdovapb/big/Peterhof_strains_seq/Phylogeny/2015-07-05-common_genes/CDS")


temp_fasta_holder <- ReadFasta("./15VP4_cds.fsa")
temp_fasta_holder$sequence <- as.character(temp_fasta_holder$sequence)
temp_fasta_holder$ORF <- as.character(temp_fasta_holder$ORF)
length(temp_fasta_holder$ORF)
length(unique(temp_fasta_holder$ORF))


head(temp_fasta_holder[order(temp_fasta_holder$ORF),])
temp_fasta_holder <- temp_fasta_holder[order(temp_fasta_holder$ORF),]

newfasta <- temp_fasta_holder[1,]
for (i in 2:6413) {
    if (i < 6413)
    {if (temp_fasta_holder$ORF[i] == temp_fasta_holder$ORF[i+1]) {
        temp_seq <- paste(temp_fasta_holder$sequence[i],
                          temp_fasta_holder$sequence[i+1],
                          sep="")
        newfasta <- rbind(newfasta, c(temp_seq, temp_fasta_holder$ORF[i]))
    }
    else if (temp_fasta_holder$ORF[i] == temp_fasta_holder$ORF[i-1]) next
    else newfasta <- rbind(newfasta, temp_fasta_holder[i,])}
    else if (temp_fasta_holder$ORF[i] == temp_fasta_holder$ORF[i-1]) next
    else newfasta <- rbind(newfasta, temp_fasta_holder[i,])
}


exportFASTA(sequences = newfasta, file = "15V-P4_cds.fsa")

#for (i in 1:10) {
#    if (i == 5) print(i)
#    else if (i == 6) next
#    else print('ha')
#}

#nrow(newfasta)

gene_list <- readLines("../genes_more_3500.csv")




for (strain in names(d3500)[-1]){
cat(
    paste("sed -e's/$/_", strain, "/' genes_more_3500.csv >genes_more_3500.", 
      strain, ".csv", '\n', sep=""))}


full_names <- c("15V-P4", 
                "AWRI1631_ABSV01000000",
                "AWRI796_ADVS01000000",
                "BC187_JRII00000000",
                "CBS7960_AEWL01000000",
                "CEN.PK2-1Ca_JRIV01000000",
                "CLIB215_AEWP01000000",
                "CLIB324_AEWM01000000",
#                "CLIB382_AFDG01000000",
                "DBVPG6044_JRIG00000000",
                "EC1118_PRJEA37863",
                "EC9-8_AGSJ01000000",
                "FostersB_AEHH01000000",
                "FostersO_AEEZ01000000",
                "JAY291_ACFL01000000",
                "K11_JRIJ00000000",
                "Kyokai7_BABQ01000000",
                "L1528_JRIK00000000",
                "LalvinQA23_ADVV01000000",
#                "M22_ABPC01000000",
                "PW5_AFDC01000000",
                "RedStar_JRIL00000000",
                "RM11-1A_JRIP00000000",
                "S288C_renamed",
                "Sigma1278b-10560-6B_JRIQ00000000",
#                "T73_AFDF01000000",
                "T7_AFDE01000000",
                "UC5_AFDD01000000",
                "UWOPS05-217-3_JRIM00000000",
                "Vin13_ADXC01000000",
                "VL3_AEJS01000000",
#                "Y10_AEWK01000000",
                "YJM269_AEWN01000000",
                "YJM339_JRIE00000000",
                "YJM789_AAFW02000000",
                "YPS128_JRID00000000",
                "YPS163_JRIC00000000",
                "YS9_JRIB00000000",
                "ZTW1_AMDD00000000")

names <- cbind(names(d3500)[-1], full_names)

for (i in 1:nrow(names)){
cat(
paste("faSomeRecords ", names[i,2], "_cds.fsa genes_more_3500.", 
names[i,1], ".csv ", names[i,1], ".796.fsa", '\n', sep=""))}


###########################

setwd("../selected_genes/")

all_fastas <- ReadFasta(dir()[1])
for (i in 2:length(dir())) {
    all_fastas <- rbind(all_fastas, ReadFasta(dir()[i]))
    
}

all_fastas$ORF <- as.character(all_fastas$ORF)
all_fastas$sequence <- as.character(all_fastas$sequence)

for (i in 1:length(genes)) {
    exportFASTA(sequences = all_fastas[substr(all_fastas$ORF, 1, 7) %in% genes[i],], 
                file = paste("../fastas_by_gene/", genes[i], ".fa", sep=""))
}
    
#user  system elapsed 
#24.748   1.468  26.287 


##without diploids


all_fastas <- ReadFasta(dir()[1])
for (i in 2:length(dir())) {
    all_fastas <- rbind(all_fastas, ReadFasta(dir()[i]))
    
}

all_fastas$ORF <- as.character(all_fastas$ORF)
all_fastas$sequence <- as.character(all_fastas$sequence)

for (i in 1:length(genes)) {
    exportFASTA(sequences = all_fastas[substr(all_fastas$ORF, 1, 7) %in% genes[i],], 
                file = paste("../fastas_by_gene/", genes[i], ".fa", sep=""))
}




####no diploids

d_no_dipl <- d[,! names(d) %in% c("M22", "Y10", "T73", "CLIB382", #too less genes annotated
                                  "AWRI796", "FostersB", "FostersO", 
                                  "LalvinQA23", "Vin13", "VL3")] #diploids
row_sub <- apply(d_no_dipl, 1, function(row) all(row !=0))
sum(as.numeric(row_sub))



genes <- sapply(d_no_dipl[row_sub,1], substr, 2, 100)
write.table(genes, "genes_no_dipl.csv", quote = F, row.names = F, col.names = F)


for (strain in names(d_no_dipl)[-1]){
    cat(
        paste("sed -e's/$/_", strain, "/' genes_no_dipl.csv >genes_no_dipl.", 
              strain, ".csv", '\n', sep=""))}


full_names <- c("15V-P4", 
                "AWRI1631_ABSV01000000",
#                "AWRI796_ADVS01000000",
                "BC187_JRII00000000",
                "CBS7960_AEWL01000000",
                "CEN.PK2-1Ca_JRIV01000000",
                "CLIB215_AEWP01000000",
                "CLIB324_AEWM01000000",
#                "CLIB382_AFDG01000000",
                "DBVPG6044_JRIG00000000",
                "EC1118_PRJEA37863",
                "EC9-8_AGSJ01000000",
#                "FostersB_AEHH01000000",
#                "FostersO_AEEZ01000000",
                "JAY291_ACFL01000000",
                "K11_JRIJ00000000",
                "Kyokai7_BABQ01000000",
                "L1528_JRIK00000000",
#                "LalvinQA23_ADVV01000000",
                #                "M22_ABPC01000000",
                "PW5_AFDC01000000",
                "RedStar_JRIL00000000",
                "RM11-1A_JRIP00000000",
                "S288C_renamed",
                "Sigma1278b-10560-6B_JRIQ00000000",
#                "T73_AFDF01000000",
                "T7_AFDE01000000",
                "UC5_AFDD01000000",
                "UWOPS05-217-3_JRIM00000000",
#                "Vin13_ADXC01000000",
#                "VL3_AEJS01000000",
#                "Y10_AEWK01000000",
                "YJM269_AEWN01000000",
                "YJM339_JRIE00000000",
                "YJM789_AAFW02000000",
                "YPS128_JRID00000000",
                "YPS163_JRIC00000000",
                "YS9_JRIB00000000",
                "ZTW1_AMDD00000000")

names <- cbind(names(d_no_dipl)[-1], full_names)

for (i in 1:nrow(names)){
    cat(
        paste("faSomeRecords ", names[i,2], "_cds.fsa ../genes_no_dipl.", 
              names[i,1], ".csv ", "../", names[i,1], ".807.fsa", '\n', sep=""))}


###########################

setwd("./selected_genes_2/")

all_fastas <- ReadFasta(dir()[1])
for (i in 2:length(dir())) {
    all_fastas <- rbind(all_fastas, ReadFasta(dir()[i]))
    
}

all_fastas$ORF <- as.character(all_fastas$ORF)
all_fastas$sequence <- as.character(all_fastas$sequence)

#807 genes

for (i in 1:length(genes)) {
    exportFASTA(sequences = all_fastas[substr(all_fastas$ORF, 1, 7) %in% genes[i],], 
                file = paste("../fastas_by_gene_807/", genes[i], ".fa", sep=""))
}



###systematically exploring the number of genes
head(d)
apply(d, 2, sum)
d2 <- apply(d[,-1], 2, "!=", 0)

str(d)

numgenes <- apply(d[-1], 2, sum)

d3 <- d
nums <- c()
while (ncol(d3) > 1) {
    #print(ncol(d3))
    row_sub <- apply(d3, 1, function(row) all(row !=0))
    print(ncol(d3[row_sub,]))
    minimal <- which(colSums(d3[-1]) == min(colSums(d3[-1])))
    d3 <- d3[,-minimal]
    nums <- c(nums, names(d)[minimal+1])
}
nums
